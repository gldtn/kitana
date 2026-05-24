#!/bin/bash

echo "Installing desktop config files..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana/}"

mkdir -p "$HOME/.config"

if [ -e "$HOME/.config/hypr" ] && [ ! -L "$HOME/.config/hypr" ]; then
  backup="$HOME/.config/hypr.bak.$(date +%s)"
  echo "Backing up existing Hypr config to $backup"
  mv "$HOME/.config/hypr" "$backup"
fi

ln -sfn "$KITANA_DIR/hypr" "$HOME/.config/hypr"
