#!/bin/bash

echo "Installing crypto wallets apps..."

# shellcheck source=install/lib/extras.sh
source "${KITANA_DIR:-$HOME/.local/share/kitana}/install/lib/extras.sh"

if ! kitana_has_extra crypto; then
  echo "Skipping crypto wallet apps. Set KITANA_EXTRAS=crypto or KITANA_EXTRAS=all to install them."
  return 0 2>/dev/null || exit 0
fi

PACKAGES=(
  blockstream-app-appimage
  ledger-live-bin
  sparrow-wallet
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_optional "apps/crypto" "$pkg"
done
