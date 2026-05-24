#!/bin/bash

echo "Installing media apps..."

PACKAGES=(
  cava
  imv
  mpv
  obs-studio
  open-tv-bin
  youtube-music-desktop
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
