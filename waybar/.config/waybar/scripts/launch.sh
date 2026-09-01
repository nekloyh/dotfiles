#!/usr/bin/env bash
# Reload waybar (config + CSS).
# swaync do systemd user unit quản lý (enabled, WantedBy=graphical-session.target)
# — script này KHÔNG đụng vào nữa. Trước đây `killall swaync` + nohup đua với
# Restart=on-failure của unit → có thể sinh 2 instance.

set -eu

# KHÔNG dùng SIGUSR2: waybar 0.15 SEGFAULT khi nhận SIGUSR2 để reload, nhất là
# nếu tín hiệu đến giữa lúc output đang được gỡ/thêm (hotplug). Cách duy nhất an
# toàn là restart hẳn process. Xem monitor-events.sh (watchdog hồi sinh waybar).
if pgrep -x waybar >/dev/null 2>&1; then
    pkill -x waybar
    # chờ process thật sự chết trước khi spawn lại, tránh 2 instance
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        pgrep -x waybar >/dev/null 2>&1 || break
        sleep 0.1
    done
fi

if command -v uwsm >/dev/null 2>&1; then
    setsid -f uwsm app -- waybar >/dev/null 2>&1
else
    nohup waybar >/tmp/waybar.log 2>&1 &
fi
