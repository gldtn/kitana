#!/bin/bash

set -euo pipefail

echo "Installing GTK theme and icon theme..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
GTK_THEME_NAME="${GTK_THEME_NAME:-Adwaita-dark}"
GTK_ICON_THEME_NAME="${GTK_ICON_THEME_NAME:-Yaru-blue-dark}"

theme_exists() {
  [ -d "$HOME/.local/share/themes/$1" ] || [ -d "$HOME/.themes/$1" ] || [ -d "/usr/share/themes/$1" ]
}

icon_theme_exists() {
  [ -d "$HOME/.local/share/icons/$1" ] || [ -d "$HOME/.icons/$1" ] || [ -d "/usr/share/icons/$1" ]
}

gtk2_theme_exists() {
  [ -d "$HOME/.local/share/themes/$1/gtk-2.0" ] || [ -d "$HOME/.themes/$1/gtk-2.0" ] || [ -d "/usr/share/themes/$1/gtk-2.0" ]
}

set_ini_key() {
  local file="$1"
  local key="$2"
  local value="$3"
  local tmp

  tmp="$(mktemp)"
  if [ -f "$file" ]; then
    awk -F= -v key="$key" -v value="$value" '
      $1 == key { print key "=" value; seen = 1; next }
      { print }
      END { if (!seen) print key "=" value }
    ' "$file" >"$tmp"
  else
    {
      printf '[Settings]\n'
      printf '%s=%s\n' "$key" "$value"
    } >"$tmp"
  fi
  mv "$tmp" "$file"
}

apply_gtk_settings() {
  local gtk3_config_dir="$HOME/.config/gtk-3.0"
  local gtk4_config_dir="$HOME/.config/gtk-4.0"
  local gtk2_theme="$GTK_THEME_NAME"

  if ! gtk2_theme_exists "$gtk2_theme"; then
    gtk2_theme="Adwaita-dark"
  fi

  mkdir -p "$gtk3_config_dir" "$gtk4_config_dir"

  if { [ ! -f "$HOME/.gtkrc-2.0" ] || grep -q "overwritten by nwg-look" "$HOME/.gtkrc-2.0"; } && [ -f "$KITANA_DIR/config/gtkrc-2.0" ]; then
    cp "$KITANA_DIR/config/gtkrc-2.0" "$HOME/.gtkrc-2.0"
  fi

  if [ ! -f "$gtk3_config_dir/settings.ini" ] && [ -f "$KITANA_DIR/config/gtk-3.0/settings.ini" ]; then
    cp "$KITANA_DIR/config/gtk-3.0/settings.ini" "$gtk3_config_dir/settings.ini"
  fi
  if [ ! -f "$gtk4_config_dir/settings.ini" ] && [ -f "$KITANA_DIR/config/gtk-4.0/settings.ini" ]; then
    cp "$KITANA_DIR/config/gtk-4.0/settings.ini" "$gtk4_config_dir/settings.ini"
  fi

  set_ini_key "$gtk3_config_dir/settings.ini" gtk-theme-name "$GTK_THEME_NAME"
  set_ini_key "$gtk3_config_dir/settings.ini" gtk-icon-theme-name "$GTK_ICON_THEME_NAME"
  set_ini_key "$gtk3_config_dir/settings.ini" gtk-application-prefer-dark-theme 1
  set_ini_key "$gtk4_config_dir/settings.ini" gtk-theme-name "$GTK_THEME_NAME"
  set_ini_key "$gtk4_config_dir/settings.ini" gtk-icon-theme-name "$GTK_ICON_THEME_NAME"

  if [ -f "$HOME/.gtkrc-2.0" ]; then
    set_ini_key "$HOME/.gtkrc-2.0" gtk-theme-name "\"$gtk2_theme\""
    set_ini_key "$HOME/.gtkrc-2.0" gtk-icon-theme-name "\"$GTK_ICON_THEME_NAME\""
  fi
}

apply_gtk_settings

if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d /usr/share/icons/Yaru ]; then
  sudo gtk-update-icon-cache /usr/share/icons/Yaru >/dev/null 2>&1 || true
fi

if command -v gsettings >/dev/null 2>&1 && [ "${KITANA_SKIP_GSETTINGS:-0}" != "1" ]; then
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark >/dev/null 2>&1 || true

  if theme_exists "$GTK_THEME_NAME"; then
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME" >/dev/null 2>&1 || true
  fi

  if icon_theme_exists "$GTK_ICON_THEME_NAME"; then
    gsettings set org.gnome.desktop.interface icon-theme "$GTK_ICON_THEME_NAME" >/dev/null 2>&1 || true
  fi
fi
