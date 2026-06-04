#!/bin/bash

echo "Installing GPU system packages..."

PACKAGES=()

while IFS= read -r pkg; do
  [ -n "$pkg" ] || continue
  PACKAGES+=("$pkg")
done < <("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-hw-gpu" --packages)

kitana_install_required_packages "system/gpu" "${PACKAGES[@]}" || exit 1
