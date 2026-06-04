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
  man
  plocate
  ripgrep
  starship
  tldr
  unzip
  wget
  whois
  zoxide
  zsh
  zsh-completion
)

kitana_install_required_packages "desktop/cli" "${PACKAGES[@]}" || exit 1
