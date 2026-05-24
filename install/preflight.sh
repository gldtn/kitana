#!/bin/bash

# preflight.sh: System preparation and AUR helper

echo "Running preflight checks and setup..."

# Update system
sudo pacman -Syu --noconfirm

# Package list
PACKAGES=(
    base-devel
    git
    gum
)

# Install packages
for pkg in "${PACKAGES[@]}"; do
    sudo pacman -S --noconfirm --needed "$pkg"
done

# Install yay if not present
if ! command -v yay &> /dev/null; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi
