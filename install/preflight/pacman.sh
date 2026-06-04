#!/bin/bash

echo "Preparing pacman, mirrors, and AUR helper..."

kitana_start_sudo_keepalive

if ! grep -q '^ILoveCandy$' /etc/pacman.conf; then
  sudo sed -i '/^\[options\]/a ILoveCandy' /etc/pacman.conf
fi

PREFLIGHT_PACKAGES=(
  base-devel
  git
  gum
  reflector
  rsync
)

if sudo pacman -Syu --noconfirm --needed "${PREFLIGHT_PACKAGES[@]}"; then
  :
else
  exit_code=$?
  kitana_log_failure "preflight/pacman" "packages" "sudo pacman -Syu --noconfirm --needed ${PREFLIGHT_PACKAGES[*]}" "$exit_code" "sudo pacman -Syu"
  exit "$exit_code"
fi

if sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist; then
  if sudo pacman -Syyu --noconfirm; then
    :
  else
    exit_code=$?
    kitana_log_failure "preflight/pacman" "mirror-sync" "sudo pacman -Syyu --noconfirm" "$exit_code" "sudo pacman -Syyu"
    exit "$exit_code"
  fi
else
  exit_code=$?
  kitana_log_failure "preflight/pacman" "reflector" "sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist" "$exit_code" "sudo reflector"
  echo "WARNING: reflector failed; continuing with the current pacman mirrorlist."
fi

if ! command -v yay >/dev/null 2>&1; then
  echo "Installing yay..."
  yay_build_dir="$(mktemp -d)"

  if git clone https://aur.archlinux.org/yay.git "$yay_build_dir"; then
    :
  else
    exit_code=$?
    kitana_log_failure "preflight/pacman" "yay-clone" "git clone https://aur.archlinux.org/yay.git" "$exit_code" "git clone https://aur.archlinux.org/yay.git /tmp/yay"
    rm -rf "$yay_build_dir"
    exit "$exit_code"
  fi

  if makepkg -si --noconfirm -D "$yay_build_dir"; then
    :
  else
    exit_code=$?
    kitana_log_failure "preflight/pacman" "yay" "makepkg -si --noconfirm -D $yay_build_dir" "$exit_code" "git clone https://aur.archlinux.org/yay.git /tmp/yay; cd /tmp/yay; makepkg -si"
    rm -rf "$yay_build_dir"
    exit "$exit_code"
  fi

  rm -rf "$yay_build_dir"
fi
