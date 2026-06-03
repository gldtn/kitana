#!/bin/bash

set -e

export KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
export KITANA_INSTALL="${KITANA_INSTALL:-$KITANA_DIR/install}"

# shellcheck source=install/lib/install.sh
source "$KITANA_INSTALL/lib/install.sh"
kitana_init_paths
kitana_init_install_log

source_script "apps/ai.sh"
source_script "apps/communication.sh"
source_script "apps/editors.sh"
source_script "apps/nvim-config.sh"
source_script "apps/essentials.sh"
source_script "apps/productivity.sh"
source_script "apps/media.sh"
source_script "apps/files.sh"
source_script "apps/managers.sh"

echo "Let's install your preferred browser..."
kitana-install-browser --apply-mime

kitana-git-config --ensure

source_script "apps/crypto.sh"
source_script "apps/webapps.sh"

kitana_print_install_summary
