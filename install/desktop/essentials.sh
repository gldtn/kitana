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
  networkmanager
  pamixer
  playerctl
  polkit
  quickshell
  satty
  sddm
  slurp
  udiskie
  vicinae-bin
  xdg-desktop-portal-gtk
  xdg-user-dirs
  xdg-utils
  wl-clip-persist
  wl-clipboard
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

sudo systemctl disable --now iwd.service systemd-networkd.service 2>/dev/null || true
sudo systemctl enable --now NetworkManager.service bluetooth.service
sudo systemctl enable --now sddm.service
