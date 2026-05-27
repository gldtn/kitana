#!/bin/bash

set -u

failed=0

pass() {
  printf '[OK] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1"
  failed=1
}

warn() {
  printf '[WARN] %s\n' "$1"
}

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    pass "command: $1"
  else
    fail "command missing: $1"
  fi
}

check_package() {
  if pacman -Q "$1" >/dev/null 2>&1; then
    pass "package: $1"
  else
    fail "package missing: $1"
  fi
}

check_service_enabled() {
  if systemctl is-enabled "$1" >/dev/null 2>&1; then
    pass "service enabled: $1"
  else
    fail "service not enabled: $1"
  fi
}

check_user_service() {
  if systemctl --user is-active "$1" >/dev/null 2>&1; then
    pass "user service active: $1"
  else
    fail "user service not active: $1"
  fi
}

check_xdg_user_dir() {
  if [ -d "$HOME/$1" ]; then
    pass "XDG user dir: ~/$1"
  else
    fail "XDG user dir missing: ~/$1"
  fi
}

check_file() {
  if [ -f "$1" ]; then
    pass "$2"
  else
    fail "$3"
  fi
}

check_dir() {
  if [ -d "$1" ]; then
    pass "$2"
  else
    fail "$3"
  fi
}

echo "Validating Kitana install..."
echo

for cmd in git yay Hyprland hyprctl sddm vicinae quickshell swaync waybar; do
  check_command "$cmd"
done

if command -v Hyprland >/dev/null 2>&1; then
  echo
  Hyprland --version 2>/dev/null || Hyprland -v 2>/dev/null || true
fi

echo

for pkg in \
  bluez \
  ghostty-nightly-bin \
  hyprland \
  hyprlock \
  hyprpaper \
  hyprpicker \
  hyprpolkitagent \
  pixie-sddm-git \
  quickshell \
  qt6ct \
  sddm \
  swaync \
  vicinae-bin \
  waybar \
  xdg-desktop-portal-hyprland; do
  check_package "$pkg"
done

echo

for user_dir in Documents Downloads Pictures Media/music Media/videos; do
  check_xdg_user_dir "$user_dir"
done

echo

check_service_enabled bluetooth.service
check_service_enabled iwd.service
check_service_enabled sddm.service

echo

if systemctl --user is-active xdg-desktop-portal-hyprland.service >/dev/null 2>&1; then
  pass "user service active: xdg-desktop-portal-hyprland.service"
elif systemctl --user is-active xdg-desktop-portal.service >/dev/null 2>&1; then
  pass "user service active: xdg-desktop-portal.service"
elif systemctl --user list-unit-files xdg-desktop-portal-hyprland.service >/dev/null 2>&1; then
  warn "user service not active: xdg-desktop-portal-hyprland.service"
else
  warn "user service not found: xdg-desktop-portal-hyprland.service"
fi

echo

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"

check_file "$HOME/.bashrc" "Bash entrypoint: ~/.bashrc" "Bash entrypoint missing: ~/.bashrc"
check_file "$HOME/.config/bash/rc" "Bash config: ~/.config/bash/rc" "Bash config missing: ~/.config/bash/rc"
check_dir "$HOME/.config/bash/custom" "Bash custom directory: ~/.config/bash/custom" "Bash custom directory missing: ~/.config/bash/custom"
check_file "$HOME/.config/starship/starship.toml" "Starship config: ~/.config/starship/starship.toml" "Starship config missing: ~/.config/starship/starship.toml"
check_file "$HOME/.config/gtk-3.0/settings.ini" "GTK 3 config: ~/.config/gtk-3.0/settings.ini" "GTK 3 config missing: ~/.config/gtk-3.0/settings.ini"
check_file "$HOME/.config/gtk-3.0/bookmarks" "GTK bookmarks: ~/.config/gtk-3.0/bookmarks" "GTK bookmarks missing: ~/.config/gtk-3.0/bookmarks"
check_file "$HOME/.config/gtk-4.0/settings.ini" "GTK 4 config: ~/.config/gtk-4.0/settings.ini" "GTK 4 config missing: ~/.config/gtk-4.0/settings.ini"
check_file "$HOME/.config/Kvantum/kvantum.kvconfig" "Kvantum config: ~/.config/Kvantum/kvantum.kvconfig" "Kvantum config missing: ~/.config/Kvantum/kvantum.kvconfig"
check_file "$HOME/.config/qt6ct/qt6ct.conf" "Qt6ct config: ~/.config/qt6ct/qt6ct.conf" "Qt6ct config missing: ~/.config/qt6ct/qt6ct.conf"

if command -v gsettings >/dev/null 2>&1; then
  if [ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || true)" = "'prefer-dark'" ]; then
    pass "GTK/libadwaita color scheme: prefer-dark"
  else
    warn "GTK/libadwaita color scheme is not prefer-dark"
  fi
fi

echo

if [ -L "$HOME/.config/hypr" ]; then
  fail "Hypr config should be a directory, not a symlink: ~/.config/hypr"
elif [ -d "$HOME/.config/hypr" ]; then
  pass "Hypr config directory: ~/.config/hypr"
else
  fail "Hypr config missing: ~/.config/hypr"
fi

if [ -f "$HOME/.config/hypr/hyprland.lua" ]; then
  pass "Hypr Lua entrypoint: ~/.config/hypr/hyprland.lua"
else
  fail "Hypr Lua entrypoint missing: ~/.config/hypr/hyprland.lua"
fi

if [ -d "$HOME/.config/hypr/custom" ]; then
  pass "Hypr custom directory: ~/.config/hypr/custom"
else
  fail "Hypr custom directory missing: ~/.config/hypr/custom"
fi

if [ -d "$HOME/.config/hypr/scripts" ]; then
  pass "Hypr user script directory: ~/.config/hypr/scripts"
else
  fail "Hypr user script directory missing: ~/.config/hypr/scripts"
fi

for lua_module in \
  modules/autostart.lua \
  modules/binds.lua \
  modules/env.lua \
  modules/windowrules.lua; do
  if [ -f "$KITANA_DIR/default/hypr/$lua_module" ]; then
    pass "Kitana Hypr Lua default: $lua_module"
  else
    fail "Kitana Hypr Lua default missing: $lua_module"
  fi
done

for custom_module in monitors binds; do
  if [ -f "$HOME/.config/hypr/custom/$custom_module.lua" ]; then
    pass "Hypr custom module: $custom_module"
  else
    fail "Hypr custom module missing: $custom_module"
  fi
done

if [ -f "$HOME/.config/hypr/hypridle.conf" ]; then
  pass "Hypridle config: ~/.config/hypr/hypridle.conf"
else
  fail "Hypridle config missing: ~/.config/hypr/hypridle.conf"
fi

if systemctl --user is-active hypridle.service >/dev/null 2>&1; then
  pass "user service active: hypridle.service"
elif pgrep -x hypridle >/dev/null 2>&1; then
  pass "process active: hypridle"
else
  fail "hypridle is not running"
fi

if [ -f "$HOME/.config/hypr/hyprpaper.conf" ]; then
  pass "Hyprpaper config: ~/.config/hypr/hyprpaper.conf"
else
  fail "Hyprpaper config missing: ~/.config/hypr/hyprpaper.conf"
fi

if [ -f "$KITANA_DIR/default/hypr/walls/mystical_night_town_default.jpg" ]; then
  pass "Hyprpaper default wallpaper"
else
  fail "Hyprpaper default wallpaper missing"
fi

if [ -d "$HOME/.config/hypr/walls" ]; then
  pass "Hypr wallpapers: ~/.config/hypr/walls"
else
  fail "Hypr wallpapers missing: ~/.config/hypr/walls"
fi

if [ -f "$HOME/.config/ghostty/config" ]; then
  pass "Ghostty config: ~/.config/ghostty/config"
else
  fail "Ghostty config missing: ~/.config/ghostty/config"
fi

for ghostty_theme in catppuccin cyberdream tokyonight; do
  if [ -f "$HOME/.config/ghostty/themes/$ghostty_theme" ]; then
    pass "Ghostty theme: $ghostty_theme"
  else
    fail "Ghostty theme missing: $ghostty_theme"
  fi
done

for zed_config in settings.json keymap.json tasks.json; do
  if [ -f "$HOME/.config/zed/$zed_config" ]; then
    pass "Zed config: $zed_config"
  else
    fail "Zed config missing: $zed_config"
  fi
done

for zed_snippet in blade filament inertia livewire pest php volt; do
  if [ -f "$HOME/.config/zed/snippets/$zed_snippet.json" ]; then
    pass "Zed snippet: $zed_snippet"
  else
    fail "Zed snippet missing: $zed_snippet"
  fi
done

if command -v luac >/dev/null 2>&1; then
  if luac -p "$KITANA_DIR/config/hypr/hyprland.lua" "$KITANA_DIR"/default/hypr/modules/*.lua; then
    pass "Kitana Hypr Lua syntax"
  else
    fail "Kitana Hypr Lua syntax"
  fi

  custom_modules=("$HOME/.config/hypr"/custom/*.lua)
  if [ -e "${custom_modules[0]}" ]; then
    if luac -p "${custom_modules[@]}"; then
      pass "Hypr custom Lua syntax"
    else
      fail "Hypr custom Lua syntax"
    fi
  fi
else
  echo '[WARN] skipping Hypr Lua syntax check: luac missing'
fi

if command -v ghostty >/dev/null 2>&1 && [ -f "$KITANA_DIR/default/ghostty/config" ]; then
  if ghostty +validate-config --config-file="$KITANA_DIR/default/ghostty/config"; then
    pass "Kitana Ghostty config syntax"
  else
    fail "Kitana Ghostty config syntax"
  fi
fi

echo

if command -v xdg-mime >/dev/null 2>&1; then
  printf 'Default browser handler: %s\n' "$(xdg-mime query default x-scheme-handler/https 2>/dev/null || true)"
  printf 'Default file handler: %s\n' "$(xdg-mime query default inode/directory 2>/dev/null || true)"
else
  fail "command missing: xdg-mime"
fi

echo

if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  hyprctl configerrors || failed=1
else
  echo '[WARN] skipping hyprctl configerrors: not running inside Hyprland'
fi

echo

if [ "$failed" -eq 0 ]; then
  echo "Kitana validation passed."
else
  echo "Kitana validation found issues."
fi

exit "$failed"
