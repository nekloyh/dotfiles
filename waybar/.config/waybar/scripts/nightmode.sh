#!/usr/bin/env bash
# Toggle gammastep day/night. `gammastep -O` applies once and may exit, so keep
# the toggle state in a small runtime file instead of checking for a process.

set -u

NIGHT_TEMP="${NIGHT_TEMP:-2400}"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="$STATE_DIR/waybar-nightmode.state"
WAYBAR_SIGNAL=10   # custom/nightmode "signal": 10

is_night() {
    [[ -f "$STATE_FILE" ]] && [[ "$(cat "$STATE_FILE" 2>/dev/null)" == "night" ]]
}

refresh_waybar() {
    pkill -RTMIN+"$WAYBAR_SIGNAL" -x waybar 2>/dev/null || true
}

apply_day() {
    # On Wayland, killing the gammastep client releases the gamma adjustment
    # — no `gammastep -x` needed (it would block in the foreground).
    pkill -x gammastep >/dev/null 2>&1 || true
    rm -f "$STATE_FILE"
}

apply_night() {
    pkill -x gammastep >/dev/null 2>&1 || true
    # On Wayland, `gammastep -O` runs in the foreground holding the gamma
    # control. Detach it so the waybar click-handler shell can return without
    # killing the child process.
    setsid -f gammastep -O "$NIGHT_TEMP" >/dev/null 2>&1 &
    disown 2>/dev/null || true
    # Wait briefly and confirm the process actually started.
    for _ in 1 2 3 4 5; do
        if pgrep -x gammastep >/dev/null 2>&1; then
            printf 'night\n' > "$STATE_FILE"
            return 0
        fi
        sleep 0.05
    done
    return 1
}

notify() {
    local mode="$1" temp="$2"
    local icon message
    if [[ "$mode" == "night" ]]; then
        icon="weather-clear-night"
        message="night mode${temp:+ (${temp}K)}"
    elif [[ "$mode" == "day" ]]; then
        icon="weather-clear"
        message="day mode"
    else
        icon="dialog-warning"
        message="$mode"
    fi
    notify-send -e \
        -h string:x-canonical-private-synchronous:nightmode_notif \
        -u low \
        -i "$icon" \
        "Display" "$message"
}

case "${1:---toggle}" in
    --toggle)
        if is_night; then
            apply_day
            notify "day" ""
        else
            if apply_night; then
                notify "night" "$NIGHT_TEMP"
            else
                notify "night mode failed" ""
            fi
        fi
        refresh_waybar
        ;;
    --day)
        apply_day
        notify "day" ""
        refresh_waybar
        ;;
    --night)
        if apply_night; then
            notify "night" "$NIGHT_TEMP"
        else
            notify "night mode failed" ""
        fi
        refresh_waybar
        ;;
    --status)
        if is_night; then echo "night"; else echo "day"; fi
        ;;
    --waybar)
        if is_night; then
            printf '{"text":"󰖔","tooltip":"Night mode: ON (%sK)\\nClick: về day mode","class":"night","alt":"night"}\n' "$NIGHT_TEMP"
        else
            printf '{"text":"󰖨","tooltip":"Night mode: OFF\\nClick: bật night mode (%sK)","class":"day","alt":"day"}\n' "$NIGHT_TEMP"
        fi
        ;;
esac
