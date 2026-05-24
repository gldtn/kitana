#!/bin/bash

echo "Installing connectivity and system managers..."

PACKAGES=(
  btop
  bluetui
  impala
  wiremix
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
