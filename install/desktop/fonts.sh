#!/bin/bash

echo "Installing fonts..."

PACKAGES=(
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  noto-fonts-extra
  otf-font-awesome
  ttf-cascadia-mono-nerd
  ttf-jetbrains-mono-nerd
  ttf-material-symbols-variable-git
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_required "desktop/fonts" "$pkg" || exit 1
done
