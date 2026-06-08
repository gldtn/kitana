#!/bin/bash

# Bootstrap script for Kitana - Custom Arch/Hyprland Setup by gldtn
# Run as: curl -sL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | bash
# Assumes fresh Arch install with sudo user.

set -e

KITANA_DIR="$HOME/.local/share/kitana"
KITANA_INSTALL="$KITANA_DIR/install"

LOGO_URL="https://raw.githubusercontent.com/gldtn/kitana/master/logo.txt"
echo
curl -fsSL "$LOGO_URL" || true
echo

# Install git if not present. Refresh the keyring first to avoid stale
# signature failures on fresh or partially updated Arch installs.
pacman -Q git &>/dev/null || sudo pacman -Sy --noconfirm --needed archlinux-keyring git

if [ -d "$KITANA_DIR/.git" ]; then
  echo -e "\nUpdating Kitana..."
  git -C "$KITANA_DIR" fetch origin
  git -C "$KITANA_DIR" reset --hard "origin/${KITANA_REF:-master}"
  git -C "$KITANA_DIR" clean -fd
else
  echo -e "\nCloning Kitana..."
  rm -rf "$KITANA_DIR"
  git clone https://github.com/gldtn/kitana.git "$KITANA_DIR" >/dev/null
fi

# Use custom branch if instructed
if [[ -n "$KITANA_REF" ]]; then
  echo -e "Using branch: $KITANA_REF"
  git -C "$KITANA_DIR" fetch origin "${KITANA_REF}"
  git -C "$KITANA_DIR" checkout "${KITANA_REF}"
fi

export KITANA_DIR KITANA_INSTALL
export PATH="$KITANA_DIR/bin:$PATH"

echo -e "\nRunning full Kitana install..."
bash "$KITANA_DIR/install.sh"
