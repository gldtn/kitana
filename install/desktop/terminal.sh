#!/bin/bash

echo "Installing terminal packages..."

PACKAGES=(
  ghostty
)

if kitana_is_edge; then
  kitana_install_with_fallback "desktop/terminal" "ghostty-nightly-bin" "ghostty" || exit 1
else
  for pkg in "${PACKAGES[@]}"; do
    kitana_install_required "desktop/terminal" "$pkg" || exit 1
  done
fi
