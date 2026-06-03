#!/bin/bash

echo "Installing media apps..."

PACKAGES=(
  cava
  imv
  mpv
  obs-studio
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_optional "apps/media" "$pkg"
done
