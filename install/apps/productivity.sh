#!/bin/bash

echo "Installing productivity apps..."

PACKAGES=(
  1password-beta
  1password-cli
  calcure
  ledger-live-desktop
  localsend-bin
  onlyoffice-bin
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
