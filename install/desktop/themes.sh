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
  pixie-sddm-git
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_required "desktop/themes" "$pkg" || exit 1
done

for pkg in "${OPTIONAL_PACKAGES[@]}"; do
  kitana_install_optional "desktop/themes" "$pkg"
done

sudo mkdir -p /etc/kitana /etc/sddm.conf.d
sudo cp "$KITANA_DIR/default/sddm/hyprland.conf" /etc/kitana/sddm-hyprland.conf

if [ -d /usr/share/sddm/themes/pixie ]; then
  sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null <<EOF
[Theme]
Current=pixie
EOF
else
  echo "Pixie SDDM theme is not installed; leaving SDDM theme default."
  if [ -f /etc/sddm.conf.d/10-theme.conf ] && grep -q '^Current=pixie$' /etc/sddm.conf.d/10-theme.conf; then
    sudo rm -f /etc/sddm.conf.d/10-theme.conf
  fi
fi

sudo tee /etc/sddm.conf.d/20-hyprland.conf >/dev/null <<EOF
[General]
DisplayServer=wayland

[Wayland]
CompositorCommand=start-hyprland -- --config /etc/kitana/sddm-hyprland.conf
EOF

"$KITANA_DIR/install/desktop/gtk-theme-icons.sh"
