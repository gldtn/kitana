#!/bin/bash

echo "Installing communication apps..."

PACKAGES=(
  vesktop-bin
  zoom
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
