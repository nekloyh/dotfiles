#!/usr/bin/env bash
# Volume control — wpctl (PipeWire native).
# Một đường duy nhất cho CẢ keybind XF86 lẫn waybar click/scroll:
# cùng step (5%), cùng limit (100%, không boost), cùng notification.
# (Trước đây keybind dùng wpctl limit 100% còn waybar dùng pamixer boost 150% — đã hợp nhất.)

iDIR="$HOME/.config/swaync/icons"
STEP=5
SINK="@DEFAULT_AUDIO_SINK@"
SOURCE="@DEFAULT_AUDIO_SOURCE@"

# wpctl get-volume → "Volume: 0.65 [MUTED]" → phần trăm nguyên
level_of() {
    wpctl get-volume "$1" 2>/dev/null | awk '{printf "%d", $2 * 100 + 0.5}'
}

is_muted() {
    wpctl get-volume "$1" 2>/dev/null | grep -q '\[MUTED\]'
}

# ===== Sink (loa) =====

get_volume() {
    local level
    level=$(level_of "$SINK")
    if is_muted "$SINK" || [[ "${level:-0}" -eq 0 ]]; then
        echo "Muted"
    else
        echo "${level}%"
    fi
}

get_icon() {
    local current
    if is_muted "$SINK"; then
        echo "$iDIR/volume-mute.png"
        return
    fi
    current=$(level_of "$SINK")
    if [[ "${current:-0}" -le 30 ]]; then
        echo "$iDIR/volume-low.png"
    elif [[ "$current" -le 60 ]]; then
        echo "$iDIR/volume-mid.png"
    else
        echo "$iDIR/volume-high.png"
    fi
}

notify_user() {
    local level
    level=$(level_of "$SINK")
    if is_muted "$SINK" || [[ "${level:-0}" -eq 0 ]]; then
        notify-send -e -h string:x-canonical-private-synchronous:volume_notif \
            -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$(get_icon)" \
            " Volume:" " Muted"
    else
        notify-send -e -h int:value:"$level" -h string:x-canonical-private-synchronous:volume_notif \
            -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$(get_icon)" \
            " Volume Level:" " ${level}%"
    fi
}

inc_volume() {
    if is_muted "$SINK"; then
        toggle_mute
    else
        wpctl set-volume -l 1.0 "$SINK" "${1}%+" && notify_user
    fi
}

dec_volume() {
    if is_muted "$SINK"; then
        toggle_mute
    else
        wpctl set-volume "$SINK" "${1}%-" && notify_user
    fi
}

toggle_mute() {
    wpctl set-mute "$SINK" toggle || return 1
    if is_muted "$SINK"; then
        notify-send -e -u low -h string:x-canonical-private-synchronous:volume_notif \
            -h boolean:SWAYNC_BYPASS_DND:true -i "$iDIR/volume-mute.png" " Volume:" " Muted"
    else
        notify-send -e -u low -h string:x-canonical-private-synchronous:volume_notif \
            -h boolean:SWAYNC_BYPASS_DND:true -i "$(get_icon)" " Volume:" " $(level_of "$SINK")%"
    fi
}

# ===== Source (mic) =====

toggle_mic() {
    wpctl set-mute "$SOURCE" toggle || return 1
    if is_muted "$SOURCE"; then
        notify-send -e -u low -h string:x-canonical-private-synchronous:volume_notif \
            -h boolean:SWAYNC_BYPASS_DND:true -i "$iDIR/microphone-mute.png" " Microphone:" " Switched OFF"
    else
        notify-send -e -u low -h string:x-canonical-private-synchronous:volume_notif \
            -h boolean:SWAYNC_BYPASS_DND:true -i "$iDIR/microphone.png" " Microphone:" " Switched ON"
    fi
}

# Execute accordingly
case "$1" in
"--get")
  get_volume
  ;;
"--inc")
  inc_volume "$STEP"
  ;;
"--dec")
  dec_volume "$STEP"
  ;;
"--toggle")
  toggle_mute
  ;;
"--toggle-mic")
  toggle_mic
  ;;
*)
  get_volume
  ;;
esac
