#!/bin/bash

echo "Installing authentication device support..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
KITANA_INSTALL="${KITANA_INSTALL:-$KITANA_DIR/install}"

if ! declare -F kitana_install_required_packages >/dev/null 2>&1; then
  # shellcheck source=../lib/install.sh
  source "$KITANA_INSTALL/lib/install.sh"
  kitana_init_paths
  kitana_init_install_log
fi

PACKAGES=(
  ccid
  libfido2
  pcsclite
  pcsc-tools
  yubikey-manager
)

kitana_install_required_packages "system/auth-devices" "${PACKAGES[@]}" || exit 1

sudo systemctl enable --now pcscd.socket || true
