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

if [ -L "$HOME/.config/hypr" ]; then
  pass "Hypr config symlink: ~/.config/hypr"
elif [ -d "$HOME/.config/hypr" ]; then
  echo '[WARN] Hypr config exists but is not a symlink: ~/.config/hypr'
else
  fail "Hypr config missing: ~/.config/hypr"
fi

if [ -f "$HOME/.config/hypr/hyprland.lua" ]; then
  pass "Hypr Lua entrypoint: ~/.config/hypr/hyprland.lua"
else
  fail "Hypr Lua entrypoint missing: ~/.config/hypr/hyprland.lua"
fi

for lua_module in \
  modules/autostart.lua \
  modules/binds.lua \
  modules/env.lua \
  modules/windowrules.lua; do
  if [ -f "$HOME/.config/hypr/$lua_module" ]; then
    pass "Hypr Lua module: ~/.config/hypr/$lua_module"
  else
    fail "Hypr Lua module missing: ~/.config/hypr/$lua_module"
  fi
done

if command -v luac >/dev/null 2>&1 && [ -f "$HOME/.config/hypr/hyprland.lua" ]; then
  if luac -p "$HOME/.config/hypr/hyprland.lua" "$HOME/.config/hypr"/modules/*.lua; then
    pass "Hypr Lua syntax"
  else
    fail "Hypr Lua syntax"
  fi
else
  echo '[WARN] skipping Hypr Lua syntax check: luac or hyprland.lua missing'
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
