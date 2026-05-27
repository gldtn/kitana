#!/bin/bash

echo "Configuring bootloader theme..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
LIMINE_THEME="$KITANA_DIR/default/limine/catppuccin-mocha.conf"
LIMINE_CONFIG="${LIMINE_CONFIG:-}"

finish() {
  return "$1" 2>/dev/null || exit "$1"
}

if [ -z "$LIMINE_CONFIG" ]; then
  for candidate in /boot/limine.conf /boot/efi/limine.conf /efi/limine.conf; do
    if [ -f "$candidate" ]; then
      LIMINE_CONFIG="$candidate"
      break
    fi
  done
fi

if [ -z "$LIMINE_CONFIG" ]; then
  echo "Limine config not found; skipping Limine theme."
  finish 0
fi

if [ ! -f "$LIMINE_THEME" ]; then
  echo "Limine theme missing: $LIMINE_THEME"
  finish 1
fi

stripped="$(mktemp)"
themed="$(mktemp)"

awk '
  /^# Kitana managed Limine theme start$/ { skip = 1; next }
  /^# Kitana managed Limine theme end$/ { skip = 0; next }
  skip { next }
  /^interface_branding:/ { next }
  { print }
' "$LIMINE_CONFIG" >"$stripped"

{
  cat "$LIMINE_THEME"
  printf '\n'
  cat "$stripped"
} >"$themed"

backup="$LIMINE_CONFIG.bak.$(date +%s)"
echo "Backing up Limine config to $backup"
sudo cp "$LIMINE_CONFIG" "$backup"
sudo cp "$themed" "$LIMINE_CONFIG"
rm -f "$stripped" "$themed"
