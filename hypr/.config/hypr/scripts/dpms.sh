#!/usr/bin/env bash
# dpms.sh {on|off|toggle|status} — đặt DPMS về ĐÚNG trạng thái yêu cầu.
#
# TẠI SAO CẦN SCRIPT NÀY (đo 2026-09-01, Hyprland 0.56.2 provider lua):
#   `hl.dsp.dpms("on")` và `hl.dsp.dpms("off")` cho KẾT QUẢ GIỐNG HỆT NHAU —
#   tham số bị bỏ qua, dispatcher là TOGGLE thuần:
#       dpms("off") từ True  -> False      dpms("off") từ False -> True
#       dpms("on")  từ True  -> False      dpms("on")  từ False -> True
#   Nên `on-timeout = ... dpms off` / `on-resume = ... dpms on` kiểu ngây thơ sẽ
#   ĐẢO NGƯỢC ngay khi lỡ một sự kiện: lần idle sau sẽ BẬT màn thay vì tắt.
#   (Kiểu legacy `hyprctl dispatch dpms off` thì fail exit 7 dưới provider lua.)
#
# Cách chữa: đọc dpmsStatus trước, chỉ toggle khi khác trạng thái mong muốn.

want="${1:-status}"

state() {   # in ra "on" hoặc "off"
    hyprctl monitors -j 2>/dev/null \
        | jq -r 'if any(.[]; .dpmsStatus) then "on" else "off" end'
}

toggle() { hyprctl dispatch 'hl.dsp.dpms("toggle")' >/dev/null 2>&1; }

case "$want" in
    status) state; exit 0 ;;
    toggle) toggle; exit 0 ;;
    on|off) ;;
    *) printf 'dùng: %s {on|off|toggle|status}\n' "${0##*/}" >&2; exit 2 ;;
esac

# Tối đa 3 lần thử — toggle có thể trượt nếu người dùng chạm chuột đúng lúc
# (mouse_move_enables_dpms = true).
for _ in 1 2 3; do
    [ "$(state)" = "$want" ] && exit 0
    toggle
    sleep 0.4
done

[ "$(state)" = "$want" ]
