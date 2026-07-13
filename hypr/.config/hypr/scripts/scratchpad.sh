#!/usr/bin/env bash
# Scratchpad terminal — SUPER+S.
# Lần đầu: spawn alacritty (class "scratchpad", windowrule float 62%×58% center
# trong special:magic) rồi hiện. Các lần sau: chỉ toggle hiện/ẩn.
# Terminal sống ngầm trong special workspace → trạng thái shell được giữ nguyên.

if ! hyprctl clients -j | jq -e '[.[] | select(.class == "scratchpad")] | length > 0' >/dev/null 2>&1; then
    hyprctl dispatch exec "[workspace special:magic] alacritty --class scratchpad" >/dev/null
    # đợi window map vào special trước khi reveal (cold-start alacritty cần ~0.3s;
    # nếu map muộn hơn nữa cũng không sao — special đã hiện, terminal nhảy vào sau)
    sleep 0.35
fi
hyprctl dispatch togglespecialworkspace magic >/dev/null
