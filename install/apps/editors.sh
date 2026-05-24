#!/bin/bash

echo "Installing editor apps..."

PACKAGES=(
  neovim
  zed
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
