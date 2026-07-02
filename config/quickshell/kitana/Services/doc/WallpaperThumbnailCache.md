# Wallpaper Thumbnail Cache

## Component Overview

WallpaperThumbnailCache resolves wallpaper thumbnail cache paths and helper command locations.

## Project Structure and Dependencies

Source file: `Services/WallpaperThumbnailCache.qml`.

Qt imports: `import QtQuick`, `import Quickshell`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `defaultSize` | `int` | `256` | Default square thumbnail size in pixels. |
| `homeDir` | `string` | `$HOME` | User home directory. |
| `kitanaDir` | `string` | `$KITANA_DIR` or `~/.local/share/kitana` | Kitana repository path used to find helper commands. |
| `cacheDir` | `string` | `~/.cache/kitana/wallpaper-thumbnails` | Thumbnail cache directory. |
| `helperPath` | `string` | `$KITANA_DIR/bin/kitana-wallpaper-thumbnail` | Thumbnail helper command path. |

## Methods

| Method | Description |
|--------|-------------|
| `normalizedPath(path)` | Removes a leading `file://` prefix from a path. |
| `djb2Hash(path)` | Produces a short stable path hash for cache filenames. |
| `cachePath(path, size)` | Returns the generated thumbnail path for a source path and size. |
| `fileUrl(path)` | Converts a local path to a `file://` URL for QML image loading. |
