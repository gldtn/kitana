#!/bin/bash

echo "Installing theme and toolkit packages..."

PACKAGES=(
  adw-gtk-theme
  gnome-themes-extra
  gtk-engine-murrine
  gtk3
  gtk4
  kvantum
  kvantum-gt5
  materia-gtk-theme
  matugen-bin
  nwg-look
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

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

git clone --depth 1 https://github.com/vinceliuice/Graphite-gtk-theme.git "$tmpdir/Graphite-gtk-theme"

(
  cd "$tmpdir/Graphite-gtk-theme"
  ./install.sh --theme default --tweaks black rimless --size compact
)
