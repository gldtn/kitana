#!/bin/bash

echo "Installing terminal packages..."

PACKAGES=(
  ghostty
)

kitana_install_required_packages "desktop/terminal" "${PACKAGES[@]}" || exit 1
