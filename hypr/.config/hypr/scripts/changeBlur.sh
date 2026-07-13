#!/usr/bin/env bash
# Toggle blur intensity (low ↔ normal) on the fly

iDIR="$HOME/.config/swaync/icons"

STATE=$(hyprctl -j getoption decoration:blur:passes | jq ".int")

if [ "${STATE}" == "2" ]; then
    hyprctl keyword decoration:blur:size 2
    hyprctl keyword decoration:blur:passes 1
    notify-send -e -u low -i "$iDIR/dropper.png" "Blur" "Less Blur (size 2 / 1 pass)"
else
    hyprctl keyword decoration:blur:size 5
    hyprctl keyword decoration:blur:passes 2
    notify-send -e -u low -i "$iDIR/dropper.png" "Blur" "Normal Blur (size 5 / 2 passes)"
fi
