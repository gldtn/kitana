#!/bin/bash

echo "Installing file-manager and integration apps..."

PACKAGES=(
    ffmpegthumbnailer
    libappindicator-gtk3
    nautilus
    nautilus-image-converter
    python-gpgme
    sushi
)

for pkg in "${PACKAGES[@]}"; do
    kitana_install_required "apps/files" "$pkg" || exit 1
done
