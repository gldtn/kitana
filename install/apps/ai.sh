#!/bin/bash

echo "Installing AI apps..."

PACKAGES=(
  opencode-desktop-bin
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_optional "apps/ai" "$pkg"
done
