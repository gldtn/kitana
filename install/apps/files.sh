#!/bin/bash

echo "Installing file-manager and integration apps..."

PACKAGES=(
  ffmpegthumbnailer
  libappindicator
  nautilus
  nautilus-image-converter
  python-gpgme
  sushi
)

kitana_install_required_packages "apps/files" "${PACKAGES[@]}" || exit 1
