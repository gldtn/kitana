#!/bin/bash

echo "Installing hardening packages..."

PACKAGES=(
  gnome-keyring
  seahorse
  ufw
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
