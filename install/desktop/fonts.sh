#!/bin/bash

echo "Installing fonts..."

PACKAGES=(
  curl
  gnome-font-viewer
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  noto-fonts-extra
  otf-font-awesome
  ttf-cascadia-mono-nerd
  ttf-jetbrains-mono-nerd
  ttf-material-symbols-variable-git
  unzip
)

kitana_install_required_packages "desktop/fonts" "${PACKAGES[@]}" || exit 1

install_ioskeley_fonts() {
  local version="v2.0.0"
  local base_url="https://github.com/ahatem/IoskeleyMono/releases/download/$version"
  local font_dir="$HOME/.local/share/fonts/ioskeley"
  local work_dir

  echo "Installing Ioskeley Mono fonts..."

  work_dir="$(mktemp -d)"
  mkdir -p "$font_dir"

  local editor_zip="$work_dir/IoskeleyMono.zip"
  local terminal_zip="$work_dir/IoskeleyMono-Term-NerdFont.zip"
  local editor_dir="$work_dir/IoskeleyMono"
  local terminal_dir="$work_dir/IoskeleyMono-Term-NerdFont"

  if ! curl -fsSL "$base_url/IoskeleyMono.zip" -o "$editor_zip"; then
    rm -rf "$work_dir"
    return 1
  fi

  if ! curl -fsSL "$base_url/IoskeleyMono-Term-NerdFont.zip" -o "$terminal_zip"; then
    rm -rf "$work_dir"
    return 1
  fi

  if ! unzip -q -o "$editor_zip" -d "$editor_dir"; then
    rm -rf "$work_dir"
    return 1
  fi

  if ! unzip -q -o "$terminal_zip" -d "$terminal_dir"; then
    rm -rf "$work_dir"
    return 1
  fi

  if ! cp -f "$editor_dir/Normal/Unhinted/"*.ttf "$font_dir/"; then
    rm -rf "$work_dir"
    return 1
  fi

  if ! cp -f "$terminal_dir/Normal/"*.ttf "$font_dir/"; then
    rm -rf "$work_dir"
    return 1
  fi

  rm -rf "$work_dir"
  fc-cache -f "$HOME/.local/share/fonts" || return 1
}

install_ioskeley_fonts || exit 1
