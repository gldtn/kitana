#!/bin/bash

echo "Installing editor apps..."

PACKAGES=(
  neovim
  zed
)

if kitana_is_edge; then
  kitana_install_with_fallback "apps/editors" "neovim-git" "neovim" || exit 1
  kitana_install_required "apps/editors" "zed" || exit 1
else
  for pkg in "${PACKAGES[@]}"; do
    kitana_install_required "apps/editors" "$pkg" || exit 1
  done
fi
