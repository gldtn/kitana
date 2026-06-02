#!/bin/bash

echo "Installing productivity apps..."

PACKAGES=(
  1password-beta
  1password-cli
  calcure
  localsend-bin
  onlyoffice-bin
)

for pkg in "${PACKAGES[@]}"; do
  kitana_install_optional "apps/productivity" "$pkg"
done
