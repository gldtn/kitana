#!/bin/bash

echo "Checking sudoers wheel configuration..."

if grep -Eq '^%wheel[[:space:]]+ALL=\(ALL(:ALL)?\)[[:space:]]+ALL' /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
  echo "Wheel sudo is already enabled."
  return 0 2>/dev/null || exit 0
fi

if command -v gum >/dev/null 2>&1; then
  if ! gum confirm "Enable sudo for users in the wheel group?"; then
    echo "Skipping sudoers wheel configuration."
    return 0 2>/dev/null || exit 0
  fi
fi

tmp="$(mktemp)"

printf '%%wheel ALL=(ALL:ALL) ALL\n' >"$tmp"

if sudo visudo -cf "$tmp" >/dev/null; then
  sudo install -m 0440 "$tmp" /etc/sudoers.d/00-kitana-wheel
else
  echo "Could not validate sudoers wheel configuration."
  kitana_log_failure "preflight/sudoers" "wheel" "visudo -cf" "1" "sudo visudo"
fi

rm -f "$tmp"
