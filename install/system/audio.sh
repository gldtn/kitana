#!/bin/bash

echo "Installing audio system packages..."

PACKAGES=(
  pipewire
  pipewire-alsa
  pipewire-jack
  pipewire-pulse
  wireplumber
)

kitana_install_required_packages "system/audio" "${PACKAGES[@]}" || exit 1
