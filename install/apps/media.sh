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
  kitana_install_optional "apps/media" "$pkg"
done
