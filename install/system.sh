#!/bin/bash

# system.sh: Core system and hardware packages

echo "Installing system packages..."

PACKAGES=(
  libnewt
  linux-headers
  mesa
  pciutils
  pipewire
  pipewire-alsa
  pipewire-jack
  pipewire-pulse
  wayland
  wireplumber
)

while IFS= read -r pkg; do
  [ -n "$pkg" ] || continue
  PACKAGES+=("$pkg")
done < <("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-hw-gpu" --packages)

deduped_packages=()
for pkg in "${PACKAGES[@]}"; do
  for existing in "${deduped_packages[@]}"; do
    [ "$existing" = "$pkg" ] && continue 2
  done
  deduped_packages+=("$pkg")
done
PACKAGES=("${deduped_packages[@]}")

# Install packages
for pkg in "${PACKAGES[@]}"; do
  kitana_install_required "system" "$pkg" || exit 1
done
