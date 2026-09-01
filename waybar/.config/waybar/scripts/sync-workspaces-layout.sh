#!/usr/bin/env bash

set -eu

waybar_dir="${HOME}/.config/waybar"
target_file="${waybar_dir}/generated/workspaces.dynamic.jsonc"
single_file="${waybar_dir}/generated/workspaces.single.jsonc"
dual_file="${waybar_dir}/generated/workspaces.dual.jsonc"

print_empty() {
    printf '{"text":""}\n'
}

if ! command -v hyprctl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    print_empty
    exit 0
fi

if ! monitors_json="$(hyprctl -j monitors 2>/dev/null)"; then
    print_empty
    exit 0
fi

monitor_names="$(
    printf '%s' "${monitors_json}" | jq -r '
        map(select(.disabled != true and .dpmsStatus != false) | .name)
        | sort
        | .[]
    ' 2>/dev/null
)"

if [ -z "${monitor_names}" ]; then
    print_empty
    exit 0
fi

selected_file="${single_file}"
monitor_count="$(printf '%s\n' "${monitor_names}" | grep -c .)"
if [ "${monitor_count}" -ge 2 ]; then
    selected_file="${dual_file}"
fi

if [ -f "${selected_file}" ] && ! cmp -s "${selected_file}" "${target_file}" 2>/dev/null; then
    cp "${selected_file}" "${target_file}"
    # KHÔNG SIGUSR2 (crash waybar 0.15, xem launch.sh) — restart qua launch.sh
    "${waybar_dir}/scripts/launch.sh" >/dev/null 2>&1 || true
fi

# ── Rebind ws 6-10 theo monitor hiện diện ─────────────────────────────────────
# Mặc định (workspacerules.lua/.conf) 6-10 bind cứng vào màn ngoài. Khi rút màn
# ngoài, Hyprland KHÔNG persistent chúng (monitor gán biến mất) → 6-10 sinh/hủy
# theo occupancy trong khi waybar ép persistent [1..10] → giằng co = "khoảng tắt".
# Sửa: đơn màn → bind 6-10 sang màn đang có + persistent thật; đa màn → trả về
# màn ngoài (ws8 = default cụm ngoài, khớp workspacerules). eDP-1 là tên màn
# trong (máy-cụ-thể). Idempotent, chạy mỗi lần sync.
#
# Config provider lua (Hyprland ≥0.55): `hyprctl keyword` bị từ chối
# ("keyword can't work with non-legacy parsers") → dùng `hyprctl eval` với
# hl.workspace_rule. Giữ keyword làm FALLBACK cho trường hợp rollback về
# hyprland.conf (eval chỉ chạy với provider lua, keyword chỉ với legacy —
# đúng một trong hai sẽ thành công).
# def: "default" -> default=true | "nodefault" -> default=false (GHI ĐÈ tường minh)
# BẪY: hl.workspace_rule MERGE chứ không REPLACE. Bỏ trống `default` KHÔNG xoá
# được default=true mà workspacerules.lua đã đặt cho ws8 -> ở đơn màn ws8 bị kéo
# về eDP-1 mà VẪN giữ default=true, thành 2 workspace cùng default trên một màn.
# Phải set default=false tường minh mới thắng được merge.
rebind_ws() {
    ws="$1"; mon="$2"; def="${3:-}"
    lua_extra=""; kw_extra=""
    if [ "${def}" = "default" ]; then
        lua_extra=", default = true"
        kw_extra=",default:true"
    elif [ "${def}" = "nodefault" ]; then
        lua_extra=", default = false"
        kw_extra=",default:false"
    fi
    hyprctl eval "hl.workspace_rule({ workspace = \"${ws}\", monitor = \"${mon}\", persistent = true${lua_extra} })" >/dev/null 2>&1 \
        || hyprctl keyword workspace "${ws},monitor:${mon},persistent:true${kw_extra}" >/dev/null 2>&1 \
        || true
}

internal="eDP-1"
if command -v hyprctl >/dev/null 2>&1; then
    if [ "${monitor_count}" -ge 2 ]; then
        external="$(printf '%s\n' "${monitor_names}" | grep -vx "${internal}" | head -n1)"
        home_mon="${external:-${internal}}"
        for ws in 6 7 9 10; do
            rebind_ws "${ws}" "${home_mon}"
        done
        rebind_ws 8 "${home_mon}" default
    else
        home_mon="$(printf '%s\n' "${monitor_names}" | head -n1)"
        # ws8 phải TẮT default tường minh ở đơn màn — ws3 mới là default của eDP-1.
        for ws in 6 7 9 10; do
            rebind_ws "${ws}" "${home_mon}"
        done
        rebind_ws 8 "${home_mon}" nodefault
    fi
fi

print_empty
