#!/bin/bash

echo "Installing DE essentials packages..."

PACKAGES=(
  awww
  bluez
  bluez-utils
  brightnessctl
  ddcutil
  grim
  inetutils
  iwd
  pamixer
  playerctl
  polkit
  quickshell
  satty
  sddm
  slurp
  swaync
  udiskie
  vicinae-bin
  xdg-desktop-portal-gtk
  xdg-user-dirs
  xdg-utils
  wl-clip-persist
  wl-clipboard
  wl-screenrec
)

for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done

mkdir -p \
  "$HOME/.config" \
  "$HOME/Documents" \
  "$HOME/Downloads" \
  "$HOME/Pictures" \
  "$HOME/Media/music" \
  "$HOME/Media/videos"

if [ ! -e "$HOME/.config/user-dirs.dirs" ]; then
  cat >"$HOME/.config/user-dirs.dirs" <<EOF
XDG_DESKTOP_DIR="$HOME"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_MUSIC_DIR="$HOME/Media/music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_PUBLICSHARE_DIR="$HOME"
XDG_TEMPLATES_DIR="$HOME"
XDG_VIDEOS_DIR="$HOME/Media/videos"
EOF
fi

sudo systemctl enable --now iwd.service bluetooth.service
sudo systemctl enable --now sddm.service

sudo mkdir -p /etc/systemd/system/systemd-networkd-wait-online.service.d
sudo tee /etc/systemd/system/systemd-networkd-wait-online.service.d/wait-for-only-one-interface.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --any
EOF
