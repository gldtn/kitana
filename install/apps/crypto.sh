#!/bin/bash

echo "Installing crypto wallets apps..."

PACKAGES=(
  blockstream-app-appimage
  ledger-live-bin
  sparrow-wallet
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_optional "apps/crypto" "$pkg"
done
