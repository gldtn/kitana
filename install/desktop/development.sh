#!/bin/bash

echo "Installing development packages..."

PACKAGES=(
  clang
  composer
  gcc
  git
  github-cli
  go
  lazygit
  llvm
  luarocks
  luajit
  mariadb-libs
  mise
  nginx
  npm
  php
  postgresql-libs
  tree-sitter-cli
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
