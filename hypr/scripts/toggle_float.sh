#!/bin/bash

# Dependencies: jq (install via pacman -S jq on Arch)

floating=$(hyprctl activewindow -j | jq '.floating')

if [ "$floating" == "false" ]; then
    # Toggle to floating, resize to exact size, center
    hyprctl --batch "dispatch togglefloating ; dispatch resizeactive exact 2048 1080 ; dispatch centerwindow"
else
    # Toggle back to tiled (no resize needed; tiling adjusts automatically)
    hyprctl dispatch togglefloating
fi
