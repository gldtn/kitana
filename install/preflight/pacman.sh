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

repair_corrupted_pacman_cache() {
  local log_file="$1"
  local repaired=0
  local package_file

  while read -r package_file; do
    [ -n "$package_file" ] || continue
    case "$package_file" in
      /var/cache/pacman/pkg/*)
        echo "Removing corrupted cached package: $package_file"
        sudo rm -f "$package_file" "$package_file.sig"
        repaired=1
        ;;
    esac
  done < <(grep -Eo '/var/cache/pacman/pkg/[^ ]+' "$log_file" | sed 's/[.:,;)]$//' | sort -u)

  [ "$repaired" -eq 1 ]
}

run_pacman_with_cache_repair() {
  local phase="$1"
  local item="$2"
  local manual="$3"
  shift 3

  local command=("$@")
  local log_file exit_code
  log_file="$(mktemp)"

  if "${command[@]}" > >(tee "$log_file") 2>&1; then
    rm -f "$log_file"
    return 0
  fi

  exit_code="$?"

  if grep -qiE 'invalid or corrupted package|is corrupted' "$log_file" && repair_corrupted_pacman_cache "$log_file"; then
    echo "Refreshing Arch keyring before retrying pacman..."
    sudo pacman -Sy --noconfirm --needed archlinux-keyring || true

    if "${command[@]}" > >(tee "$log_file.retry") 2>&1; then
      rm -f "$log_file" "$log_file.retry"
      return 0
    fi

    exit_code="$?"
    log_file="$log_file.retry"
  fi

  kitana_log_failure "$phase" "$item" "${command[*]}" "$exit_code" "$manual" "$log_file"
  exit "$exit_code"
}

run_pacman_with_cache_repair \
  "preflight/pacman" \
  "keyring" \
  "sudo pacman -Sy archlinux-keyring" \
  sudo pacman -Sy --noconfirm --needed archlinux-keyring

run_pacman_with_cache_repair \
  "preflight/pacman" \
  "packages" \
  "sudo pacman -Syu" \
  sudo pacman -Syu --noconfirm --needed "${PREFLIGHT_PACKAGES[@]}"

if sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist; then
  run_pacman_with_cache_repair \
    "preflight/pacman" \
    "mirror-sync" \
    "sudo pacman -Syyu" \
    sudo pacman -Syyu --noconfirm
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
