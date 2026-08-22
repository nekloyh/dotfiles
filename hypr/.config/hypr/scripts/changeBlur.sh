#!/usr/bin/env bash
# Toggle blur intensity (low ↔ normal) on the fly

iDIR="$HOME/.config/swaync/icons"

STATE=$(hyprctl -j getoption decoration:blur:passes | jq ".int")

# Config provider lua (Hyprland ≥0.55): `hyprctl keyword` bị từ chối → dùng
# `hyprctl eval` + hl.config. Giữ keyword làm FALLBACK cho rollback về
# hyprland.conf (eval chỉ chạy với provider lua, keyword chỉ với legacy).
set_blur() {
    size="$1"; passes="$2"
    hyprctl eval "hl.config({ decoration = { blur = { size = ${size}, passes = ${passes} } } })" >/dev/null 2>&1 \
        || { hyprctl keyword decoration:blur:size "${size}"; hyprctl keyword decoration:blur:passes "${passes}"; } >/dev/null 2>&1 \
        || true
}

if [ "${STATE}" == "2" ]; then
    set_blur 2 1
    notify-send -e -u low -i "$iDIR/dropper.png" "Blur" "Less Blur (size 2 / 1 pass)"
else
    set_blur 5 2
    notify-send -e -u low -i "$iDIR/dropper.png" "Blur" "Normal Blur (size 5 / 2 passes)"
fi
