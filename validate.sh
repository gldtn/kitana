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

if systemctl --user list-unit-files xdg-desktop-portal-hyprland.service >/dev/null 2>&1; then
  check_user_service xdg-desktop-portal-hyprland.service
else
  echo '[WARN] user service not found: xdg-desktop-portal-hyprland.service'
fi

echo

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"

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

if [ -d "$HOME/.config/hypr/modules" ]; then
  pass "Hypr user override directory: ~/.config/hypr/modules"
else
  fail "Hypr user override directory missing: ~/.config/hypr/modules"
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
  if [ -f "$KITANA_DIR/hypr/$lua_module" ]; then
    pass "Kitana Hypr Lua default: $lua_module"
  else
    fail "Kitana Hypr Lua default missing: $lua_module"
  fi
done

if [ -f "$HOME/.config/hypr/hypridle.conf" ]; then
  pass "Hypridle config: ~/.config/hypr/hypridle.conf"
else
  fail "Hypridle config missing: ~/.config/hypr/hypridle.conf"
fi

if [ -f "$HOME/.config/hypr/hyprpaper.conf" ]; then
  pass "Hyprpaper config: ~/.config/hypr/hyprpaper.conf"
else
  fail "Hyprpaper config missing: ~/.config/hypr/hyprpaper.conf"
fi

if [ -f "$KITANA_DIR/hypr/walls/mystical_night_town_default.jpg" ]; then
  pass "Hyprpaper default wallpaper"
else
  fail "Hyprpaper default wallpaper missing"
fi

if [ -e "$HOME/.config/hypr/walls" ]; then
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

if command -v luac >/dev/null 2>&1; then
  if luac -p "$KITANA_DIR/hypr/hyprland.lua" "$KITANA_DIR"/hypr/modules/*.lua; then
    pass "Kitana Hypr Lua syntax"
  else
    fail "Kitana Hypr Lua syntax"
  fi

  user_modules=("$HOME/.config/hypr"/modules/*.lua)
  if [ -e "${user_modules[0]}" ]; then
    if luac -p "${user_modules[@]}"; then
      pass "Hypr user override Lua syntax"
    else
      fail "Hypr user override Lua syntax"
    fi
  fi
else
  echo '[WARN] skipping Hypr Lua syntax check: luac missing'
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
