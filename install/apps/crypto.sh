#!/bin/bash

echo "Installing crypto wallets apps..."

PACKAGES=(
  blockstream-app-appimage
  ledger-live-bin
  sparrow-wallet
)

for pkg in "${PACKAGES[@]}"; do
  if ! yay -S --noconfirm --needed "$pkg"; then
    echo "$pkg install failed. Retrying with a clean AUR build..."
    if ! yay -S --noconfirm --needed --answerclean All "$pkg"; then
      echo "WARNING: $pkg failed to install and needs manual intervention. Continuing."
    fi
  fi
done
