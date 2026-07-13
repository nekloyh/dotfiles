#!/usr/bin/env bash
# Screen-record wrapper: wf-recorder với VAAPI hardware encode (Intel iGPU) + mic & âm thanh
# hệ thống gộp qua một null-sink PipeWire tạm.
#
# Lý do thiết kế:
#   - Encode H264 trên renderD128 (Intel iGPU) → gần như không tốn CPU, tiết kiệm điện/nhiệt.
#     Để dGPU (RTX 3060, renderD129) ngủ.
#   - wf-recorder chỉ nhận MỘT audio device. Muốn thu cả mic + loa cùng lúc → tạo null-sink
#     "screenrec_mix", loopback monitor của default sink + default source (mic) vào đó, rồi
#     record monitor của null-sink. Null-sink không phát ra loa nên không vọng (echo).
#   - Cùng một keybind dùng để bắt đầu VÀ dừng (toggle). Dừng = SIGINT để wf-recorder
#     finalize file mp4 sạch, sau đó gỡ các module audio tạm.
#
# Usage:
#   screenrecord.sh region   # chọn vùng (slurp) rồi quay
#   screenrecord.sh full     # quay nguyên màn hình đang focus
#   screenrecord.sh stop     # dừng (thường gọi qua chính keybind toggle)

set -euo pipefail

MODE="${1:-region}"
SAVE_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"
RUNDIR="${XDG_RUNTIME_DIR:-/tmp}/screenrecord"
PID_FILE="$RUNDIR/wf-recorder.pid"
MODULES_FILE="$RUNDIR/pw-modules"   # các module-id PipeWire cần gỡ khi stop
FILE_FILE="$RUNDIR/current-file"    # đường dẫn file đang quay

VAAPI_DEVICE="/dev/dri/renderD128"  # Intel iGPU
MIX_SINK="screenrec_mix"

mkdir -p "$RUNDIR"

# slurp với overlay trong suốt — đồng bộ với screenshot.sh
SLURP_ARGS=(-b '#00000040' -c '#8388e8ff' -s '#00000000' -B '#00000000' -w 1)

is_recording() {
    [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

# Đẩy waybar cập nhật module custom/recording ngay lập tức (SIGRTMIN+9, khớp "signal": 9).
refresh_waybar() {
    pkill -RTMIN+9 waybar 2>/dev/null || true
}

teardown_audio() {
    if [ -f "$MODULES_FILE" ]; then
        # gỡ ngược thứ tự đã load
        tac "$MODULES_FILE" | while read -r id; do
            [ -n "$id" ] && pactl unload-module "$id" 2>/dev/null || true
        done
        rm -f "$MODULES_FILE"
    fi
}

setup_audio() {
    : > "$MODULES_FILE"
    local sink src null_id lb_sys lb_mic
    sink="$(pactl get-default-sink)"
    src="$(pactl get-default-source)"

    null_id=$(pactl load-module module-null-sink \
        sink_name="$MIX_SINK" \
        sink_properties=device.description=ScreenRecMix)
    echo "$null_id" >> "$MODULES_FILE"

    # âm thanh hệ thống: monitor của sink mặc định → mix
    lb_sys=$(pactl load-module module-loopback \
        source="${sink}.monitor" sink="$MIX_SINK" latency_msec=20)
    echo "$lb_sys" >> "$MODULES_FILE"

    # mic: source mặc định → mix
    lb_mic=$(pactl load-module module-loopback \
        source="$src" sink="$MIX_SINK" latency_msec=20)
    echo "$lb_mic" >> "$MODULES_FILE"

    # chờ monitor của null-sink thực sự xuất hiện (nếu không wf-recorder sẽ bỏ audio)
    for _ in $(seq 1 30); do
        pactl list short sources 2>/dev/null | grep -q "${MIX_SINK}.monitor" && return 0
        sleep 0.05
    done
}

stop_recording() {
    if is_recording; then
        kill -INT "$(cat "$PID_FILE")" 2>/dev/null || true
        # chờ wf-recorder finalize mp4
        for _ in $(seq 1 50); do
            is_recording || break
            sleep 0.1
        done
    fi
    rm -f "$PID_FILE"
    teardown_audio
    local saved=""
    [ -f "$FILE_FILE" ] && saved="$(cat "$FILE_FILE")" && rm -f "$FILE_FILE"
    if [ -n "$saved" ]; then
        wl-copy "$saved" 2>/dev/null || true
        notify-send -t 4000 "Screen recording" "Đã lưu: $saved"$'\n'"(đường dẫn đã copy vào clipboard)"
    else
        notify-send -t 3000 "Screen recording" "Đã dừng quay"
    fi
    refresh_waybar
}

focused_output() {
    hyprctl -j monitors | jq -r 'first(.[] | select(.focused)) | .name'
}

start_recording() {
    local -a geom_args=()
    case "$MODE" in
        region)
            local geom
            geom=$(slurp "${SLURP_ARGS[@]}") || exit 0   # huỷ chọn → thoát êm
            [ -z "$geom" ] && exit 0
            geom_args=(-g "$geom")
            ;;
        full)
            geom_args=(-o "$(focused_output)")
            ;;
        *)
            echo "Unknown mode: $MODE" >&2
            echo "Usage: $0 {region|full|stop}" >&2
            exit 1
            ;;
    esac

    mkdir -p "$SAVE_DIR"
    local ts file
    ts="$(date +'%Y-%m-%d_%H-%M-%S')"
    file="$SAVE_DIR/${ts}.mp4"
    echo "$file" > "$FILE_FILE"

    setup_audio   # tạo null-sink + loopback và chờ monitor sẵn sàng

    # Lưu ý: KHÔNG dùng --audio-backend=pipewire — backend đó capture null-sink monitor ra
    # 0 mẫu (Qavg nan) và mp4 loại bỏ track rỗng. Backend PulseAudio mặc định (qua
    # pipewire-pulse) thu đúng cả mic + loa đã gộp.
    wf-recorder \
        --codec h264_vaapi \
        --device "$VAAPI_DEVICE" \
        --audio="${MIX_SINK}.monitor" \
        "${geom_args[@]}" \
        -f "$file" \
        >/dev/null 2>&1 &
    echo $! > "$PID_FILE"

    notify-send -t 2500 "Screen recording" "Đang quay (${MODE}) — bấm lại keybind để dừng"
    refresh_waybar
}

# ── toggle ────────────────────────────────────────────────────────────────────
# Đang quay → bất kỳ lệnh nào (region/full/stop) cũng dừng. Chưa quay → bắt đầu.
if [ "$MODE" = "stop" ] || is_recording; then
    stop_recording
else
    start_recording
fi
