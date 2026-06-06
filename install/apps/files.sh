#!/bin/bash

echo "Installing file-manager and integration apps..."

PACKAGES=(
  ffmpegthumbnailer
  gvfs-mtp
  libappindicator
  nautilus
  nautilus-image-converter
  nautilus-python
  python-gpgme
  sushi
)

kitana_install_required_packages "apps/files" "${PACKAGES[@]}" || exit 1

NAUTILUS_EXTENSIONS_DIR="$HOME/.local/share/nautilus-python/extensions"
LOCALSEND_EXTENSION="$NAUTILUS_EXTENSIONS_DIR/localsend.py"
LOCALSEND_EXTENSION_MARKER="Kitana managed LocalSend Nautilus extension"

mkdir -p "$NAUTILUS_EXTENSIONS_DIR"

if [ ! -e "$LOCALSEND_EXTENSION" ] || grep -q "$LOCALSEND_EXTENSION_MARKER" "$LOCALSEND_EXTENSION"; then
  cp "$KITANA_DIR/default/nautilus-python/extensions/localsend.py" "$LOCALSEND_EXTENSION"
else
  echo "Keeping existing Nautilus LocalSend extension: $LOCALSEND_EXTENSION"
fi
