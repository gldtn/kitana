#!/bin/bash

echo "Installing app essentials..."

PACKAGES=(
  gnome-calculator
)

kitana_install_required_packages "apps/essentials" "${PACKAGES[@]}" || exit 1
