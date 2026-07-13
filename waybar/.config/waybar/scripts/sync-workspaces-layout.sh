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

print_empty
