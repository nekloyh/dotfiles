#!/usr/bin/env bash
# Workspace-layout sync theo EVENT — thay module waybar polling 2s cũ
# (custom/monitor-layout-sync fork bash+hyprctl+jq mỗi 2 giây, tốn pin vô ích).
# Nghe socket2 của Hyprland, chỉ chạy sync khi monitor được thêm/gỡ.
# Khởi động từ exec-once (uwsm app --), sống suốt session.

set -u

sync="$HOME/.config/waybar/scripts/sync-workspaces-layout.sh"
runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# exec-once có sẵn HYPRLAND_INSTANCE_SIGNATURE; fallback cho chạy tay/debug.
sig="${HYPRLAND_INSTANCE_SIGNATURE:-$(ls -t "$runtime/hypr" 2>/dev/null | head -n1)}"
sock="$runtime/hypr/$sig/.socket2.sock"

# Sync một lần lúc khởi động — áp trạng thái monitor hiện tại.
"$sync" >/dev/null 2>&1 || true

while :; do
    if [ ! -S "$sock" ]; then
        sleep 5
        continue
    fi
    socat -u "UNIX-CONNECT:$sock" - 2>/dev/null | while IFS= read -r event; do
        case "$event" in
            monitoradded*|monitorremoved*)
                # Đợi waybar xử lý xong output add/remove trước khi sync
                # (SIGUSR2 reload đến giữa lúc waybar đang gỡ output → crash, waybar 0.15).
                sleep 1.5
                "$sync" >/dev/null 2>&1 || true
                # Watchdog: reload trong lúc hotplug vẫn có thể làm waybar chết — hồi sinh.
                sleep 2
                if ! pgrep -x waybar >/dev/null 2>&1; then
                    setsid -f uwsm app -- waybar >/dev/null 2>&1 || setsid -f waybar >/dev/null 2>&1
                fi
                ;;
        esac
    done
    # Socket đứt (Hyprland restart?) — chờ rồi kết nối lại.
    sleep 3
done
