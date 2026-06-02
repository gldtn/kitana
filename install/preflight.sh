#!/bin/bash

# preflight.sh: System preparation and AUR helper

echo "Running preflight checks and setup..."

# Update system
if sudo pacman -Syu --noconfirm; then
    :
else
    exit_code=$?
    kitana_log_failure "preflight" "system-update" "sudo pacman -Syu --noconfirm" "$exit_code" "sudo pacman -Syu"
    exit "$exit_code"
fi

# Package list
PACKAGES=(
    base-devel
    git
    gum
)

# Install packages
for pkg in "${PACKAGES[@]}"; do
    if sudo pacman -S --noconfirm --needed "$pkg"; then
        :
    else
        exit_code=$?
        kitana_log_failure "preflight" "$pkg" "sudo pacman -S --noconfirm --needed $pkg" "$exit_code" "sudo pacman -S $pkg"
        exit "$exit_code"
    fi
done

# Install yay if not present
if ! command -v yay &> /dev/null; then
    echo "Installing yay..."
    yay_build_dir="$(mktemp -d)"

    if git clone https://aur.archlinux.org/yay.git "$yay_build_dir"; then
        :
    else
        exit_code=$?
        kitana_log_failure "preflight" "yay-clone" "git clone https://aur.archlinux.org/yay.git" "$exit_code" "git clone https://aur.archlinux.org/yay.git /tmp/yay"
        rm -rf "$yay_build_dir"
        exit "$exit_code"
    fi

    if makepkg -si --noconfirm -D "$yay_build_dir"; then
        :
    else
        exit_code=$?
        kitana_log_failure "preflight" "yay" "makepkg -si --noconfirm -D $yay_build_dir" "$exit_code" "git clone https://aur.archlinux.org/yay.git /tmp/yay; cd /tmp/yay; makepkg -si"
        rm -rf "$yay_build_dir"
        exit "$exit_code"
    fi

    rm -rf "$yay_build_dir"
fi
