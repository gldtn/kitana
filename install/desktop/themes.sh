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
  matugen-bin
  pixie-sddm-git
  qt5-wayland
  qt6ct
  qt6-declarative
  qt6-quickcontrols2
  qt6-svg
  qt6-wayland
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done

sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null <<EOF
[Theme]
Current=pixie
EOF

sudo tee /etc/sddm.conf.d/20-hyprland.conf >/dev/null <<EOF
[Wayland]
CompositorCommand=start-hyprland
EOF

"$KITANA_DIR/install/desktop/gtk-theme-icons.sh"
