#!/usr/bin/env bash
# Waybar custom module: chỉ báo "đang quay màn hình".
# Dùng chung PID file với ~/.config/hypr/scripts/screenrecord.sh → hiện khi wf-recorder
# đang chạy, ẩn khi không (config bật hide-empty-text). Cập nhật tức thì nhờ screenrecord.sh
# gửi SIGRTMIN+9 cho waybar mỗi lần start/stop; interval chỉ là fallback.
#
# Usage:
#   recording.sh status   # in JSON cho waybar
#   recording.sh stop     # dừng quay (gắn vào on-click)

RUNDIR="${XDG_RUNTIME_DIR:-/tmp}/screenrecord"
PID_FILE="$RUNDIR/wf-recorder.pid"
FILE_FILE="$RUNDIR/current-file"

is_recording() {
    [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null
}

case "${1:-status}" in
    status)
        if is_recording; then
            f="$(cat "$FILE_FILE" 2>/dev/null)"; f="${f##*/}"
            printf '{"text":"󰑊","tooltip":"Đang quay màn hình\\n%s\\nClick để dừng","class":"recording"}\n' "${f:-recording}"
        else
            printf '{"text":"","tooltip":"","class":"idle"}\n'
        fi
        ;;
    stop)
        ~/.config/hypr/scripts/screenrecord.sh stop
        ;;
    *)
        echo "Usage: $0 {status|stop}" >&2
        exit 1
        ;;
esac
