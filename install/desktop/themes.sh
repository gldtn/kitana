#!/bin/bash

echo "Installing theme and toolkit packages..."

PACKAGES=(
  adw-gtk-theme
  graphite-gtk-theme-git
  gtk-engine-murrine
  gtk3
  gtk4
  kvantum
  kvantum-gt5
  materia-gtk-theme
  matugen-bin
  nwg-look
  qt5-wayland
  qt6-declarative
  qt6-quickcontrols2
  qt6-svg
  qt6-wayland
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
