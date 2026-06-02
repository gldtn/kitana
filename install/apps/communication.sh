#!/bin/bash

echo "Installing communication apps..."

REQUIRED_PACKAGES=(
  vesktop-bin
)

for pkg in "${REQUIRED_PACKAGES[@]}"; do
  kitana_install_optional "apps/communication" "$pkg"
done
