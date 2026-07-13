#!/usr/bin/env bash
# Waybar VPN module — ProtonVPN via WireGuard.
#
# Usage:
#   vpn.sh status   # JSON for waybar (default)
#   vpn.sh toggle   # connect (selected server) or disconnect
#   vpn.sh switch   # internal: switch to a specific server (arg2: sg|us)
#   vpn.sh picker   # walker --dmenu menu to pick server / disconnect
#
# Reads /etc/wireguard/proton-<server>.conf via wg-quick.
# Requires sudoers rule: NOPASSWD for /usr/bin/wg-quick {up,down} on those configs
# and /usr/bin/wg show interfaces.

set -euo pipefail

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-vpn-server"
WAYBAR_SIGNAL=8
ICON="󰖂"

mkdir -p "$(dirname "$STATE_FILE")"
[[ -s "$STATE_FILE" ]] || echo "sg" >"$STATE_FILE"
selected=$(<"$STATE_FILE")

case "$selected" in
    sg|us) ;;
    *) selected="sg"; echo "$selected" >"$STATE_FILE" ;;
esac

active_iface() {
    # Không cần root: interface WireGuard đang up = có thư mục trong /sys/class/net.
    # (sudo -n wg show mỗi tick dựng cả PAM stack + ~3 dòng journal → bỏ khỏi hot path.)
    local i
    for i in proton-sg proton-us; do
        if [[ -d "/sys/class/net/$i" ]]; then printf '%s' "$i"; return 0; fi
    done
    return 0
}

server_label() {
    case "$1" in
        sg) printf 'Singapore' ;;
        us) printf 'United States' ;;
        *)  printf '%s' "$1" ;;
    esac
}

reload_waybar() {
    pkill -RTMIN+"$WAYBAR_SIGNAL" -x waybar 2>/dev/null || true
}

vpn_up() {
    sudo -n wg-quick up "/etc/wireguard/proton-$1.conf" >/dev/null 2>&1
}

vpn_down() {
    sudo -n wg-quick down "/etc/wireguard/proton-$1.conf" >/dev/null 2>&1
}

set_selected() {
    selected="$1"
    echo "$selected" >"$STATE_FILE"
}

cmd_status() {
    local iface current label tooltip
    iface=$(active_iface)
    if [[ -n "$iface" ]]; then
        current="${iface#proton-}"
        label=$(server_label "$current")
        tooltip="VPN: ON — ${label}\nClick: tắt VPN\nRight click: chọn server"
        printf '{"text":"%s","tooltip":"%s","class":"on","alt":"on"}\n' "$ICON" "$tooltip"
    else
        label=$(server_label "$selected")
        tooltip="VPN: OFF\nServer đã chọn: ${label}\nClick: bật VPN\nRight click: chọn server"
        printf '{"text":"%s","tooltip":"%s","class":"off","alt":"off"}\n' "$ICON" "$tooltip"
    fi
}

cmd_toggle() {
    local iface
    iface=$(active_iface)
    if [[ -n "$iface" ]]; then
        vpn_down "${iface#proton-}"
    else
        vpn_up "$selected"
    fi
    reload_waybar
}

# Switch to a specific server. If currently up on a different one, swap.
# If currently up on the same one, no-op. If down, just remember selection.
cmd_switch() {
    local target="${1:-}"
    case "$target" in
        sg|us) ;;
        *) echo "switch needs sg|us" >&2; exit 2 ;;
    esac
    local iface current
    iface=$(active_iface)
    set_selected "$target"
    if [[ -n "$iface" ]]; then
        current="${iface#proton-}"
        if [[ "$current" != "$target" ]]; then
            vpn_down "$current"
            vpn_up "$target"
        fi
    fi
    reload_waybar
}

cmd_disconnect() {
    local iface
    iface=$(active_iface)
    [[ -n "$iface" ]] && vpn_down "${iface#proton-}"
    reload_waybar
}

cmd_picker() {
    local iface current connected_marker_sg="" connected_marker_us=""
    iface=$(active_iface)
    if [[ -n "$iface" ]]; then
        current="${iface#proton-}"
        case "$current" in
            sg) connected_marker_sg="  ●" ;;
            us) connected_marker_us="  ●" ;;
        esac
    fi

    local menu choice
    menu=$(printf '%s\n' \
        "Singapore${connected_marker_sg}" \
        "United States${connected_marker_us}" \
        "Tắt VPN")

    choice=$(printf '%s' "$menu" | walker --dmenu --placeholder "ProtonVPN — chọn server" --width 360 --height 240 || true)

    case "$choice" in
        Singapore*)      cmd_switch sg ;;
        "United States"*) cmd_switch us ;;
        "Tắt VPN")       cmd_disconnect ;;
        "")              : ;;  # cancelled
        *)               : ;;
    esac
}

case "${1:-status}" in
    status)     cmd_status ;;
    toggle)     cmd_toggle ;;
    switch)     shift; cmd_switch "${1:-}" ;;
    disconnect) cmd_disconnect ;;
    picker)     cmd_picker ;;
    *) echo "usage: $0 {status|toggle|switch sg|us|disconnect|picker}" >&2; exit 2 ;;
esac
