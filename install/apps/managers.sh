#!/bin/bash

echo "Installing connectivity and system managers..."

PACKAGES=(
  btop
  wiremix
)

kitana_install_required_packages "apps/managers" "${PACKAGES[@]}" || exit 1
