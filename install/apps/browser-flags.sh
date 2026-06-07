#!/bin/bash

echo "Installing browser flags..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
BROWSER_FLAGS_SOURCE_DIR="$KITANA_DIR/config/browser-flags"
BROWSER_FLAGS_TARGET_DIR="$HOME/.config"
BROWSER_FLAGS_MARKER="Kitana managed browser flags"

install_browser_flags() {
  local source_file="$1"
  local target_file="$2"

  if [ ! -e "$target_file" ] || { [ -f "$target_file" ] && grep -q "$BROWSER_FLAGS_MARKER" "$target_file"; }; then
    cp "$source_file" "$target_file"
  else
    echo "Keeping existing browser flags: $target_file"
  fi
}

install_browser_flags_link() {
  local link_file="$1"
  local target_name="$2"

  if [ -L "$link_file" ]; then
    ln -sfn "$target_name" "$link_file"
  elif [ ! -e "$link_file" ]; then
    ln -s "$target_name" "$link_file"
  elif [ -f "$link_file" ] && grep -q "$BROWSER_FLAGS_MARKER" "$link_file"; then
    rm -f "$link_file"
    ln -s "$target_name" "$link_file"
  else
    echo "Keeping existing browser flags: $link_file"
  fi
}

mkdir -p "$BROWSER_FLAGS_TARGET_DIR"

install_browser_flags "$BROWSER_FLAGS_SOURCE_DIR/brave-flags.conf" "$BROWSER_FLAGS_TARGET_DIR/brave-flags.conf"
install_browser_flags "$BROWSER_FLAGS_SOURCE_DIR/chromium-flags.conf" "$BROWSER_FLAGS_TARGET_DIR/chromium-flags.conf"
install_browser_flags "$BROWSER_FLAGS_SOURCE_DIR/google-chrome-flags.conf" "$BROWSER_FLAGS_TARGET_DIR/google-chrome-flags.conf"
install_browser_flags_link "$BROWSER_FLAGS_TARGET_DIR/brave-origin-beta-flags.conf" "brave-flags.conf"
