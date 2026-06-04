#!/bin/bash

echo "Installing development packages..."

PACKAGES=(
  clang
  composer
  dart-sass
  gcc
  git
  github-cli
  go
  lazygit
  llvm
  luarocks
  luajit
  mise
  npm
  tree-sitter-cli
)

kitana_install_required_packages "desktop/development" "${PACKAGES[@]}" || exit 1
