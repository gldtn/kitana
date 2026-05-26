#!/bin/bash

echo "Installing hyprland packages..."

PACKAGES=(
  grim
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
  hyprsunset
  hyprutils
  hyprwayland-scanner
  pamixer
  playerctl
  polkit
  satty
  slurp
  swww
  udiskie
  waybar
  wl-clip-persist
  wl-clipboard
  wl-screenrec
  xdg-desktop-portal-hyprland
  xdg-user-dirs
  xdg-utils
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
