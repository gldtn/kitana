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

OPTIONAL_PACKAGES=(
    dropbox
    dropbox-cli
    nautilus-dropbox
)

for pkg in "${PACKAGES[@]}"; do
    kitana_install_required "apps/files" "$pkg" || exit 1
done

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    kitana_install_optional "apps/files" "$pkg"
done
