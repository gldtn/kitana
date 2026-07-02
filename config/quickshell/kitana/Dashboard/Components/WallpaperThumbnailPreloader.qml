// Kitana managed Quickshell dashboard component

import QtQuick
import Quickshell.Io
import "../../Services" as Services

// Sequentially generates wallpaper thumbnails without blocking the UI thread.
Item {
    id: root

    property var paths: []
    property int cacheSize: Services.WallpaperThumbnailCache.defaultSize
    property var queue: []
    property int queueGeneration: 0

    function uniquePaths(items: var): var {
        const result = [];
        const seen = ({});

        for (const path of items || []) {
            const normalized = Services.WallpaperThumbnailCache.normalizedPath(path);
            if (normalized.length === 0 || seen[normalized])
                continue;

            seen[normalized] = true;
            result.push(normalized);
        }

        return result;
    }

    function restart(): void {
        queueGeneration++;
        queue = uniquePaths(paths);

        if (!preloadProcess.running)
            startNext();
    }

    function startNext(): void {
        if (!enabled || preloadProcess.running || queue.length === 0)
            return;

        const path = queue.shift();
        const cachePath = Services.WallpaperThumbnailCache.cachePath(path, cacheSize);
        if (path.length === 0 || cachePath.length === 0) {
            Qt.callLater(startNext);
            return;
        }

        preloadProcess.queueGeneration = queueGeneration;
        preloadProcess.exec([Services.WallpaperThumbnailCache.helperPath, "--size", String(cacheSize), "--output", cachePath, path]);
    }

    onPathsChanged: restart()
    onCacheSizeChanged: restart()
    onEnabledChanged: if (enabled)
        restart()
    Component.onCompleted: restart()

    Process {
        id: preloadProcess

        property int queueGeneration: 0

        onRunningChanged: if (!running)
            Qt.callLater(root.startNext)
    }
}
