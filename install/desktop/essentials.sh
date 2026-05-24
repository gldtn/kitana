#!/bin/bash

echo "Installing DE essentials packages..."

PACKAGES=(
  bluez
  bluez-utils
  brightnessctl
  ddcutil
  inetutils
  iwd
  pixie-sddm-git
  quickshell
  sddm
  swaync
  vicinae-bin
  xdg-desktop-portal-gtk
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done

sudo systemctl enable --now iwd.service bluetooth.service
sudo systemctl enable --now sddm.service

sudo mkdir -p /etc/systemd/system/systemd-networkd-wait-online.service.d
sudo tee /etc/systemd/system/systemd-networkd-wait-online.service.d/wait-for-only-one-interface.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --any
EOF
