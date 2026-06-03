#!/bin/bash

# Kitana main install script
# Sources modular scripts in order.

# Exit immediately if a command exits with a non-zero status
set -e

# Give people a chance to retry running the installation
trap 'echo "Kitana installation failed! You can retry by running: bash ~/.local/share/kitana/install.sh"' ERR

export KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
export KITANA_INSTALL="${KITANA_INSTALL:-$KITANA_DIR/install}"

# shellcheck source=install/lib/install.sh
source "$KITANA_INSTALL/lib/install.sh"
kitana_init_paths
kitana_init_install_log

# Add some visual flair to pacman
if ! grep -q '^ILoveCandy$' /etc/pacman.conf; then
  sudo sed -i '/^\[options\]/a ILoveCandy' /etc/pacman.conf
fi

# Install everything in order
source_script "preflight.sh"
source_script "preflight/sudoers.sh"
source_script "system.sh"

bash "$KITANA_DIR/install-desktop.sh"
bash "$KITANA_DIR/install-apps.sh"

# Ensure locate is up to date now that everything has been installed
sudo updatedb

kitana_print_install_summary

# Prompt for reboot
if command -v gum >/dev/null 2>&1; then
  if gum confirm "Reboot to apply all settings?"; then
    reboot
  fi
else
  read -p "Reboot to apply all settings? (y/n): " choice
  if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    reboot
  fi
fi
