#!/bin/bash

echo "Installing theme and toolkit packages..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"

PACKAGES=(
  adw-gtk-theme
  gnome-themes-extra
  gtk3
  gtk4
  kvantum
  kvantum-gt5
  materia-gtk-theme
  qt5-wayland
  qt6ct
  qt6-declarative
  qt6-quickcontrols2
  qt6-svg
  qt6-wayland
)

OPTIONAL_PACKAGES=(
  matugen-bin
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_required "desktop/themes" "$pkg" || exit 1
done

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
  kitana_install_optional "desktop/themes" "$pkg"
done

"$KITANA_DIR/install/desktop/gtk-theme-icons.sh"
