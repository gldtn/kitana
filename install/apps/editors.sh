#!/bin/bash

echo "Installing editor apps..."

PACKAGES=(
  neovim
  zed
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_required "apps/editors" "$pkg" || exit 1
done
