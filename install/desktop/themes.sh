#!/bin/bash

echo "Installing theme and toolkit packages..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"

PACKAGES=(
  adw-gtk-theme
  gnome-themes-extra
  gtk3
  gtk4
  kvantum
  kvantum-qt5
  qt5-wayland
  qt6ct
  qt6-declarative
  qt6-svg
  qt6-wayland
)

OPTIONAL_PACKAGES=(
  matugen-bin
)

kitana_install_required_packages "desktop/themes" "${PACKAGES[@]}" || exit 1

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
  kitana_install_optional "desktop/themes" "$pkg"
done

"$KITANA_DIR/install/desktop/gtk-theme-icons.sh"
