#!/bin/bash

# system.sh: Core system and hardware package stages.

set -e

export KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
export KITANA_INSTALL="${KITANA_INSTALL:-$KITANA_DIR/install}"

# shellcheck source=lib/install.sh
source "$KITANA_INSTALL/lib/install.sh"
kitana_init_paths
kitana_init_install_log

echo "Installing system packages..."

source_script "system/base.sh"
source_script "system/audio.sh"
source_script "system/gpu.sh"
source_script "system/auth-devices.sh"
