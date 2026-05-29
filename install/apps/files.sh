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
    yay -S --noconfirm --needed "$pkg"
done

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    if ! yay -S --noconfirm --needed "$pkg"; then
        echo "$pkg install failed. Retrying with a clean AUR build..."
        if ! yay -S --noconfirm --needed --answerclean All "$pkg"; then
            echo "WARNING: $pkg failed to install and needs manual intervention. Continuing."
        fi
    fi
done
