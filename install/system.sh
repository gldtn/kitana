#!/bin/bash

# system.sh: Core system and hardware packages

echo "Installing system packages..."

PACKAGES=(
    libnewt
    linux-headers
    mesa
    pipewire
    pipewire-alsa
    pipewire-jack
    pipewire-pulse
    vulkan-radeon
    wayland
    wireplumber
    xf86-video-amdgpu
)

# Install packages
for pkg in "${PACKAGES[@]}"; do
    kitana_install_required "system" "$pkg" || exit 1
done
