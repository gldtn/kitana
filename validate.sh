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

check_optional_command() {
  if command -v "$1" >/dev/null 2>&1; then
    pass "command: $1"
  else
    warn "command missing: $1"
  fi
}

check_package() {
  if pacman -Q "$1" >/dev/null 2>&1; then
    pass "package: $1"
  else
    fail "package missing: $1"
  fi
}

check_optional_package() {
  if pacman -Q "$1" >/dev/null 2>&1; then
    pass "package: $1"
  else
    warn "package missing: $1"
  fi
}

check_any_package() {
  local label="$1"
  shift

  local pkg
  for pkg in "$@"; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
      pass "package: $pkg"
      return 0
    fi
  done

  fail "package missing: $label (tried: $*)"
}

check_service_enabled() {
  if systemctl is-enabled "$1" >/dev/null 2>&1; then
    pass "service enabled: $1"
  else
    fail "service not enabled: $1"
  fi
}

check_optional_service_enabled() {
  if systemctl is-enabled "$1" >/dev/null 2>&1; then
    pass "service enabled: $1"
  else
    warn "service not enabled: $1"
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

check_file_contains() {
  local file="$1"
  local pattern="$2"
  local ok_message="$3"
  local fail_message="$4"

  if [ -f "$file" ] && grep -q -- "$pattern" "$file"; then
    pass "$ok_message"
  else
    fail "$fail_message"
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

for cmd in git yay Hyprland start-hyprland hyprctl sddm quickshell awww awww-daemon nmcli nc lspci reflector rsync lua fwupdmgr dmidecode cargo rustc; do
  check_command "$cmd"
done

if command -v Hyprland >/dev/null 2>&1; then
  echo
  Hyprland --version 2>/dev/null || Hyprland -v 2>/dev/null || true
fi

echo

for pkg in \
  awww \
  bluez \
  desktop-file-utils \
  hyprland \
  hyprqt6engine \
  hyprlock \
  hyprpaper \
  hyprpicker \
  hyprpolkitagent \
  dmidecode \
  fwupd \
  linux-firmware \
  networkmanager \
  openbsd-netcat \
  papers \
  pciutils \
  quickshell \
  reflector \
  rsync \
  rust \
  shared-mime-info \
  sof-firmware \
  qt6ct \
  xdg-desktop-portal-hyprland; do
  check_package "$pkg"
done

check_any_package "ghostty" ghostty ghostty-nightly-bin
check_any_package "sddm" sddm sddm-git
check_package "libappindicator"

if [ -f /usr/share/applications/org.gnome.Papers.desktop ] || [ -f "$HOME/.local/share/applications/org.gnome.Papers.desktop" ]; then
  pass "PDF viewer desktop entry: org.gnome.Papers.desktop"
else
  fail "PDF viewer desktop entry missing: org.gnome.Papers.desktop"
fi

echo

for user_dir in Documents Downloads Pictures Media/music Media/videos; do
  check_xdg_user_dir "$user_dir"
done

echo

check_service_enabled bluetooth.service
check_service_enabled NetworkManager.service
check_service_enabled sddm.service
check_service_enabled fwupd-refresh.timer

for pkg in ccid libfido2 pcsclite pcsc-tools yubikey-manager; do
  check_optional_package "$pkg"
done
check_optional_command ykman
check_optional_command pcsc_scan
check_optional_service_enabled pcscd.socket

if systemctl is-enabled iwd.service >/dev/null 2>&1; then
  fail "service should be disabled: iwd.service"
else
  pass "service disabled: iwd.service"
fi

if systemctl is-enabled systemd-networkd.service >/dev/null 2>&1; then
  fail "service should be disabled: systemd-networkd.service"
else
  pass "service disabled: systemd-networkd.service"
fi

if [ -f /etc/sddm.conf.d/10-wayland.conf ] && grep -q '^DisplayServer=wayland$' /etc/sddm.conf.d/10-wayland.conf && grep -q '^CompositorCommand=start-hyprland -- --config /usr/share/sddm/hyprland.lua$' /etc/sddm.conf.d/10-wayland.conf; then
  pass "SDDM Wayland greeter compositor: Kitana Hyprland config"
else
  fail "SDDM Wayland greeter compositor missing or not Kitana-configured: /etc/sddm.conf.d/10-wayland.conf"
fi

if [ -f /usr/share/sddm/hyprland.lua ] && grep -q '^-- Kitana managed SDDM Hyprland greeter compositor config\.$' /usr/share/sddm/hyprland.lua; then
  pass "SDDM Hyprland greeter config: /usr/share/sddm/hyprland.lua"
else
  fail "SDDM Hyprland greeter config missing: /usr/share/sddm/hyprland.lua"
fi

if [ -f /usr/share/wayland-sessions/kitana-hyprland.desktop ] && grep -q '^Exec=/usr/bin/start-hyprland$' /usr/share/wayland-sessions/kitana-hyprland.desktop; then
  pass "SDDM Kitana Hyprland session: start-hyprland"
elif [ -f /usr/share/wayland-sessions/hyprland.desktop ] && grep -q '^Exec=.*start-hyprland$' /usr/share/wayland-sessions/hyprland.desktop; then
  pass "SDDM Hyprland session: start-hyprland"
else
  fail "SDDM Hyprland session does not use start-hyprland"
fi

if [ -f /etc/sddm.conf.d/20-theme.conf ] && grep -q '^Current=kitana$' /etc/sddm.conf.d/20-theme.conf && [ -d /usr/share/sddm/themes/kitana ]; then
  pass "SDDM Kitana theme configured"
else
  fail "SDDM Kitana theme missing or not selected"
fi

limine_config=""
for candidate in /boot/limine.conf /boot/limine/limine.conf /boot/efi/limine.conf /efi/limine.conf; do
  if [ -f "$candidate" ]; then
    limine_config="$candidate"
    break
  fi
done

if [ -n "$limine_config" ]; then
  if grep -q '^# Kitana managed Limine theme start$' "$limine_config" && grep -q '^term_background: 1e1e2e$' "$limine_config"; then
    pass "Limine theme: Catppuccin Mocha"
  else
    fail "Limine Catppuccin Mocha theme missing: $limine_config"
  fi

  if grep -q '^interface_branding:$' "$limine_config"; then
    pass "Limine branding hidden"
  else
    fail "Limine branding is not hidden: $limine_config"
  fi
else
  warn "Limine config not found; skipping Limine theme validation"
fi

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

if [ -f "$HOME/.config/hypr/.luarc.json" ] && grep -q '/usr/share/hypr/stubs' "$HOME/.config/hypr/.luarc.json"; then
  pass "Hypr Lua language config: ~/.config/hypr/.luarc.json"
else
  fail "Hypr Lua language config missing Hypr stubs: ~/.config/hypr/.luarc.json"
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
  modules/decorations.lua \
  modules/env.lua \
  modules/rules.lua \
  apps/system.lua \
  apps/1password.lua \
  apps/bitwarden.lua; do
  if [ -f "$KITANA_DIR/default/hypr/$lua_module" ]; then
    pass "Kitana Hypr Lua default: $lua_module"
  else
    fail "Kitana Hypr Lua default missing: $lua_module"
  fi
done

for custom_module in monitors input binds; do
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

if [ -f "$HOME/.config/hypr/hyprlock.conf" ]; then
  pass "Hyprlock config: ~/.config/hypr/hyprlock.conf"
else
  fail "Hyprlock config missing: ~/.config/hypr/hyprlock.conf"
fi

if [ -f "$HOME/.config/hypr/kitana-theme.lua" ]; then
  pass "Hypr Kitana theme config: ~/.config/hypr/kitana-theme.lua"
else
  fail "Hypr Kitana theme config missing: ~/.config/hypr/kitana-theme.lua"
fi

if [ -x "$KITANA_DIR/bin/kitana-lock" ]; then
  pass "Kitana lock helper: bin/kitana-lock"
else
  fail "Kitana lock helper missing or not executable: bin/kitana-lock"
fi

if [ -e "$HOME/.config/kitana/current-wallpaper" ]; then
  pass "Kitana current wallpaper: ~/.config/kitana/current-wallpaper"
else
  fail "Kitana current wallpaper missing: ~/.config/kitana/current-wallpaper"
fi

for helper in \
  kitana-arch-usb \
  kitana-git-config \
  kitana-firmware \
  kitana-hw-cpu \
  kitana-hw-gpu \
  kitana-hyprland-workspace-layout-toggle \
  kitana-keyboard \
  kitana-keyring \
  kitana-osd \
  kitana-screenshot \
  kitana-browser \
  kitana-password-manager \
  kitana-audio-mic-status \
  kitana-install-1password \
  kitana-install-browser \
  kitana-install-password-manager \
  kitana-install-dropbox \
  kitana-install-extras-crypto \
  kitana-install-extras-media \
  kitana-install-extras-nvim \
  kitana-install-extras-wallpapers \
  kitana-install-ghostty-nightly \
  kitana-install-nvim-gldtn \
  kitana-install-private-fonts \
  kitana-install-zsh \
  kitana-launcher \
  kitana-pkg-add \
  kitana-quickshell \
  kitana-refresh \
  kitana-reinstall \
  kitana-show-done \
  kitana-show-logo \
  kitana-theme \
  kitana-theme-ghostty \
  kitana-theme-grid \
  kitana-theme-hypr \
  kitana-theme-neovim \
  kitana-theme-quickshell \
  kitana-theme-zed \
  kitana-theme-zed-update \
  kitana-wallpaper \
  kitana-wallpaper-watch \
  kitana-webapp-install \
  kitana-webapp-handler-zoom \
  kitana-webapp-launch \
  kitana-webapp-remove; do
  if [ -x "$KITANA_DIR/bin/$helper" ]; then
    pass "Kitana helper: bin/$helper"
  else
    fail "Kitana helper missing or not executable: bin/$helper"
  fi
done

if [ -x "$KITANA_DIR/bin/kitana-hw-cpu" ]; then
  mapfile -t cpu_packages < <("$KITANA_DIR/bin/kitana-hw-cpu" --packages)
  if [ "${#cpu_packages[@]}" -eq 0 ]; then
    warn "No CPU microcode package detected by kitana-hw-cpu"
  else
    for pkg in "${cpu_packages[@]}"; do
      check_package "$pkg"
    done
  fi
fi

if [ -x "$KITANA_DIR/bin/kitana-hw-gpu" ]; then
  mapfile -t gpu_packages < <("$KITANA_DIR/bin/kitana-hw-gpu" --packages)
  mapfile -t gpu_tools < <("$KITANA_DIR/bin/kitana-hw-gpu" --tools)
  if [ "${#gpu_packages[@]}" -eq 0 ]; then
    warn "No GPU-specific packages detected by kitana-hw-gpu"
  else
    for pkg in "${gpu_packages[@]}"; do
      check_package "$pkg"
    done

    if printf '%s\n' "${gpu_packages[@]}" | grep -q '^vulkan-'; then
      if [ -d /usr/share/vulkan/icd.d ] && compgen -G '/usr/share/vulkan/icd.d/*.json' >/dev/null; then
        pass "Vulkan ICD files installed"
      else
        fail "Vulkan ICD files missing: /usr/share/vulkan/icd.d/*.json"
      fi
    fi
  fi

  if [ "${#gpu_tools[@]}" -eq 0 ]; then
    warn "No GPU diagnostic tools detected by kitana-hw-gpu"
  else
    for pkg in "${gpu_tools[@]}"; do
      check_package "$pkg"
    done

    if printf '%s\n' "${gpu_tools[@]}" | grep -q '^vulkan-tools$'; then
      if command -v vulkaninfo >/dev/null 2>&1; then
        pass "GPU diagnostic command: vulkaninfo"
      else
        warn "GPU diagnostic command missing: vulkaninfo"
      fi
    fi

    if printf '%s\n' "${gpu_tools[@]}" | grep -q '^libva-utils$'; then
      if command -v vainfo >/dev/null 2>&1; then
        pass "GPU diagnostic command: vainfo"
      else
        warn "GPU diagnostic command missing: vainfo"
      fi
    fi
  fi
fi

if [ -f "$KITANA_DIR/lib/kitana-theme.lua" ]; then
  pass "Kitana theme library: lib/kitana-theme.lua"
else
  fail "Kitana theme library missing: lib/kitana-theme.lua"
fi

if [ -f "$KITANA_DIR/themes/helpers/color.lua" ]; then
  pass "Kitana theme helper library: themes/helpers/color.lua"
  if LUA_PATH="$KITANA_DIR/?.lua;$KITANA_DIR/?/init.lua;;" lua -e 'local color = require("themes.helpers.color"); assert(color.mix("#000000", "#ffffff", 0.5) == "#808080"); assert(color.lighten("#000000", 0.25) == "#404040"); assert(color.darken("#ffffff", 0.25) == "#bfbfbf"); assert(color.alpha("#7aa2f7", "cc") == "#cc7aa2f7"); assert(color.strip("#7aa2f7") == "7aa2f7")'; then
    pass "Kitana color helper functions"
  else
    fail "Kitana color helper functions"
  fi
else
  fail "Kitana theme helper library missing: themes/helpers/color.lua"
fi

for theme in catppuccin-mocha rose-pine tokyo-night dracula kanagawa-dragon cyberdream; do
  if [ -f "$KITANA_DIR/themes/$theme.lua" ]; then
    pass "Kitana theme palette: themes/$theme.lua"
  else
    fail "Kitana theme palette missing: themes/$theme.lua"
  fi
done

for theme in catppuccin-mocha rose-pine tokyo-night dracula kanagawa-dragon cyberdream; do
  if [ -f "$KITANA_DIR/vendor/zed/$theme.json" ]; then
    pass "Kitana Zed upstream theme: vendor/zed/$theme.json"
  else
    fail "Kitana Zed upstream theme missing: vendor/zed/$theme.json"
  fi
done

if [ -f "$KITANA_DIR/vendor/ghostty/cyberdream" ]; then
  pass "Kitana Ghostty vendored theme: vendor/ghostty/cyberdream"
else
  fail "Kitana Ghostty vendored theme missing: vendor/ghostty/cyberdream"
fi

if [ -x "$KITANA_DIR/bin/kitana-wallpaper-grid" ]; then
  pass "Kitana wallpaper grid helper: bin/kitana-wallpaper-grid"
else
  fail "Kitana wallpaper grid helper missing or not executable: bin/kitana-wallpaper-grid"
fi

if [ -f "$KITANA_DIR/default/xcompose" ]; then
  pass "Kitana XCompose default: default/xcompose"
else
  fail "Kitana XCompose default missing: default/xcompose"
fi

if [ -f "$HOME/.XCompose" ]; then
  pass "XCompose config: ~/.XCompose"

  if grep -q '^<Multi_key> <m> <y> : "👍" # yes$' "$HOME/.XCompose" && grep -q '^<Multi_key> <space> <space> : "—"$' "$HOME/.XCompose"; then
    pass "XCompose Kitana defaults"
  else
    warn "XCompose Kitana defaults missing or customized: ~/.XCompose"
  fi

  if grep -q '^# Match Windows/macOS US-International behavior for Brazilian Portuguese\.$' "$HOME/.XCompose"; then
    if grep -q '^<dead_acute> <c> : "ç" ccedilla$' "$HOME/.XCompose" && grep -q '^<dead_acute> <C> : "Ç" Ccedilla$' "$HOME/.XCompose"; then
      pass "XCompose PT-BR overrides"
    else
      fail "XCompose PT-BR marker present but overrides missing: ~/.XCompose"
    fi
  fi
else
  warn "XCompose config missing: ~/.XCompose"
fi

echo

for browser_flags in brave-flags.conf chromium-flags.conf google-chrome-flags.conf; do
  check_file_contains "$HOME/.config/$browser_flags" '^# Kitana managed browser flags$' "Browser flags: ~/.config/$browser_flags" "Browser flags missing or unmanaged: ~/.config/$browser_flags"
  check_file_contains "$HOME/.config/$browser_flags" '^--ozone-platform-hint=wayland$' "Browser Wayland flag: $browser_flags" "Browser Wayland flag missing: ~/.config/$browser_flags"
  check_file_contains "$HOME/.config/$browser_flags" 'WebRTCPipeWireCapturer' "Browser PipeWire capture flag: $browser_flags" "Browser PipeWire capture flag missing: ~/.config/$browser_flags"
done

if [ -L "$HOME/.config/brave-origin-beta-flags.conf" ] && [ "$(readlink "$HOME/.config/brave-origin-beta-flags.conf")" = "brave-flags.conf" ]; then
  pass "Browser flags symlink: brave-origin-beta-flags.conf -> brave-flags.conf"
elif [ -e "$HOME/.config/brave-origin-beta-flags.conf" ]; then
  warn "Browser flags Brave beta path is not Kitana symlink: ~/.config/brave-origin-beta-flags.conf"
else
  fail "Browser flags Brave beta symlink missing: ~/.config/brave-origin-beta-flags.conf"
fi

if [ -d "$KITANA_DIR/applications/hidden" ]; then
  hidden_checked=0
  for hidden_desktop in "$KITANA_DIR"/applications/hidden/*.desktop; do
    [ -e "$hidden_desktop" ] || continue
    desktop_id="${hidden_desktop##*/}"
    hidden_source="$hidden_desktop"
    user_hidden_desktop="$HOME/.config/kitana/applications/hidden/$desktop_id"
    target_desktop="$HOME/.local/share/applications/$desktop_id"
    hidden_checked=1

    if [ -f "$user_hidden_desktop" ]; then
      hidden_source="$user_hidden_desktop"
    fi

    if grep -Eiq '^[[:space:]]*(NoDisplay|Hidden)[[:space:]]*=[[:space:]]*true[[:space:]]*$' "$hidden_source"; then
      if [ -f "$target_desktop" ] && grep -q '^NoDisplay=true$' "$target_desktop" && grep -q '^X-Kitana-Managed=true$' "$target_desktop"; then
        pass "Hidden desktop override: $desktop_id"
      else
        warn "Hidden desktop override missing or unmanaged: $target_desktop"
      fi
    elif [ -f "$user_hidden_desktop" ] && grep -Eiq '^[[:space:]]*(NoDisplay|Hidden)[[:space:]]*=[[:space:]]*false[[:space:]]*$' "$user_hidden_desktop"; then
      if [ ! -e "$target_desktop" ] || ! grep -q '^X-Kitana-Managed=true$' "$target_desktop"; then
        pass "Hidden desktop user override: $desktop_id"
      else
        warn "Hidden desktop user override not applied: $target_desktop"
      fi
    fi
  done

  if [ "$hidden_checked" -eq 0 ]; then
    warn "No Kitana hidden desktop defaults found"
  fi
else
  fail "Kitana hidden desktop defaults missing: applications/hidden"
fi

if [ -f "$KITANA_DIR/config/quickshell/kitana/Wallpaper/WallpaperGrid.qml" ]; then
  pass "Quickshell module: WallpaperGrid"
else
  fail "Quickshell module missing: WallpaperGrid"
fi

if [ -f "$HOME/.config/kitana/config" ]; then
  pass "Kitana config: ~/.config/kitana/config"
  env_wallpaper_dir="${KITANA_WALLPAPER_DIR:-}"
  # shellcheck disable=SC1090
  source "$HOME/.config/kitana/config"
  KITANA_WALLPAPER_DIR="${env_wallpaper_dir:-${KITANA_WALLPAPER_DIR:-$HOME/.config/kitana/wallpapers}}"
else
  fail "Kitana config missing: ~/.config/kitana/config"
  KITANA_WALLPAPER_DIR="${KITANA_WALLPAPER_DIR:-$HOME/.config/kitana/wallpapers}"
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

if [ -f "$KITANA_DIR/default/wallpapers/kitana-wallpaper-001.jpg" ]; then
  pass "Kitana default wallpaper"
else
  fail "Kitana default wallpaper missing"
fi

if [ -d "$KITANA_WALLPAPER_DIR" ]; then
  pass "Kitana wallpaper directory: $KITANA_WALLPAPER_DIR"
else
  fail "Kitana wallpaper directory missing: $KITANA_WALLPAPER_DIR"
fi

if [ -f "$HOME/.config/ghostty/config" ]; then
  pass "Ghostty config: ~/.config/ghostty/config"
else
  fail "Ghostty config missing: ~/.config/ghostty/config"
fi

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

for quickshell_config in shell.qml qmldir; do
  if [ -f "$HOME/.config/quickshell/kitana/$quickshell_config" ]; then
    pass "Quickshell config: $quickshell_config"
  else
    fail "Quickshell config missing: $quickshell_config"
  fi
done

if [ -f "$HOME/.config/quickshell/kitana/Config/Colors.qml" ] && [ -f "$HOME/.config/quickshell/kitana/Config/Icons.qml" ] && [ -f "$HOME/.config/quickshell/kitana/Config/Typography.qml" ]; then
  pass "Quickshell config tokens"
else
  fail "Quickshell config tokens missing"
fi

if grep -q '^singleton Colors 1.0 Config/Colors.qml$' "$HOME/.config/quickshell/kitana/qmldir" && grep -q '^singleton Icons 1.0 Config/Icons.qml$' "$HOME/.config/quickshell/kitana/qmldir" && grep -q '^singleton Typography 1.0 Config/Typography.qml$' "$HOME/.config/quickshell/kitana/qmldir"; then
  pass "Quickshell root singletons"
else
  fail "Quickshell root singletons missing"
fi

if grep -q 'readonly property var glyphs' "$KITANA_DIR/config/quickshell/kitana/Config/Icons.qml" && grep -q 'function toneColor' "$KITANA_DIR/config/quickshell/kitana/Config/Icons.qml" && grep -q 'function size' "$KITANA_DIR/config/quickshell/kitana/Config/Icons.qml" && grep -q 'function audioVolumeName' "$KITANA_DIR/config/quickshell/kitana/Config/Icons.qml"; then
  pass "Quickshell semantic icon registry"
else
  fail "Quickshell semantic icon registry missing"
fi

if grep -q 'text: Icons.glyph(name)' "$KITANA_DIR/config/quickshell/kitana/Components/Controls/Icon.qml" && grep -q 'color: Icons.toneColor(tone)' "$KITANA_DIR/config/quickshell/kitana/Components/Controls/Icon.qml" && grep -q 'Icons.size(sizeRole)' "$KITANA_DIR/config/quickshell/kitana/Components/Controls/Icon.qml"; then
  pass "Quickshell semantic icon renderer"
else
  fail "Quickshell semantic icon renderer missing"
fi

icon_font_usage=$(grep -R -l --include='*.qml' 'Typography\.iconFontFamily' "$KITANA_DIR/config/quickshell/kitana" "$HOME/.config/quickshell/kitana" 2>/dev/null | grep -v '/Components/Controls/Icon.qml$' || true)
legacy_icon_usage_re='iconText|text:[[:space:]]*Icons\.|icon:[[:space:]]*(Icons\.|Services\.(SystemStatus|CaffeineService|OsdService)\.[[:alnum:]_]*Icon([^[:alnum:]_]|$))'
legacy_icon_usage=$(grep -R -n -E --include='*.qml' "$legacy_icon_usage_re" "$KITANA_DIR/config/quickshell/kitana" "$HOME/.config/quickshell/kitana" 2>/dev/null | grep -v '/Components/Controls/Icon.qml:' || true)
if [ -z "$icon_font_usage" ] && [ -z "$legacy_icon_usage" ]; then
  pass "Quickshell semantic icon call sites"
else
  fail "Quickshell semantic icon call sites"
fi

if grep -q 'Config/Colors.qml' "$KITANA_DIR/bin/kitana-theme-quickshell" && grep -q 'Config/Colors.qml' "$KITANA_DIR/bin/kitana-quickshell"; then
  pass "Quickshell theme color target"
else
  fail "Quickshell theme color target mismatch"
fi

quickshell_colors="$KITANA_DIR/config/quickshell/kitana/Config/Colors.qml"
canonical_color_roles=(
  foreground foregroundStrong foregroundMuted foregroundSubtle foregroundDisabled foregroundInverted
  accent accentStrong foregroundOnAccent accentBackground accentSelectedBackground
  background surface surfaceContainer surfaceCard surfaceControl surfaceSubtle surfaceHover surfacePressed surfaceActive surfaceSelected surfaceFloating surfaceFloatingStrong
  border borderMuted borderStrong
  info success warning danger infoBackground successBackground warningBackground dangerBackground
  scrim scrimSoft imageOverlay shadow
)
missing_color_roles=()
for role in "${canonical_color_roles[@]}"; do
  if ! grep -q "readonly property color $role:" "$quickshell_colors"; then
    missing_color_roles+=("$role")
  fi
done

if [ "${#missing_color_roles[@]}" -eq 0 ]; then
  pass "Quickshell semantic color roles"
else
  fail "Quickshell semantic color roles missing: ${missing_color_roles[*]}"
fi

signal_handler_color_roles=$(grep -n -E 'readonly property color on[A-Z]' "$quickshell_colors" "$KITANA_DIR/bin/kitana-matugen" 2>/dev/null || true)
if [ -z "$signal_handler_color_roles" ]; then
  pass "Quickshell signal-handler color roles avoided"
else
  fail "Quickshell signal-handler color roles found"
fi

icon_color_roles=(
  iconPrimary iconSecondary iconMuted iconSubtle iconAccent iconOnAccent iconInverse iconBrand iconDisabled iconDanger
)
missing_icon_color_roles=()
for role in "${icon_color_roles[@]}"; do
  if ! grep -q "readonly property color $role:" "$quickshell_colors"; then
    missing_icon_color_roles+=("$role")
  fi
done

if [ "${#missing_icon_color_roles[@]}" -eq 0 ] && grep -q 'Kitana.Colors.iconPrimary' "$KITANA_DIR/config/quickshell/kitana/Config/Icons.qml" && grep -q 'Kitana.Colors.iconDanger' "$KITANA_DIR/config/quickshell/kitana/Config/Icons.qml"; then
  pass "Quickshell icon color roles"
else
  fail "Quickshell icon color roles missing or unused: ${missing_icon_color_roles[*]}"
fi

component_color_roles=(
  barBackground barForeground barHoverBackground barBorder
  panelBackground panelForeground panelBorder
  containerBackground containerForeground containerBorder
  cardBackground cardForeground cardBorder
  controlBackground controlForeground controlBorder controlSubtleBackground controlHoverBackground controlPressedBackground controlActiveBackground controlActiveForeground controlActiveBorder
  inputBackground inputForeground inputPlaceholderForeground inputBorder inputActiveBorder
  workspaceInactiveBackground workspaceInactiveForeground workspaceOccupiedBackground workspaceOccupiedForeground workspaceActiveBackground workspaceActiveForeground workspaceUrgentBackground workspaceUrgentForeground
)
missing_component_color_roles=()
for role in "${component_color_roles[@]}"; do
  if ! grep -q "readonly property color $role:" "$quickshell_colors"; then
    missing_component_color_roles+=("$role")
  fi
done

if [ "${#missing_component_color_roles[@]}" -eq 0 ]; then
  pass "Quickshell component color roles"
else
  fail "Quickshell component color roles missing: ${missing_component_color_roles[*]}"
fi

independent_color_role_re='readonly property color (foregroundOnAccent|surfaceActive|surfaceSelected|iconPrimary|iconSecondary|iconMuted|iconSubtle|iconAccent|iconOnAccent|iconInverse|iconBrand|iconDisabled|iconDanger|barBackground|barForeground|barHoverBackground|barBorder|panelBackground|panelForeground|panelBorder|containerBackground|containerForeground|containerBorder|cardBackground|cardForeground|cardBorder|controlBackground|controlForeground|controlBorder|controlSubtleBackground|controlHoverBackground|controlPressedBackground|controlActiveBackground|controlActiveForeground|controlActiveBorder|inputBackground|inputForeground|inputPlaceholderForeground|inputBorder|inputActiveBorder|workspaceInactiveBackground|workspaceInactiveForeground|workspaceOccupiedBackground|workspaceOccupiedForeground|workspaceActiveBackground|workspaceActiveForeground|workspaceUrgentBackground|workspaceUrgentForeground): [[:alpha:]_][[:alnum:]_]*$'
raw_color_role_ref_re=': (foreground|foregroundMuted|accent|foregroundOnAccent|border|borderStrong|borderFocus|surfaceCard|surfaceSubtle|danger)$'
linked_color_roles=$(grep -n -E "$independent_color_role_re" "$quickshell_colors" "$KITANA_DIR/bin/kitana-matugen" 2>/dev/null | grep -v -E "$raw_color_role_ref_re" || true)
if [ -z "$linked_color_roles" ]; then
  pass "Quickshell independently tunable color roles"
else
  fail "Quickshell independently tunable color roles are linked"
fi

migration_color_aliases=(
  primaryForeground secondaryForeground mutedForeground accentForeground onAccentForeground
  infoForeground successForeground warningForeground dangerForeground
  primaryBackground secondaryBackground mutedBackground
  panelContainerBackground panelContainerForeground panelContainerBorder
  panelCardBackground panelCardForeground panelCardBorder
  panelButtonBackground panelButtonBackgroundSubtle panelButtonBackgroundHover panelButtonBackgroundActive panelButtonForeground panelButtonBorder panelButtonBorderActive
  panelInputBackground panelInputForeground panelInputBorder panelInputBorderActive
)
cleanup_color_alias_names="$(IFS='|'; printf '%s' "${migration_color_aliases[*]}")"
cleanup_color_alias_definition_re="Migration aliases|readonly property color ($cleanup_color_alias_names):"
cleanup_color_alias_definitions=$(grep -n -E "$cleanup_color_alias_definition_re" "$quickshell_colors" "$KITANA_DIR/bin/kitana-matugen" "$HOME/.config/quickshell/kitana/Config/Colors.qml" 2>/dev/null || true)
if [ -z "$cleanup_color_alias_definitions" ]; then
  pass "Quickshell cleanup color aliases removed"
else
  fail "Quickshell cleanup color aliases still defined"
fi

cleanup_color_alias_re="Colors\.($cleanup_color_alias_names)([^[:alnum:]_]|$)"
cleanup_color_alias_usage=$(grep -R -n -E --include='*.qml' "$cleanup_color_alias_re" "$KITANA_DIR/config/quickshell/kitana" "$HOME/.config/quickshell/kitana" 2>/dev/null | grep -v '/Config/Colors.qml:' || true)
if [ -z "$cleanup_color_alias_usage" ]; then
  pass "Quickshell cleanup color alias call sites"
else
  fail "Quickshell cleanup color alias call sites remain"
fi

generated_color_roles=(
  foreground foregroundStrong foregroundMuted foregroundSubtle foregroundInverted
  accent accentStrong foregroundOnAccent
  background surface surfaceContainer surfaceCard surfaceControl surfaceSubtle surfaceHover surfacePressed surfaceActive surfaceSelected surfaceFloating surfaceFloatingStrong
  border borderMuted borderStrong borderFocus
  info success warning danger
  iconPrimary iconSecondary iconMuted iconSubtle iconAccent iconOnAccent iconInverse iconBrand iconDanger
)

generated_alpha_color_roles=(
  iconDisabled
)

validate_quickshell_colors_file() {
  local file="$1"
  local label="$2"
  local missing_roles=()
  local invalid_generated=()
  local role
  local field

  if [ ! -f "$file" ]; then
    fail "$label missing: $file"
    return
  fi

  for role in "${canonical_color_roles[@]}" "${icon_color_roles[@]}" "${component_color_roles[@]}"; do
    if ! grep -q "readonly property color $role:" "$file"; then
      missing_roles+=("$role")
    fi
  done

  if [ "${#missing_roles[@]}" -eq 0 ]; then
    pass "$label semantic roles"
  else
    fail "$label semantic roles missing: ${missing_roles[*]}"
  fi

  for field in "${generated_color_roles[@]}"; do
    if ! grep -Eq "readonly property color $field: \"#[0-9a-fA-F]{6}\"" "$file"; then
      invalid_generated+=("$field")
    fi
  done

  for field in "${generated_alpha_color_roles[@]}"; do
    if ! grep -Eq "readonly property color $field: withAlpha\(\"#[0-9a-fA-F]{6}\", [0-9]+\)" "$file"; then
      invalid_generated+=("$field")
    fi
  done

  if [ "${#invalid_generated[@]}" -eq 0 ]; then
    pass "$label generated color roles"
  else
    fail "$label generated color roles invalid: ${invalid_generated[*]}"
  fi

  if grep -E "$cleanup_color_alias_definition_re" "$file" >/dev/null 2>&1; then
    fail "$label cleanup aliases removed"
  else
    pass "$label cleanup aliases removed"
  fi

}

theme_audit_home="$(mktemp -d)"
theme_audit_target="$theme_audit_home/.config/quickshell/kitana/Config/Colors.qml"

for theme in catppuccin-mocha rose-pine tokyo-night dracula kanagawa-dragon cyberdream; do
  if HOME="$theme_audit_home" KITANA_DIR="$KITANA_DIR" "$KITANA_DIR/bin/kitana-theme-quickshell" "$theme" >/dev/null 2>&1; then
    validate_quickshell_colors_file "$theme_audit_target" "Quickshell theme colors: $theme"
  else
    fail "Quickshell theme colors generation failed: $theme"
  fi
done

if HOME="$theme_audit_home" KITANA_DIR="$KITANA_DIR" KITANA_NO_RELOAD=1 "$KITANA_DIR/bin/kitana-matugen" '#89b4fa' >/dev/null 2>&1; then
  validate_quickshell_colors_file "$theme_audit_target" "Quickshell matugen hex colors"
else
  fail "Quickshell matugen hex colors generation failed"
fi

rm -rf "$theme_audit_home"

matugen_icon_role_count=$(grep -c 'readonly property color iconPrimary:' "$KITANA_DIR/bin/kitana-matugen")
matugen_component_role_count=$(grep -c 'readonly property color barHoverBackground:' "$KITANA_DIR/bin/kitana-matugen")
if [ "$matugen_icon_role_count" -ge 1 ] && [ "$matugen_component_role_count" -ge 1 ]; then
  pass "Quickshell matugen color framework parity"
else
  fail "Quickshell matugen color framework parity missing"
fi

raw_palette_usage_re='Colors\.(crust[01]|mantle[01]|base[01]|surface[01]|overlay[01]|subtext[01]|text[01]|accent[01]|info0|success0|warning0|danger0)([^[:alnum:]_]|$)'
raw_palette_usage=$(grep -R -n -E --include='*.qml' "$raw_palette_usage_re" "$KITANA_DIR/config/quickshell/kitana" "$HOME/.config/quickshell/kitana" 2>/dev/null | grep -v '/Config/Colors.qml:' || true)
if [ -z "$raw_palette_usage" ]; then
  pass "Quickshell raw palette use contained"
else
  fail "Quickshell raw palette use outside Config/Colors.qml"
fi

if [ ! -f "$HOME/.config/quickshell/kitana/Colors.qml" ]; then
  pass "Quickshell legacy color target removed"
elif grep -q "Kitana managed Quickshell colors" "$HOME/.config/quickshell/kitana/Colors.qml"; then
  fail "Quickshell legacy color target still present"
else
  pass "Quickshell legacy color target user-owned"
fi

quickshell_files=(
  Bar/BarWindow.qml
  Bar/StartMenu.qml
  Bar/Items/DateTime.qml
  Bar/Items/Layout.qml
  Bar/Items/Screenshot.qml
  Bar/Items/Session.qml
  Bar/Items/Start.qml
  Bar/Items/Status.qml
  Bar/Items/Workspaces.qml
  Bar/Sections/Center.qml
  Bar/Sections/Left.qml
  Bar/Sections/Right.qml
  Components/Controls/BlurredBackdrop.qml
  Components/Controls/KeyHintBar.qml
  Components/Controls/Icon.qml
  Components/Controls/PanelRow.qml
  Dashboard/DashboardPanel.qml
  Launcher/AppLauncher.qml
  Notifications/NotificationPopups.qml
  OSD/OsdPopup.qml
  Screenshot/ScreenshotPanel.qml
  Session/SessionPanel.qml
  Shortcuts/ShortcutsPanel.qml
  Settings/SettingsPanel.qml
  System/SystemPanel.qml
  Wallpaper/WallpaperGrid.qml
)

for quickshell_file in "${quickshell_files[@]}"; do
  if [ -f "$HOME/.config/quickshell/kitana/$quickshell_file" ]; then
    pass "Quickshell file: $quickshell_file"
  else
    fail "Quickshell file missing: $quickshell_file"
  fi
done

quickshell_dashboard_modules=(
  CavaBars
  DashboardField
  DateTimeTab
  MediaButton
  MediaDeviceRow
  MediaTab
  MiniButton
  PickerFooter
  PickerHelp
  PickerTopInset
  SettingsTab
  TabButton
  ThemesTab
  TodayFact
  VolumeSlider
  WallpapersTab
  WeatherMetric
  WeatherTab
  WorldClockRow
)

for quickshell_module in "${quickshell_dashboard_modules[@]}"; do
  if [ -f "$HOME/.config/quickshell/kitana/Dashboard/Tabs/$quickshell_module.qml" ] || [ -f "$HOME/.config/quickshell/kitana/Dashboard/Components/$quickshell_module.qml" ]; then
    pass "Quickshell dashboard module: $quickshell_module"
  else
    fail "Quickshell dashboard module missing: $quickshell_module"
  fi
done

quickshell_system_modules=(
  AudioPane
  BluetoothDeviceRow
  BluetoothPane
  CompactIconTile
  ConfirmButton
  ConfirmOverlay
  ControlSliders
  DetailList
  DetailRow
  HeaderIcon
  NetworkPane
  NotificationRow
  NotificationsPane
  PanelHeader
  QuickSettingsGrid
  QuickTile
  SessionPane
  SettingsPane
  SliderRow
)

for quickshell_module in "${quickshell_system_modules[@]}"; do
  if [ -f "$HOME/.config/quickshell/kitana/System/Panes/$quickshell_module.qml" ] || [ -f "$HOME/.config/quickshell/kitana/System/Components/$quickshell_module.qml" ]; then
    pass "Quickshell system module: $quickshell_module"
  else
    fail "Quickshell system module missing: $quickshell_module"
  fi
done

if [ -f "$HOME/.config/quickshell/kitana/Services/SystemStatus.qml" ] && [ -f "$HOME/.config/quickshell/kitana/Services/qmldir" ]; then
  pass "Quickshell service: SystemStatus"
else
  fail "Quickshell service missing: SystemStatus"
fi

if [ -f "$HOME/.config/quickshell/kitana/Services/NotificationService.qml" ]; then
  pass "Quickshell service: NotificationService"
else
  fail "Quickshell service missing: NotificationService"
fi

if [ -f "$HOME/.config/quickshell/kitana/Services/AppSearchService.qml" ] && grep -q '^singleton AppSearchService 1.0 AppSearchService.qml$' "$HOME/.config/quickshell/kitana/Services/qmldir"; then
  pass "Quickshell service: AppSearchService"
else
  fail "Quickshell service missing: AppSearchService"
fi

if [ -f "$HOME/.config/quickshell/kitana/Services/CaffeineService.qml" ] && grep -q '^singleton CaffeineService 1.0 CaffeineService.qml$' "$HOME/.config/quickshell/kitana/Services/qmldir"; then
  pass "Quickshell service: CaffeineService"
else
  fail "Quickshell service missing: CaffeineService"
fi

if [ -f "$HOME/.config/quickshell/kitana/Services/UiPreferences.qml" ] && grep -q '^singleton UiPreferences 1.0 UiPreferences.qml$' "$HOME/.config/quickshell/kitana/Services/qmldir"; then
  pass "Quickshell service: UiPreferences"
else
  fail "Quickshell service missing: UiPreferences"
fi

if [ -f "$HOME/.config/quickshell/kitana/shell.qml" ] && grep -q 'target: "kitana-bar"' "$HOME/.config/quickshell/kitana/shell.qml"; then
  pass "Quickshell IPC: kitana-bar"
else
  fail "Quickshell IPC missing: kitana-bar"
fi

if [ -f "$HOME/.config/quickshell/kitana/shell.qml" ] && grep -q 'target: "kitana-shell"' "$HOME/.config/quickshell/kitana/shell.qml"; then
  pass "Quickshell IPC: kitana-shell"
else
  fail "Quickshell IPC missing: kitana-shell"
fi

if [ -f "$HOME/.config/quickshell/kitana/shell.qml" ] && grep -q 'function refreshWorkspaces' "$HOME/.config/quickshell/kitana/shell.qml" && grep -q 'Hyprland.refreshWorkspaces' "$HOME/.config/quickshell/kitana/shell.qml"; then
  pass "Quickshell IPC: kitana-shell refreshWorkspaces"
else
  fail "Quickshell IPC missing: kitana-shell refreshWorkspaces"
fi

if [ -f "$HOME/.config/quickshell/kitana/Settings/SettingsPanel.qml" ] && grep -q 'target: "kitana-settings"' "$HOME/.config/quickshell/kitana/Settings/SettingsPanel.qml"; then
  pass "Quickshell IPC: kitana-settings"
else
  fail "Quickshell IPC missing: kitana-settings"
fi

if [ -f "$HOME/.config/quickshell/kitana/Session/SessionPanel.qml" ] && grep -q 'target: "kitana-session"' "$HOME/.config/quickshell/kitana/Session/SessionPanel.qml"; then
  pass "Quickshell IPC: kitana-session"
else
  fail "Quickshell IPC missing: kitana-session"
fi

if [ -f "$HOME/.config/quickshell/kitana/Services/MediaService.qml" ] && grep -q '^singleton MediaService 1.0 MediaService.qml$' "$HOME/.config/quickshell/kitana/Services/qmldir"; then
  pass "Quickshell service: MediaService"
else
  fail "Quickshell service missing: MediaService"
fi

if [ -f "$HOME/.config/quickshell/kitana/Services/OsdService.qml" ] && grep -q '^singleton OsdService 1.0 OsdService.qml$' "$HOME/.config/quickshell/kitana/Services/qmldir"; then
  pass "Quickshell service: OsdService"
else
  fail "Quickshell service missing: OsdService"
fi

if [ -f "$HOME/.config/quickshell/kitana/shell.qml" ] && grep -q 'target: "kitana-osd"' "$HOME/.config/quickshell/kitana/shell.qml"; then
  pass "Quickshell IPC: kitana-osd"
else
  fail "Quickshell IPC missing: kitana-osd"
fi

if [ -f "$HOME/.config/quickshell/kitana/Shortcuts/ShortcutsPanel.qml" ] && grep -q 'target: "kitana-shortcuts"' "$HOME/.config/quickshell/kitana/Shortcuts/ShortcutsPanel.qml"; then
  pass "Quickshell IPC: kitana-shortcuts"
else
  fail "Quickshell IPC missing: kitana-shortcuts"
fi

if [ -f "$HOME/.config/quickshell/kitana/shell.qml" ] && grep -q 'target: "kitana-screenshot"' "$HOME/.config/quickshell/kitana/shell.qml"; then
  pass "Quickshell IPC: kitana-screenshot"
else
  fail "Quickshell IPC missing: kitana-screenshot"
fi

if [ -f "$HOME/.config/quickshell/kitana/custom/Settings.qml" ]; then
  pass "Quickshell custom settings"
else
  fail "Quickshell custom settings missing"
fi

if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  if pgrep -x awww-daemon >/dev/null 2>&1; then
    pass "process active: awww-daemon"
  else
    fail "awww-daemon is not running"
  fi

  if pgrep -x quickshell >/dev/null 2>&1; then
    pass "process active: quickshell"
  else
    fail "quickshell is not running"
  fi
fi

if command -v luac >/dev/null 2>&1; then
  if luac -p "$KITANA_DIR/config/hypr/hyprland.lua" "$KITANA_DIR/config/hypr/kitana-theme.lua" "$KITANA_DIR/default/sddm/hyprland.lua" "$KITANA_DIR"/default/hypr/modules/*.lua "$KITANA_DIR"/default/hypr/apps/*.lua "$KITANA_DIR"/default/hypr/profiles/*.lua; then
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

  if [ "$(xdg-mime query default application/pdf 2>/dev/null || true)" = "org.gnome.Papers.desktop" ]; then
    pass "Default PDF handler: org.gnome.Papers.desktop"
  else
    fail "Default PDF handler is not Papers: $(xdg-mime query default application/pdf 2>/dev/null || true)"
  fi
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
