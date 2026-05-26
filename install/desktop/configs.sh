#!/bin/bash

echo "Installing desktop config files..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
HYPR_CONFIG_DIR="$HOME/.config/hypr"
HYPR_ENTRYPOINT="$HYPR_CONFIG_DIR/hyprland.lua"
HYPR_ENTRYPOINT_MARKER="Kitana managed Hyprland Lua entrypoint"

install_kitana_entrypoint() {
  cat >"$HYPR_ENTRYPOINT" <<EOF
-- $HYPR_ENTRYPOINT_MARKER
-- Local overrides belong in ~/.config/hypr/modules/<module>.lua.

local home = os.getenv("HOME")
local kitana_dir = os.getenv("KITANA_DIR") or (home .. "/.local/share/kitana")

dofile(kitana_dir .. "/hypr/hyprland.lua")
EOF
}

mkdir -p "$HOME/.config"

if [ -L "$HYPR_CONFIG_DIR" ]; then
  target=$(readlink "$HYPR_CONFIG_DIR")
  if [ "$target" = "$KITANA_DIR/hypr" ]; then
    echo "Removing old Kitana Hypr config symlink..."
    rm "$HYPR_CONFIG_DIR"
  else
    backup="$HYPR_CONFIG_DIR.bak.$(date +%s)"
    echo "Backing up existing Hypr config symlink to $backup"
    mv "$HYPR_CONFIG_DIR" "$backup"
  fi
elif [ -e "$HYPR_CONFIG_DIR" ] && [ ! -d "$HYPR_CONFIG_DIR" ]; then
  backup="$HYPR_CONFIG_DIR.bak.$(date +%s)"
  echo "Backing up existing Hypr config path to $backup"
  mv "$HYPR_CONFIG_DIR" "$backup"
fi

mkdir -p "$HYPR_CONFIG_DIR/modules" "$HYPR_CONFIG_DIR/scripts"

if [ ! -e "$HYPR_ENTRYPOINT" ] || grep -q "$HYPR_ENTRYPOINT_MARKER" "$HYPR_ENTRYPOINT"; then
  install_kitana_entrypoint
else
  echo "Keeping existing Hypr Lua entrypoint: $HYPR_ENTRYPOINT"
  echo "Add dofile(\"$KITANA_DIR/hypr/hyprland.lua\") to load Kitana defaults."
fi

if [ ! -e "$HYPR_CONFIG_DIR/hypridle.conf" ]; then
  cp "$KITANA_DIR/hypr/hypridle.conf" "$HYPR_CONFIG_DIR/hypridle.conf"
fi

if [ ! -e "$HYPR_CONFIG_DIR/hyprpaper.conf" ]; then
  cp "$KITANA_DIR/hypr/hyprpaper.conf" "$HYPR_CONFIG_DIR/hyprpaper.conf"
fi

if [ ! -e "$HYPR_CONFIG_DIR/walls" ]; then
  ln -s "$KITANA_DIR/hypr/walls" "$HYPR_CONFIG_DIR/walls"
fi

for script in "$KITANA_DIR"/hypr/scripts/*; do
  [ -e "$script" ] || continue
  target="$HYPR_CONFIG_DIR/scripts/$(basename "$script")"

  if [ ! -e "$target" ]; then
    ln -s "$script" "$target"
  fi
done
