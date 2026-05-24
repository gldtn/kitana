#!/bin/bash

# Bootstrap script for Kitana - Custom Arch/Hyprland Setup
# Run as: curl -sL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | bash
# Assumes fresh Arch install with sudo user.

LOGO_URL="https://raw.githubusercontent.com/gldtn/kitana/master/logo.txt"
echo
curl -fsSL "$LOGO_URL" || true
echo

# Install git if not present
pacman -Q git &>/dev/null || sudo pacman -Sy --noconfirm --needed git

echo -e "\nCloning Kitana..."
rm -rf ~/.local/share/kitana/
git clone https://github.com/gldtn/kitana.git ~/.local/share/kitana >/dev/null

# Use custom branch if instructed
if [[ -n "$KITANA_REF" ]]; then
  echo -e "Using branch: $KITANA_REF"
  cd ~/.local/share/kitana
  git fetch origin "${KITANA_REF}" && git checkout "${KITANA_REF}"
  cd -
fi

echo -e "\nInstallation starting..."
source ~/.local/share/kitana/install.sh
