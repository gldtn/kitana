#!/bin/bash

set -e

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"

# shellcheck source=install/lib/install.sh
source "$KITANA_DIR/install/lib/install.sh"
kitana_init_install_log

source_script() {
  local script="$1"
  if [ -f "$KITANA_DIR/install/$script" ]; then
    echo "Sourcing $script..."
    source "$KITANA_DIR/install/$script"
  else
    echo "$script not found; skipping."
  fi
}

source_script "desktop/development.sh"
source_script "desktop/terminal.sh"
source_script "desktop/cli.sh"
source_script "desktop/hardening.sh"
source_script "desktop/hyprland.sh"
source_script "desktop/configs.sh"
source_script "desktop/wallpapers-extras.sh"
source_script "desktop/fonts.sh"
source_script "desktop/themes.sh"
source_script "desktop/essentials.sh"
source_script "desktop/bootloader.sh"

kitana_print_install_summary
