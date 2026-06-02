#!/bin/bash

echo "Checking Git identity..."

current_name="$(git config --global user.name 2>/dev/null || true)"
current_email="$(git config --global user.email 2>/dev/null || true)"

if [ -n "$current_name" ] && [ -n "$current_email" ]; then
  echo "Keeping existing Git identity: $current_name <$current_email>"
  return 0 2>/dev/null || exit 0
fi

name="${KITANA_GIT_NAME:-}"
email="${KITANA_GIT_EMAIL:-}"

if [ -z "$name" ] && ! kitana_is_unattended && command -v gum >/dev/null 2>&1; then
  name="$(gum input --prompt "Git name> " --placeholder "Your Name")"
fi

if [ -z "$email" ] && ! kitana_is_unattended && command -v gum >/dev/null 2>&1; then
  email="$(gum input --prompt "Git email> " --placeholder "you@example.com")"
fi

if [ -n "$name" ] && [ -n "$email" ]; then
  git config --global user.name "$name"
  git config --global user.email "$email"
else
  echo "Skipping Git identity. Set KITANA_GIT_NAME and KITANA_GIT_EMAIL for unattended installs."
  kitana_log_failure "apps/git-config" "git-identity" "git config --global user.name/user.email" "1" "git config --global user.name 'Your Name'; git config --global user.email you@example.com"
fi
