#!/bin/bash

echo "Installing file-manager and integration apps..."

PACKAGES=(
    dropbox
    dropbox-cli
    ffmpegthumbnailer
    libappindicator-gtk3
    nautilus
    nautilus-dropbox
    nautilus-image-converter
    python-gpgme
    sushi
)

for pkg in "${PACKAGES[@]}"; do
    yay -S --noconfirm --needed "$pkg"
done
