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

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
