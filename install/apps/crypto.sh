#!/bin/bash

echo "Installing crypto wallets apps..."

PACKAGES=(
  blockstream-app-appimage
  ledger-live-bin
  sparrow-wallet
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
