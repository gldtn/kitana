#!/bin/bash

# system.sh: Core system and hardware packages

echo "Installing system packages..."

PACKAGES=(
    libnewt
    libva-mesa-driver
    linux-headers
    mesa
    mesa-vdpau
    pipewire
    pipewire-alsa
    pipewire-jack
    pipewire-pulse
    vulkan-radeon
    wayland
    wireplumber
    wlroots
    xf86-video-amdgpu
)

# Install packages
for pkg in "${PACKAGES[@]}"; do
    yay -S --noconfirm --needed "$pkg"
done
