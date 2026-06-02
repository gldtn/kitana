#!/bin/bash

echo "Installing app essentials..."

PACKAGES=(
  gnome-calculator
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_required "apps/essentials" "$pkg" || exit 1
done
