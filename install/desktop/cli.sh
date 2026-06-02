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

for pkg in "${PACKAGES[@]}"; do
  kitana_install_required "desktop/cli" "$pkg" || exit 1
done
