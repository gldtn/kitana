#!/bin/bash

echo "Installing communication apps..."

REQUIRED_PACKAGES=(
  vesktop-bin
)

for pkg in "${REQUIRED_PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done

if ! yay -S --noconfirm --needed zoom; then
  echo "Zoom install failed. Retrying with a clean AUR build..."
  if ! yay -S --noconfirm --needed --answerclean All zoom; then
    echo "WARNING: Zoom failed to install and needs manual intervention. Continuing."
  fi
fi
