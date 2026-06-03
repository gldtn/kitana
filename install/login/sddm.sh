#!/bin/bash

echo "Installing SDDM login manager..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"

kitana_install_required "login/sddm" "sddm" || exit 1

"$KITANA_DIR/bin/kitana-refresh-sddm"

sudo systemctl enable sddm.service

if [ "${KITANA_START_SDDM:-0}" = "1" ]; then
  sudo systemctl start sddm.service
else
  echo "SDDM enabled. Reboot after the installer finishes, or run KITANA_START_SDDM=1 to start it immediately."
fi
