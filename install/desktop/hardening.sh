#!/bin/bash

echo "Installing hardening packages..."

PACKAGES=(
  gnome-keyring
  seahorse
  ufw
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_required "desktop/hardening" "$pkg" || exit 1
done
