#!/bin/bash

echo "Checking wallpaper extras..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"

# shellcheck source=../lib/extras.sh
source "$KITANA_DIR/install/lib/extras.sh"

if ! kitana_has_extra walls; then
  echo "Skipping wallpaper extras. Set KITANA_EXTRAS=walls or KITANA_EXTRAS=all to install them."
  return 0 2>/dev/null || exit 0
fi

repo_url="${KITANA_WALLPAPER_EXTRAS_REPO:-https://github.com/gldtn/kitana-wallpapers-extras.git}"
repo_dir="${KITANA_WALLPAPER_EXTRAS_DIR:-$HOME/.local/share/kitana-wallpapers-extras}"
wallpaper_dir="${KITANA_WALLPAPER_DIR:-$HOME/.config/kitana/wallpapers}"

mkdir -p "$(dirname "$repo_dir")" "$wallpaper_dir"

if [ -d "$repo_dir/.git" ]; then
  git -C "$repo_dir" pull --ff-only
else
  git clone "$repo_url" "$repo_dir"
fi

if [ -x "$repo_dir/install.sh" ]; then
  KITANA_WALLPAPER_DIR="$wallpaper_dir" "$repo_dir/install.sh"
else
  for wallpaper in "$repo_dir"/wallpapers/*; do
    [ -e "$wallpaper" ] || continue
    target="$wallpaper_dir/$(basename "$wallpaper")"
    if [ ! -e "$target" ] || [ -L "$target" ]; then
      ln -sfn "$wallpaper" "$target"
    else
      echo "Keeping existing wallpaper: $target"
    fi
  done
fi
