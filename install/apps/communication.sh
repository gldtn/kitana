#!/bin/bash

echo "Installing communication apps..."

REQUIRED_PACKAGES=(
  vesktop-bin
)

for pkg in "${REQUIRED_PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
