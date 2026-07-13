#!/usr/bin/env bash
# Scratchpad terminal — SUPER+S.
# Lần đầu: spawn alacritty (class "scratchpad", windowrule float 1580×930 center
# trong special:magic) SILENT rồi toggle hiện. Các lần sau: chỉ toggle hiện/ẩn.
# Terminal sống ngầm trong special workspace → trạng thái shell được giữ nguyên.
#
# 'silent' RẤT quan trọng: nếu thiếu, window vừa map sẽ TỰ bung special ra (vì được
# focus), rồi `togglespecialworkspace` ngay sau đó lại ẩn nó đi (double-toggle) →
# triệu chứng "bật lên bị tắt mất, phải bấm lại lần nữa". Với silent, window vào
# special mà không tự hiện → chỉ còn đúng 1 toggle để reveal, hết race.

has_pad() { hyprctl clients -j | jq -e 'any(.[]; .class == "scratchpad")' >/dev/null 2>&1; }

if ! has_pad; then
    hyprctl dispatch exec "[workspace special:magic silent] alacritty --class scratchpad" >/dev/null
    # đợi window thật sự map (poll thay vì sleep cứng — cold-start alacritty ~0.3s
    # nhưng có thể lâu hơn); tránh reveal special rỗng, tránh phụ thuộc timing.
    for _ in $(seq 40); do has_pad && break; sleep 0.05; done
fi
hyprctl dispatch togglespecialworkspace magic >/dev/null
