#!/bin/bash

echo "Installing editor apps..."

PACKAGES=(
  neovim-git
  zed
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
