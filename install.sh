#!/bin/bash

# Kitana main install script
# Sources modular scripts in order.

# Exit immediately if a command exits with a non-zero status
set -e

# Give people a chance to retry running the installation
trap 'echo "Kitana installation failed! You can retry by running: bash ~/.local/share/kitana/install.sh"' ERR

# Define base path
KITANA_DIR="$HOME/.local/share/kitana"

# Function to source a script
source_script() {
  local script="$1"
  if [ -f "$KITANA_DIR/install/$script" ]; then
    echo "Sourcing $script..."
    source "$KITANA_DIR/install/$script" || {
      echo "Error in $script"
      exit 1
    }
  else
    echo "$script not found; skipping."
  fi
}

# Add some visual flair to pacman
sudo sed -i '/^\[options\]/a ILoveCandy' /etc/pacman.conf

# Install everything in order
source_script "preflight.sh"
source_script "system.sh"

bash "$KITANA_DIR/install-desktop.sh"
bash "$KITANA_DIR/install-apps.sh"

# Ensure locate is up to date now that everything has been installed
sudo updatedb

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
