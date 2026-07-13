#!/usr/bin/env bash
# Reload waybar (config + CSS).
# swaync do systemd user unit quản lý (enabled, WantedBy=graphical-session.target)
# — script này KHÔNG đụng vào nữa. Trước đây `killall swaync` + nohup đua với
# Restart=on-failure của unit → có thể sinh 2 instance.

set -eu

if pgrep -x waybar >/dev/null 2>&1; then
    # SIGUSR2 = waybar tự restart tại chỗ, re-read config/style
    pkill -SIGUSR2 -x waybar
elif command -v uwsm >/dev/null 2>&1; then
    setsid -f uwsm app -- waybar >/dev/null 2>&1
else
    nohup waybar >/tmp/waybar.log 2>&1 &
fi
