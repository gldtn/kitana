#!/bin/bash

echo "Installing connectivity and system managers..."

PACKAGES=(
  btop
  wiremix
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_required "apps/managers" "$pkg" || exit 1
done
