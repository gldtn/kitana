#!/bin/bash

CONFIG_FILE="$HOME/.config/webapp-install.conf"
BROWSER="brave"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

case "$BROWSER" in
    brave)
        BROWSER_DESKTOP="brave-browser.desktop"
        ;;
    chromium)
        BROWSER_DESKTOP="chromium.desktop"
        ;;
    firefox)
        BROWSER_DESKTOP="firefox.desktop"
        ;;
    google-chrome-stable)
        BROWSER_DESKTOP="google-chrome.desktop"
        ;;
    qutebrowser)
        BROWSER_DESKTOP="org.qutebrowser.qutebrowser.desktop"
        ;;
    zen-browser)
        BROWSER_DESKTOP="zen-browser.desktop"
        ;;
    *)
        BROWSER_DESKTOP="brave-browser.desktop"
        ;;
esac

xdg-settings set default-web-browser "$BROWSER_DESKTOP"
xdg-mime default "$BROWSER_DESKTOP" x-scheme-handler/http
xdg-mime default "$BROWSER_DESKTOP" x-scheme-handler/https
xdg-mime default org.gnome.Nautilus.desktop inode/directory

# Open all images with imv
xdg-mime default imv.desktop image/png
xdg-mime default imv.desktop image/jpeg
xdg-mime default imv.desktop image/gif
xdg-mime default imv.desktop image/webp
xdg-mime default imv.desktop image/bmp
xdg-mime default imv.desktop image/tiff

# Open video files with mpv
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-msvideo
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop video/x-flv
xdg-mime default mpv.desktop video/x-ms-wmv
xdg-mime default mpv.desktop video/mpeg
xdg-mime default mpv.desktop video/ogg
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/quicktime
xdg-mime default mpv.desktop video/3gpp
xdg-mime default mpv.desktop video/3gpp2
xdg-mime default mpv.desktop video/x-ms-asf
xdg-mime default mpv.desktop video/x-ogm+ogg
xdg-mime default mpv.desktop video/x-theora+ogg
xdg-mime default mpv.desktop application/ogg

update-desktop-database ~/.local/share/applications
update-mime-database ~/.local/share/mime
