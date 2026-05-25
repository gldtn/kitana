#!/bin/bash

set -e

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana/}"

source_script() {
  local script="$1"
  if [ -f "$KITANA_DIR/install/$script" ]; then
    echo "Sourcing $script..."
    source "$KITANA_DIR/install/$script"
  else
    echo "$script not found; skipping."
  fi
}

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
bash "$KITANA_DIR/bin/install-browser"

source_script "apps/mimetypes.sh"
source_script "apps/webapps.sh"
