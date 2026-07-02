# Cached Wallpaper Image

## Component Overview

CachedWallpaperImage loads generated wallpaper thumbnails with original-image fallback.

## Project Structure and Dependencies

Source file: `Dashboard/Components/CachedWallpaperImage.qml`.

Qt imports: `import QtQuick`, `import Quickshell.Io`.

Project imports: `import "../../Services" as Services`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `sourcePath` | `string` | `""` | Wallpaper file path. |
| `cacheSize` | `int` | `WallpaperThumbnailCache.defaultSize` | Thumbnail source size in pixels. |
| `fillMode` | `int` | `Image.PreserveAspectCrop` | Image fill mode forwarded to the internal image. |
