// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property int defaultSize: 256
    readonly property string homeDir: Quickshell.env("HOME") || ""
    readonly property string kitanaDir: Quickshell.env("KITANA_DIR") || homeDir + "/.local/share/kitana"
    readonly property string cacheDir: homeDir + "/.cache/kitana/wallpaper-thumbnails"
    readonly property string helperPath: kitanaDir + "/bin/kitana-wallpaper-thumbnail"

    function normalizedPath(path: string): string {
        const value = String(path || "");
        const localPath = value.indexOf("file://") === 0 ? value.slice(7) : value;

        try {
            return decodeURIComponent(localPath);
        } catch (error) {
            return localPath;
        }
    }

    function djb2Hash(path: string): string {
        const value = normalizedPath(path);
        let hash = 5381;

        for (let i = 0; i < value.length; i++)
            hash = (((hash << 5) + hash) + value.charCodeAt(i)) & 0x7fffffff;

        return hash.toString(16).padStart(8, "0");
    }

    function cachePath(path: string, size: int): string {
        const normalized = normalizedPath(path);
        if (normalized.length === 0)
            return "";

        const boundedSize = Math.max(1, size || defaultSize);
        return cacheDir + "/" + djb2Hash(normalized) + "@" + boundedSize + "x" + boundedSize + ".png";
    }

    function fileUrl(path: string): string {
        const normalized = normalizedPath(path);
        return normalized.length > 0 ? "file://" + normalized.split("/").map(part => encodeURIComponent(part)).join("/") : "";
    }
}
