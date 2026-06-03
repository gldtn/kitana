#!/bin/bash

echo "Installing terminal packages..."

PACKAGES=(
  ghostty
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_required "desktop/terminal" "$pkg" || exit 1
done
