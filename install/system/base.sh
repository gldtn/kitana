#!/bin/bash

echo "Installing base system packages..."

PACKAGES=(
  libnewt
  linux-headers
  mesa
  pciutils
  wayland
)

kitana_install_required_packages "system/base" "${PACKAGES[@]}" || exit 1
