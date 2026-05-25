#!/bin/bash

echo "Installing AI apps..."

PACKAGES=(
  opencode-desktop
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
