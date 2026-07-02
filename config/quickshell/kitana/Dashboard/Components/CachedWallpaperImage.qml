// Kitana managed Quickshell dashboard component

import QtQuick
import Quickshell.Io
import "../../Services" as Services

// Wallpaper image loader that prefers a generated thumbnail cache.
Item {
    id: root

    property string sourcePath: ""
    property int cacheSize: Services.WallpaperThumbnailCache.defaultSize
    property int fillMode: Image.PreserveAspectCrop
    readonly property int status: thumbnail.status
    readonly property string cachePath: Services.WallpaperThumbnailCache.cachePath(sourcePath, cacheSize)
    readonly property string cacheUrl: Services.WallpaperThumbnailCache.fileUrl(cachePath)
    readonly property string sourceUrl: Services.WallpaperThumbnailCache.fileUrl(sourcePath)
    property int requestGeneration: 0
    property int pendingGeneration: 0

    function refreshSource(): void {
        requestGeneration++;

        if (sourcePath.length === 0 || cachePath.length === 0) {
            thumbnail.source = "";
            return;
        }

        thumbnail.source = "";
        generateThumbnail(requestGeneration);
    }

    function generateThumbnail(generation: int): void {
        if (generation !== requestGeneration || sourcePath.length === 0 || cachePath.length === 0) {
            pendingGeneration = 0;
            return;
        }

        if (thumbnailGenerator.running) {
            pendingGeneration = generation;
            return;
        }

        pendingGeneration = 0;
        thumbnailGenerator.requestGeneration = generation;
        thumbnailGenerator.cachePath = cachePath;
        thumbnailGenerator.exec([Services.WallpaperThumbnailCache.helperPath, "--size", String(cacheSize), "--output", cachePath, Services.WallpaperThumbnailCache.normalizedPath(sourcePath)]);
    }

    onSourcePathChanged: refreshSource()
    onCacheSizeChanged: refreshSource()
    Component.onCompleted: refreshSource()

    // Visible thumbnail image
    Image {
        id: thumbnail

        anchors.fill: parent
        fillMode: root.fillMode
        asynchronous: true
        smooth: true
        mipmap: true
        sourceSize.width: root.cacheSize
        sourceSize.height: root.cacheSize
    }

    // Best-effort cache generator for visible uncached thumbnails
    Process {
        id: thumbnailGenerator

        property int requestGeneration: 0
        property string cachePath: ""
        property bool resolved: false

        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim();
                thumbnailGenerator.resolved = path.length > 0;

                if (thumbnailGenerator.requestGeneration === root.requestGeneration && path.length > 0)
                    thumbnail.source = Services.WallpaperThumbnailCache.fileUrl(path);
            }
        }

        onRunningChanged: {
            if (running)
                resolved = false;
            else if (root.pendingGeneration > 0)
                root.generateThumbnail(root.pendingGeneration);
            else if (requestGeneration === root.requestGeneration && !resolved)
                thumbnail.source = root.sourceUrl;
        }
    }
}
