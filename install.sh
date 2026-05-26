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
source_script "desktop/development.sh"
source_script "desktop/terminal.sh"
source_script "desktop/cli.sh"
source_script "desktop/hardening.sh"
source_script "desktop/hyprland.sh"
source_script "desktop/fonts.sh"
source_script "desktop/themes.sh"
source_script "desktop/essentials.sh"
source_script "desktop/configs.sh"
source_script "apps/ai.sh"
source_script "apps/communication.sh"
source_script "apps/crypto.sh"
source_script "apps/editors.sh"
source_script "apps/essentials.sh"
source_script "apps/productivity.sh"
source_script "apps/media.sh"
source_script "apps/files.sh"
source_script "apps/managers.sh"

echo "Let's install your preferred browser..."
sleep 2
bash "$KITANA_DIR/bin/install-browser"

source_script "apps/mimetypes.sh"
source_script "apps/webapps.sh"

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
