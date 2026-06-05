#!/bin/bash

echo "Installing base system packages..."

PACKAGES=(
  dmidecode
  fwupd
  libnewt
  linux-firmware
  linux-headers
  mesa
  pciutils
  sof-firmware
  wayland
)

while IFS= read -r pkg; do
  [ -n "$pkg" ] || continue
  PACKAGES+=("$pkg")
done < <("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-hw-cpu" --packages)

kitana_install_required_packages "system/base" "${PACKAGES[@]}" || exit 1

sudo systemctl enable --now fwupd-refresh.timer || true
