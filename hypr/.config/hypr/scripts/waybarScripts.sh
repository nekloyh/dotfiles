#!/usr/bin/env bash
# Right-click handlers for waybar CPU/MEM/NET modules.
# No external config dependency — programs are hardcoded to match programs.conf.

term="alacritty"

case "$1" in
    --btop)
        $term --title btop -e btop
        ;;
    --nvtop)
        $term --title nvtop -e nvtop
        ;;
    --nmtui)
        $term --title nmtui -e nmtui
        ;;
    *)
        cat <<EOF
Usage: $0 [--btop|--nvtop|--nmtui]
  --btop    : Open btop in a new terminal
  --nvtop   : Open nvtop in a new terminal
  --nmtui   : Open nmtui in a new terminal
EOF
        ;;
esac
