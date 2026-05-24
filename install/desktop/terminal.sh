#!/bin/bash

echo "Installing terminal packages..."

PACKAGES=(
  ghostty-nightly-bin
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
