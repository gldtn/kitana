#!/bin/bash

# Bootstrap script for Kitana - Custom Arch/Hyprland Setup by gldtn
# Run as: curl -sL https://raw.githubusercontent.com/gldtn/kitana/master/bootstrap.sh | bash -s -- [full|desktop|apps|configs]
# Assumes fresh Arch install with sudo user.

set -e

MODE="${1:-full}"
KITANA_DIR="$HOME/.local/share/kitana"

LOGO_URL="https://raw.githubusercontent.com/gldtn/kitana/master/logo.txt"
echo
curl -fsSL "$LOGO_URL" || true
echo

# Install git if not present
pacman -Q git &>/dev/null || sudo pacman -Sy --noconfirm --needed git

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

echo -e "\nInstallation mode: $MODE"

case "$MODE" in
  full)
    bash "$KITANA_DIR/install.sh"
    ;;
  desktop)
    bash "$KITANA_DIR/install-desktop.sh"
    ;;
  apps)
    bash "$KITANA_DIR/install-apps.sh"
    ;;
  configs)
    bash "$KITANA_DIR/install/desktop/configs.sh"
    ;;
  *)
    echo "Usage: bootstrap.sh [full|desktop|apps|configs]"
    exit 1
    ;;
esac
