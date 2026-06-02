#!/bin/bash

echo "Checking personal Neovim config..."

KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"

# shellcheck source=../lib/extras.sh
source "$KITANA_DIR/install/lib/extras.sh"

if ! kitana_has_extra nvim; then
  echo "Skipping personal Neovim config. Set KITANA_EXTRAS=nvim or KITANA_EXTRAS=all to install it."
  return 0 2>/dev/null || exit 0
fi

repo_url="${KITANA_NVIM_REPO:-https://github.com/gldtn/nvim.git}"
nvim_dir="$HOME/.config/nvim"

mkdir -p "$HOME/.config"

if [ -d "$nvim_dir/.git" ]; then
  origin_url="$(git -C "$nvim_dir" remote get-url origin 2>/dev/null || true)"
  if [ "$origin_url" = "$repo_url" ] || [ "$origin_url" = "git@github.com:gldtn/nvim.git" ]; then
    git -C "$nvim_dir" pull --ff-only
  else
    echo "Keeping existing Neovim config with different origin: $origin_url"
  fi
elif [ -e "$nvim_dir" ]; then
  echo "Keeping existing Neovim config: $nvim_dir"
else
  git clone "$repo_url" "$nvim_dir"
fi
