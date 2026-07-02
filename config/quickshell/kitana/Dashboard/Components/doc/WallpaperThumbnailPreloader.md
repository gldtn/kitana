# Wallpaper Thumbnail Preloader

## Component Overview

WallpaperThumbnailPreloader generates wallpaper thumbnail cache entries in the background.

## Project Structure and Dependencies

Source file: `Dashboard/Components/WallpaperThumbnailPreloader.qml`.

Qt imports: `import QtQuick`, `import Quickshell.Io`.

Project imports: `import "../../Services" as Services`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `paths` | `var` | `[]` | Wallpaper file paths queued for cache generation. |
| `cacheSize` | `int` | `WallpaperThumbnailCache.defaultSize` | Generated thumbnail size in pixels. |
