#!/bin/bash

set -e

export KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
export KITANA_INSTALL="${KITANA_INSTALL:-$KITANA_DIR/install}"

# shellcheck source=install/lib/install.sh
source "$KITANA_INSTALL/lib/install.sh"
kitana_init_paths
kitana_init_install_log

source_script "desktop/development.sh"
source_script "desktop/terminal.sh"
source_script "desktop/cli.sh"
source_script "desktop/hardening.sh"
source_script "desktop/hyprland.sh"
source_script "desktop/configs.sh"
source_script "desktop/fonts.sh"
source_script "desktop/themes.sh"
source_script "desktop/essentials.sh"
source_script "login/sddm.sh"
source_script "desktop/bootloader.sh"

kitana_print_install_summary
