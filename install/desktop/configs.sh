#!/bin/bash

echo "Installing desktop config files..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
HYPR_CONFIG_DIR="$HOME/.config/hypr"
HYPR_ENTRYPOINT="$HYPR_CONFIG_DIR/hyprland.lua"
HYPR_ENTRYPOINT_MARKER="Kitana managed Hyprland Lua entrypoint"
HYPRIDLE_MARKER="Kitana managed Hypridle config"
HYPRLOCK_MARKER="Kitana managed Hyprlock config"
HYPRPAPER_MARKER="Kitana managed Hyprpaper config"
KITANA_CONFIG_DIR="$HOME/.config/kitana"
KITANA_CONFIG_FILE="$KITANA_CONFIG_DIR/config"
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
ZED_CONFIG_DIR="$HOME/.config/zed"
QUICKSHELL_CONFIG_DIR="$HOME/.config/quickshell/kitana"

mkdir -p "$HOME/.config" "$KITANA_CONFIG_DIR"

if [ ! -e "$KITANA_CONFIG_FILE" ]; then
  cp "$KITANA_DIR/config/kitana/config" "$KITANA_CONFIG_FILE"
else
  echo "Keeping existing Kitana config: $KITANA_CONFIG_FILE"
fi

env_wallpaper_dir="${KITANA_WALLPAPER_DIR:-}"
# shellcheck disable=SC1090
source "$KITANA_CONFIG_FILE"
WALLPAPER_DIR="${env_wallpaper_dir:-${KITANA_WALLPAPER_DIR:-$HOME/.config/kitana/wallpapers}}"

mkdir -p "$WALLPAPER_DIR"

for wallpaper_link in "$WALLPAPER_DIR"/*; do
  if [ -L "$wallpaper_link" ] && [ ! -e "$wallpaper_link" ]; then
    echo "Removing broken wallpaper symlink: $wallpaper_link"
    rm "$wallpaper_link"
  fi
done

for wallpaper in "$KITANA_DIR"/default/wallpapers/*; do
  [ -e "$wallpaper" ] || continue
  target="$WALLPAPER_DIR/$(basename "$wallpaper")"
  if [ ! -e "$target" ]; then
    ln -sfn "$wallpaper" "$target"
  fi
done

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

if [ ! -e "$HYPR_CONFIG_DIR/hypridle.conf" ] || grep -q "$HYPRIDLE_MARKER" "$HYPR_CONFIG_DIR/hypridle.conf" || grep -q "timeout = 2700" "$HYPR_CONFIG_DIR/hypridle.conf"; then
  cp "$KITANA_DIR/default/hypr/hypridle.conf" "$HYPR_CONFIG_DIR/hypridle.conf"
fi

if [ ! -e "$HYPR_CONFIG_DIR/hyprlock.conf" ] || grep -q "$HYPRLOCK_MARKER" "$HYPR_CONFIG_DIR/hyprlock.conf" || grep -q "sample hyprlock.conf" "$HYPR_CONFIG_DIR/hyprlock.conf"; then
  cp "$KITANA_DIR/default/hypr/hyprlock.conf" "$HYPR_CONFIG_DIR/hyprlock.conf"
fi

if [ ! -e "$HYPR_CONFIG_DIR/hyprpaper.conf" ] || grep -q "$HYPRPAPER_MARKER" "$HYPR_CONFIG_DIR/hyprpaper.conf" || grep -q "mystical_night_town_default.jpg" "$HYPR_CONFIG_DIR/hyprpaper.conf" || grep -q "fantasy_world_floating_islands.jpg" "$HYPR_CONFIG_DIR/hyprpaper.conf"; then
  cp "$KITANA_DIR/default/hypr/hyprpaper.conf" "$HYPR_CONFIG_DIR/hyprpaper.conf"
fi

if [ -L "$HYPR_CONFIG_DIR/walls" ]; then
  walls_target="$(readlink "$HYPR_CONFIG_DIR/walls")"
  if [ "$walls_target" = "$KITANA_DIR/default/hypr/walls" ] || [ ! -e "$HYPR_CONFIG_DIR/walls" ]; then
    echo "Removing old Hypr wallpapers symlink: $HYPR_CONFIG_DIR/walls"
    rm "$HYPR_CONFIG_DIR/walls"
  fi
fi

for script in "$KITANA_DIR"/default/hypr/scripts/*; do
  [ -e "$script" ] || continue
  target="$HYPR_CONFIG_DIR/scripts/$(basename "$script")"

  if [ -L "$target" ] && [ ! -e "$target" ]; then
    echo "Removing broken Hypr script symlink: $target"
    rm "$target"
  fi

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

if [ ! -e "$GTK3_CONFIG_DIR/bookmarks" ]; then
  {
    printf 'file://%s/Documents Documents\n' "$HOME"
    printf 'file://%s/Downloads Downloads\n' "$HOME"
    printf 'file://%s/Pictures Pictures\n' "$HOME"
    printf 'file://%s/Media/music Music\n' "$HOME"
    printf 'file://%s/Media/videos Videos\n' "$HOME"
  } >"$GTK3_CONFIG_DIR/bookmarks"
else
  echo "Keeping existing GTK bookmarks: $GTK3_CONFIG_DIR/bookmarks"
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

if command -v gsettings >/dev/null 2>&1 && [ "${KITANA_SKIP_GSETTINGS:-0}" != "1" ]; then
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark >/dev/null 2>&1 || true

  if [ -d "$HOME/.local/share/themes/Graphite-Dark-compact" ] || [ -d /usr/share/themes/Graphite-Dark-compact ]; then
    gsettings set org.gnome.desktop.interface gtk-theme Graphite-Dark-compact >/dev/null 2>&1 || true
  else
    gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark >/dev/null 2>&1 || true
  fi

  if [ -d "$HOME/.local/share/icons/Tela-circle-black" ] || [ -d /usr/share/icons/Tela-circle-black ]; then
    gsettings set org.gnome.desktop.interface icon-theme Tela-circle-black >/dev/null 2>&1 || true
  fi
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

mkdir -p "$ZED_CONFIG_DIR/snippets"

for zed_config in settings.json keymap.json tasks.json; do
  if [ ! -e "$ZED_CONFIG_DIR/$zed_config" ]; then
    cp "$KITANA_DIR/config/zed/$zed_config" "$ZED_CONFIG_DIR/$zed_config"
  else
    echo "Keeping existing Zed config: $ZED_CONFIG_DIR/$zed_config"
  fi
done

for snippet in "$KITANA_DIR"/config/zed/snippets/*.json; do
  [ -e "$snippet" ] || continue
  target="$ZED_CONFIG_DIR/snippets/$(basename "$snippet")"

  if [ ! -e "$target" ]; then
    cp "$snippet" "$target"
  fi
done

mkdir -p "$QUICKSHELL_CONFIG_DIR"
mkdir -p "$QUICKSHELL_CONFIG_DIR/Common"
mkdir -p "$QUICKSHELL_CONFIG_DIR/Modules"
mkdir -p "$QUICKSHELL_CONFIG_DIR/Services"
mkdir -p "$QUICKSHELL_CONFIG_DIR/Widgets"
mkdir -p "$QUICKSHELL_CONFIG_DIR/custom"

if [ ! -e "$QUICKSHELL_CONFIG_DIR/shell.qml" ] || grep -q "Kitana managed Quickshell bar" "$QUICKSHELL_CONFIG_DIR/shell.qml"; then
  cp "$KITANA_DIR/config/quickshell/kitana/shell.qml" "$QUICKSHELL_CONFIG_DIR/shell.qml"
else
  echo "Keeping existing Quickshell config: $QUICKSHELL_CONFIG_DIR/shell.qml"
fi

for quickshell_config in Colors.qml qmldir; do
  if [ ! -e "$QUICKSHELL_CONFIG_DIR/$quickshell_config" ]; then
    cp "$KITANA_DIR/config/quickshell/kitana/$quickshell_config" "$QUICKSHELL_CONFIG_DIR/$quickshell_config"
  else
    echo "Keeping existing Quickshell config: $QUICKSHELL_CONFIG_DIR/$quickshell_config"
  fi
done

for quickshell_dir in Common Modules Services Widgets; do
  [ -d "$KITANA_DIR/config/quickshell/kitana/$quickshell_dir" ] || continue

  for quickshell_file in "$KITANA_DIR"/config/quickshell/kitana/"$quickshell_dir"/*; do
    [ -f "$quickshell_file" ] || continue
    target="$QUICKSHELL_CONFIG_DIR/$quickshell_dir/$(basename "$quickshell_file")"

    if [ ! -e "$target" ] || grep -q "Kitana managed Quickshell" "$target" || [ "$(basename "$quickshell_file")" = "qmldir" ]; then
      cp "$quickshell_file" "$target"
    else
      echo "Keeping existing Quickshell file: $target"
    fi
  done
done

for quickshell_custom in "$KITANA_DIR"/config/quickshell/kitana/custom/*.qml; do
  [ -e "$quickshell_custom" ] || continue
  target="$QUICKSHELL_CONFIG_DIR/custom/$(basename "$quickshell_custom")"

  if [ ! -e "$target" ]; then
    cp "$quickshell_custom" "$target"
  else
    echo "Keeping existing Quickshell custom config: $target"
  fi
done
