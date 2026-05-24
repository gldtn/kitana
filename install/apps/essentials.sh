#!/bin/bash

echo "Installing app essentials..."

PACKAGES=(
  gnome-calculator
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
