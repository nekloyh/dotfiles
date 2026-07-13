#!/usr/bin/env bash
# Screenshot wrapper: bypass hyprshot, freeze qua hyprpicker, slurp với rectangle vô hình.
# Lý do: hyprshot's freeze + default slurp vẫn để slurp's selection rect leak vào capture
# (thấy thành "viền đen"). Cách này dùng slurp colors hoàn toàn trong suốt nên không có gì
# slurp vẽ ra có thể bị grim capture.
#
# Usage:
#   screenshot.sh region-clip   # region → clipboard only
#   screenshot.sh region        # region → save + clipboard
#   screenshot.sh window        # active window → save + clipboard
#   screenshot.sh output        # active output → save + clipboard

set -euo pipefail

MODE="${1:-region-clip}"
SAVE_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
TS="$(date +'%Y-%m-%d_%H-%M-%S')"
FILE="$SAVE_DIR/${TS}.png"

# Slurp với toàn bộ overlay trong suốt — chỉ dim background nhẹ để user thấy con trỏ.
# -b: vùng ngoài selection (dim nhẹ)
# -c: viền selection (trong suốt → không có viền đen)
# -s: vùng selection (trong suốt → thấy nội dung gốc)
# -B: option box (trong suốt)
# -w 0: border weight 0 — không vẽ viền
SLURP_ARGS=(-b '#00000040' -c '#00000000' -s '#00000000' -B '#00000000' -w 0)

freeze_start() {
    if command -v hyprpicker >/dev/null 2>&1; then
        hyprpicker -r -z >/dev/null 2>&1 &
        FREEZE_PID=$!
        sleep 0.15
    fi
}

freeze_stop() {
    [ -n "${FREEZE_PID:-}" ] && kill "$FREEZE_PID" 2>/dev/null
    pkill -x hyprpicker 2>/dev/null || true
}
trap freeze_stop EXIT

active_window_geom() {
    hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
}

active_output_geom() {
    local ws monitors
    ws=$(hyprctl -j activeworkspace)
    monitors=$(hyprctl -j monitors)
    echo "$monitors" | jq -r --argjson ws "$ws" \
        'first(.[] | select(.activeWorkspace.id == $ws.id))
         | "\(.x),\(.y) \((.width/.scale)|round)x\((.height/.scale)|round)"'
}

capture_to_clipboard() {
    local geom="$1"
    grim -g "$geom" - | wl-copy --type image/png
    notify-send -t 3000 "Screenshot" "Copied to clipboard"
}

capture_to_file() {
    local geom="$1"
    mkdir -p "$SAVE_DIR"
    grim -g "$geom" "$FILE"
    wl-copy --type image/png < "$FILE"
    notify-send -t 4000 "Screenshot" "Saved: $FILE"
}

case "$MODE" in
    region-clip)
        freeze_start
        GEOM=$(slurp "${SLURP_ARGS[@]}" || true)
        [ -n "$GEOM" ] && capture_to_clipboard "$GEOM"
        ;;
    region)
        freeze_start
        GEOM=$(slurp "${SLURP_ARGS[@]}" || true)
        [ -n "$GEOM" ] && capture_to_file "$GEOM"
        ;;
    window)
        capture_to_file "$(active_window_geom)"
        ;;
    output)
        capture_to_file "$(active_output_geom)"
        ;;
    *)
        echo "Unknown mode: $MODE" >&2
        echo "Usage: $0 {region-clip|region|window|output}" >&2
        exit 1
        ;;
esac
