#!/bin/bash

echo "Installing desktop config files..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
HYPR_CONFIG_DIR="$HOME/.config/hypr"
HYPR_ENTRYPOINT="$HYPR_CONFIG_DIR/hyprland.lua"
HYPR_ENTRYPOINT_MARKER="Kitana managed Hyprland Lua entrypoint"
HYPRPAPER_MARKER="Kitana managed Hyprpaper config"
BASH_CONFIG_DIR="$HOME/.config/bash"
BASH_RC_MARKER="Kitana managed Bash config"
BASHRC_MARKER="Kitana managed Bash entrypoint"
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
GHOSTTY_CONFIG_MARKER="Kitana managed Ghostty config"
STARSHIP_CONFIG_DIR="$HOME/.config/starship"
STARSHIP_CONFIG_MARKER="Kitana managed Starship config"
GTK3_CONFIG_DIR="$HOME/.config/gtk-3.0"
GTK4_CONFIG_DIR="$HOME/.config/gtk-4.0"
GTK3_CONFIG_MARKER="Kitana managed GTK 3 config"
GTK4_CONFIG_MARKER="Kitana managed GTK 4 config"
KVANTUM_CONFIG_DIR="$HOME/.config/Kvantum"
KVANTUM_CONFIG_MARKER="Kitana managed Kvantum config"
QT6CT_CONFIG_DIR="$HOME/.config/qt6ct"
QT6CT_CONFIG_MARKER="Kitana managed Qt6ct config"

mkdir -p "$HOME/.config"

if [ -L "$HYPR_CONFIG_DIR" ]; then
  target=$(readlink "$HYPR_CONFIG_DIR")
  if [ "$target" = "$KITANA_DIR/hypr" ] || [ "$target" = "$KITANA_DIR/default/hypr" ]; then
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

mkdir -p "$HYPR_CONFIG_DIR/custom" "$HYPR_CONFIG_DIR/scripts"

if [ ! -e "$HYPR_ENTRYPOINT" ] || grep -q "$HYPR_ENTRYPOINT_MARKER" "$HYPR_ENTRYPOINT"; then
  cp "$KITANA_DIR/config/hypr/hyprland.lua" "$HYPR_ENTRYPOINT"
else
  echo "Keeping existing Hypr Lua entrypoint: $HYPR_ENTRYPOINT"
  echo "Use require(\"default.hypr...\") to load Kitana defaults from $KITANA_DIR/default."
fi

for custom_module in monitors binds; do
  custom_file="$HYPR_CONFIG_DIR/custom/$custom_module.lua"

  if [ ! -e "$custom_file" ]; then
    cat >"$custom_file" <<EOF
-- Local Hypr customizations for $custom_module.
-- This file is loaded after Kitana defaults.
EOF
  fi
done

if [ ! -e "$HYPR_CONFIG_DIR/hypridle.conf" ]; then
  cp "$KITANA_DIR/default/hypr/hypridle.conf" "$HYPR_CONFIG_DIR/hypridle.conf"
fi

if [ ! -e "$HYPR_CONFIG_DIR/hyprpaper.conf" ] || grep -q "$HYPRPAPER_MARKER" "$HYPR_CONFIG_DIR/hyprpaper.conf" || grep -q "mystical_night_town_default.jpg" "$HYPR_CONFIG_DIR/hyprpaper.conf"; then
  cp "$KITANA_DIR/default/hypr/hyprpaper.conf" "$HYPR_CONFIG_DIR/hyprpaper.conf"
fi

WALLS_LINK="$HYPR_CONFIG_DIR/walls"

if [ -L "$WALLS_LINK" ] && [ ! -e "$WALLS_LINK" ]; then
  echo "Removing broken Hypr wallpapers symlink: $WALLS_LINK"
  rm "$WALLS_LINK"
fi

if [ ! -e "$WALLS_LINK" ]; then
  ln -s "$KITANA_DIR/default/hypr/walls" "$WALLS_LINK"
fi

for script in "$KITANA_DIR"/default/hypr/scripts/*; do
  [ -e "$script" ] || continue
  target="$HYPR_CONFIG_DIR/scripts/$(basename "$script")"

  if [ ! -e "$target" ]; then
    ln -s "$script" "$target"
  fi
done

mkdir -p "$BASH_CONFIG_DIR/custom"

if [ ! -e "$HOME/.bashrc" ] || grep -q "$BASHRC_MARKER" "$HOME/.bashrc"; then
  cp "$KITANA_DIR/config/bash/.bashrc" "$HOME/.bashrc"
else
  backup="$HOME/.bashrc.bak.$(date +%s)"
  echo "Backing up existing Bash entrypoint to $backup"
  mv "$HOME/.bashrc" "$backup"
  cp "$KITANA_DIR/config/bash/.bashrc" "$HOME/.bashrc"
fi

if [ ! -e "$BASH_CONFIG_DIR/rc" ] || grep -q "$BASH_RC_MARKER" "$BASH_CONFIG_DIR/rc"; then
  cp "$KITANA_DIR/config/bash/rc" "$BASH_CONFIG_DIR/rc"
else
  echo "Keeping existing Bash config: $BASH_CONFIG_DIR/rc"
fi

mkdir -p "$STARSHIP_CONFIG_DIR"

if [ ! -e "$STARSHIP_CONFIG_DIR/starship.toml" ] || grep -q "$STARSHIP_CONFIG_MARKER" "$STARSHIP_CONFIG_DIR/starship.toml"; then
  cp "$KITANA_DIR/config/starship.toml" "$STARSHIP_CONFIG_DIR/starship.toml"
else
  echo "Keeping existing Starship config: $STARSHIP_CONFIG_DIR/starship.toml"
fi

mkdir -p "$GTK3_CONFIG_DIR" "$GTK4_CONFIG_DIR" "$KVANTUM_CONFIG_DIR" "$QT6CT_CONFIG_DIR"

if [ ! -e "$GTK3_CONFIG_DIR/settings.ini" ] || grep -q "$GTK3_CONFIG_MARKER" "$GTK3_CONFIG_DIR/settings.ini"; then
  cp "$KITANA_DIR/config/gtk-3.0/settings.ini" "$GTK3_CONFIG_DIR/settings.ini"
else
  echo "Keeping existing GTK 3 config: $GTK3_CONFIG_DIR/settings.ini"
fi

if [ ! -e "$GTK4_CONFIG_DIR/settings.ini" ] || grep -q "$GTK4_CONFIG_MARKER" "$GTK4_CONFIG_DIR/settings.ini"; then
  cp "$KITANA_DIR/config/gtk-4.0/settings.ini" "$GTK4_CONFIG_DIR/settings.ini"
else
  echo "Keeping existing GTK 4 config: $GTK4_CONFIG_DIR/settings.ini"
fi

if [ ! -e "$KVANTUM_CONFIG_DIR/kvantum.kvconfig" ] || grep -q "$KVANTUM_CONFIG_MARKER" "$KVANTUM_CONFIG_DIR/kvantum.kvconfig"; then
  cp "$KITANA_DIR/config/Kvantum/kvantum.kvconfig" "$KVANTUM_CONFIG_DIR/kvantum.kvconfig"
else
  echo "Keeping existing Kvantum config: $KVANTUM_CONFIG_DIR/kvantum.kvconfig"
fi

if [ ! -e "$QT6CT_CONFIG_DIR/qt6ct.conf" ] || grep -q "$QT6CT_CONFIG_MARKER" "$QT6CT_CONFIG_DIR/qt6ct.conf"; then
  cp "$KITANA_DIR/config/qt6ct/qt6ct.conf" "$QT6CT_CONFIG_DIR/qt6ct.conf"
else
  echo "Keeping existing Qt6ct config: $QT6CT_CONFIG_DIR/qt6ct.conf"
fi

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark >/dev/null 2>&1 || true
  gsettings set org.gnome.desktop.interface gtk-theme Graphite-Dark-compact >/dev/null 2>&1 || true
  gsettings set org.gnome.desktop.interface icon-theme Tela-circle-black >/dev/null 2>&1 || true
fi

mkdir -p "$GHOSTTY_CONFIG_DIR/themes"

if [ ! -e "$GHOSTTY_CONFIG_DIR/config" ] || grep -q "$GHOSTTY_CONFIG_MARKER" "$GHOSTTY_CONFIG_DIR/config"; then
  cp "$KITANA_DIR/default/ghostty/config" "$GHOSTTY_CONFIG_DIR/config"
else
  echo "Keeping existing Ghostty config: $GHOSTTY_CONFIG_DIR/config"
fi

for theme in "$KITANA_DIR"/default/ghostty/themes/*; do
  [ -e "$theme" ] || continue
  target="$GHOSTTY_CONFIG_DIR/themes/$(basename "$theme")"

  if [ ! -e "$target" ]; then
    cp "$theme" "$target"
  fi
done
