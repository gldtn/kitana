#!/bin/bash

echo "Installing AI apps..."

PACKAGES=(
  opencode-desktop-bin
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
