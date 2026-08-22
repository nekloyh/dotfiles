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

# Config provider lua (Hyprland ≥0.55): dispatcher legacy ("dispatch exec ...")
# bị từ chối → dùng cú pháp lua (hl.dsp.*). Giữ dạng legacy làm FALLBACK cho
# rollback về hyprland.conf (mỗi provider chỉ chấp nhận đúng một cú pháp).
if ! has_pad; then
    hyprctl dispatch 'hl.dsp.exec_cmd("alacritty --class scratchpad", { workspace = "special:magic silent" })' >/dev/null 2>&1 \
        || hyprctl dispatch exec "[workspace special:magic silent] alacritty --class scratchpad" >/dev/null
    # đợi window thật sự map (poll thay vì sleep cứng — cold-start alacritty ~0.3s
    # nhưng có thể lâu hơn); tránh reveal special rỗng, tránh phụ thuộc timing.
    for _ in $(seq 40); do has_pad && break; sleep 0.05; done
fi
# follow_mouse=1 + spawn 'silent': pad không tự nhận focus khi map, và khi special
# trượt vào, focus bị hút về cửa sổ nằm dưới con trỏ → gõ nhầm. Ghi lại trạng thái
# TRƯỚC toggle: nếu special đang ẩn thì lần này là REVEAL → chủ động focus pad (focus
# giữ tới khi chuột di chuyển, đúng như window mới). Khi HIDE thì không đụng vào focus.
was_active=$(hyprctl monitors -j | jq -r 'any(.[]; .specialWorkspace.name == "special:magic")')
hyprctl dispatch 'hl.dsp.workspace.toggle_special("magic")' >/dev/null 2>&1 \
    || hyprctl dispatch togglespecialworkspace magic >/dev/null
if [ "$was_active" = "false" ]; then
    hyprctl dispatch 'hl.dsp.focus({ window = "class:^scratchpad$" })' >/dev/null 2>&1 \
        || hyprctl dispatch focuswindow "class:^scratchpad$" >/dev/null
fi
