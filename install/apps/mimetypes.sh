#!/bin/bash

CONFIG_FILE="$HOME/.config/webapp-install.conf"
BROWSER="brave-origin-beta"
KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
KITANA_HIDDEN_APPLICATIONS_DIR="$KITANA_DIR/applications/hidden"
USER_HIDDEN_APPLICATIONS_DIR="$HOME/.config/kitana/applications/hidden"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

mkdir -p "$HOME/.local/share/applications" "$HOME/.local/share/mime/packages" "$USER_HIDDEN_APPLICATIONS_DIR"
rm -f "$HOME/.local/share/applications/kitana-hidden-desktop-ids"

desktop_entry_hides() {
    grep -Eiq '^[[:space:]]*(NoDisplay|Hidden)[[:space:]]*=[[:space:]]*true[[:space:]]*$' "$1"
}

hidden_desktop_source() {
    DESKTOP_ID="$1"
    USER_FILE="$USER_HIDDEN_APPLICATIONS_DIR/$DESKTOP_ID"
    KITANA_FILE="$KITANA_HIDDEN_APPLICATIONS_DIR/$DESKTOP_ID"

    if [ -f "$USER_FILE" ]; then
        printf '%s\n' "$USER_FILE"
    elif [ -f "$KITANA_FILE" ]; then
        printf '%s\n' "$KITANA_FILE"
    fi
}

write_hidden_desktop_override() {
    SOURCE_FILE="$1"
    DESKTOP_ID="${SOURCE_FILE##*/}"
    TARGET_FILE="$HOME/.local/share/applications/$DESKTOP_ID"
    SYSTEM_FILE="/usr/share/applications/$DESKTOP_ID"
    BASE_FILE="$SOURCE_FILE"
    TMP_FILE="$(mktemp)"

    [ -f "$SYSTEM_FILE" ] && BASE_FILE="$SYSTEM_FILE"
    grep -Eiv '^[[:space:]]*(NoDisplay|Hidden|X-Kitana-Managed)[[:space:]]*=' "$BASE_FILE" > "$TMP_FILE" || true

    if grep -q '^\[Desktop Entry\]' "$TMP_FILE"; then
        cp "$TMP_FILE" "$TARGET_FILE"
    else
        {
            printf '[Desktop Entry]\n'
            grep -Ev '^\[Desktop Entry\]$' "$TMP_FILE" || true
        } > "$TARGET_FILE"
    fi

    {
        printf 'NoDisplay=true\n'
        printf 'X-Kitana-Managed=true\n'
    } >> "$TARGET_FILE"

    rm -f "$TMP_FILE"
}

for HIDDEN_DIR in "$KITANA_HIDDEN_APPLICATIONS_DIR" "$USER_HIDDEN_APPLICATIONS_DIR"; do
    [ -d "$HIDDEN_DIR" ] || continue
    for DESKTOP_FILE in "$HIDDEN_DIR"/*.desktop; do
        [ -e "$DESKTOP_FILE" ] || continue
        DESKTOP_ID="${DESKTOP_FILE##*/}"
        SOURCE_FILE="$(hidden_desktop_source "$DESKTOP_ID")"
        [ -n "$SOURCE_FILE" ] || continue
        TARGET_FILE="$HOME/.local/share/applications/$DESKTOP_ID"

        if desktop_entry_hides "$SOURCE_FILE"; then
            write_hidden_desktop_override "$SOURCE_FILE"
        elif [ -f "$TARGET_FILE" ] && grep -q '^X-Kitana-Managed=true$' "$TARGET_FILE"; then
            rm -f "$TARGET_FILE"
        fi
    done
done

for TARGET_FILE in "$HOME/.local/share/applications"/*.desktop; do
    [ -e "$TARGET_FILE" ] || continue
    grep -q '^X-Kitana-Managed=true$' "$TARGET_FILE" || continue
    DESKTOP_ID="${TARGET_FILE##*/}"
    SOURCE_FILE="$(hidden_desktop_source "$DESKTOP_ID")"

    if [ -z "$SOURCE_FILE" ] || ! desktop_entry_hides "$SOURCE_FILE"; then
        rm -f "$TARGET_FILE"
    fi
done

case "$BROWSER" in
    brave)
        BROWSER_DESKTOP="brave-browser.desktop"
        ;;
    brave-origin-beta)
        BROWSER_DESKTOP="brave-origin-beta.desktop"
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
        BROWSER_DESKTOP="brave-origin-beta.desktop"
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

# Open PDF documents with GNOME Papers
PDF_DESKTOP="org.gnome.Papers.desktop"
if [ -f "/usr/share/applications/$PDF_DESKTOP" ] || [ -f "$HOME/.local/share/applications/$PDF_DESKTOP" ]; then
    xdg-mime default "$PDF_DESKTOP" application/pdf
else
    echo "Papers desktop entry not found; keeping existing PDF handler."
fi

# Open video files with Celluloid
VIDEO_DESKTOP="io.github.celluloid_player.Celluloid.desktop"
if [ ! -f "/usr/share/applications/$VIDEO_DESKTOP" ] && [ ! -f "$HOME/.local/share/applications/$VIDEO_DESKTOP" ]; then
    VIDEO_DESKTOP="mpv.desktop"
fi

xdg-mime default "$VIDEO_DESKTOP" video/mp4
xdg-mime default "$VIDEO_DESKTOP" video/x-msvideo
xdg-mime default "$VIDEO_DESKTOP" video/x-matroska
xdg-mime default "$VIDEO_DESKTOP" video/x-flv
xdg-mime default "$VIDEO_DESKTOP" video/x-ms-wmv
xdg-mime default "$VIDEO_DESKTOP" video/mpeg
xdg-mime default "$VIDEO_DESKTOP" video/ogg
xdg-mime default "$VIDEO_DESKTOP" video/webm
xdg-mime default "$VIDEO_DESKTOP" video/quicktime
xdg-mime default "$VIDEO_DESKTOP" video/3gpp
xdg-mime default "$VIDEO_DESKTOP" video/3gpp2
xdg-mime default "$VIDEO_DESKTOP" video/x-ms-asf
xdg-mime default "$VIDEO_DESKTOP" video/x-ogm+ogg
xdg-mime default "$VIDEO_DESKTOP" video/x-theora+ogg
xdg-mime default "$VIDEO_DESKTOP" application/ogg

update-desktop-database "$HOME/.local/share/applications"
update-mime-database "$HOME/.local/share/mime"
