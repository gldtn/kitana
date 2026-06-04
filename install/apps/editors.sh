#!/bin/bash

echo "Installing editor apps..."

PACKAGES=(
  neovim
  zed
)

kitana_install_required_packages "apps/editors" "${PACKAGES[@]}" || exit 1
