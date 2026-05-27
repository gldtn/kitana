#!/bin/bash

# Dependencies: jq (install via pacman -S jq on Arch)

floating=$(hyprctl activewindow -j | jq -r '.floating')

if [ "$floating" = "false" ]; then
    # Toggle to floating, resize to exact size, center
    hyprctl dispatch 'hl.dsp.window.float({ action = "set" })'
    hyprctl dispatch 'hl.dsp.window.resize({ x = 2048, y = 1080 })'
    hyprctl dispatch 'hl.dsp.window.center()'
else
    # Toggle back to tiled (no resize needed; tiling adjusts automatically)
    hyprctl dispatch 'hl.dsp.window.float({ action = "unset" })'
fi
