#!/bin/bash

echo "Installing CLI tools..."

PACKAGES=(
  bash-completion
  bat
  curl
  eza
  fastfetch
  fd
  fzf
  gzip
  jq
  less
  man-db
  plocate
  ripgrep
  starship
  tldr
  unzip
  wget
  whois
  zoxide
)

kitana_install_required_packages "desktop/cli" "${PACKAGES[@]}" || exit 1
