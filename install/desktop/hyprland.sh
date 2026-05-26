#!/bin/bash

echo "Installing hyprland packages..."

PACKAGES=(
  hyprcursor
  hypridle
  hyprland
  hyprland-guiutils
  hyprland-qt-support
  hyprlang
  hyprlock
  hyprpaper
  hyprpicker
  hyprpolkitagent
  hyprqt6engine
  hyprshot
  hyprutils
  hyprwayland-scanner
  xdg-desktop-portal-hyprland
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
