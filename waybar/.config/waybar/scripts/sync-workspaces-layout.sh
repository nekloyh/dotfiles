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
    pkill -SIGUSR2 -x waybar 2>/dev/null || true
fi

# ── Rebind ws 6-10 theo monitor hiện diện ─────────────────────────────────────
# Mặc định (workspacerules.conf) 6-10 bind cứng vào màn ngoài. Khi rút màn ngoài,
# Hyprland KHÔNG persistent chúng (monitor gán biến mất) → 6-10 sinh/hủy theo
# occupancy trong khi waybar ép persistent [1..10] → giằng co = "khoảng tắt".
# Sửa: đơn màn → bind 6-10 sang màn đang có + persistent thật; đa màn → trả về
# màn ngoài (ws8 = default cụm ngoài, khớp workspacerules.conf). eDP-1 là tên màn
# trong (máy-cụ-thể). Idempotent, chạy mỗi lần sync.
internal="eDP-1"
if command -v hyprctl >/dev/null 2>&1; then
    if [ "${monitor_count}" -ge 2 ]; then
        external="$(printf '%s\n' "${monitor_names}" | grep -vx "${internal}" | head -n1)"
        home_mon="${external:-${internal}}"
        for ws in 6 7 9 10; do
            hyprctl keyword workspace "${ws},monitor:${home_mon},persistent:true" >/dev/null 2>&1 || true
        done
        hyprctl keyword workspace "8,monitor:${home_mon},persistent:true,default:true" >/dev/null 2>&1 || true
    else
        home_mon="$(printf '%s\n' "${monitor_names}" | head -n1)"
        # KHÔNG set default cho ws8 ở đơn màn — tránh đụng ws3 (default của eDP-1).
        for ws in 6 7 8 9 10; do
            hyprctl keyword workspace "${ws},monitor:${home_mon},persistent:true" >/dev/null 2>&1 || true
        done
    fi
fi

print_empty
