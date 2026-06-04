#!/bin/bash

echo "Installing hardening packages..."

PACKAGES=(
  gnome-keyring
  seahorse
  ufw
)

kitana_install_required_packages "desktop/hardening" "${PACKAGES[@]}" || exit 1
