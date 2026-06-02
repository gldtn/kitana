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
  kitana_install_required "desktop/hyprland" "$pkg" || exit 1
done

sudo mkdir -p /usr/share/wayland-sessions
sudo tee /usr/share/wayland-sessions/kitana-hyprland.desktop >/dev/null <<EOF
[Desktop Entry]
Name=Kitana Hyprland
Comment=Start Hyprland with the Hyprland wrapper
Exec=/usr/bin/start-hyprland
Type=Application
DesktopNames=Hyprland
EOF
