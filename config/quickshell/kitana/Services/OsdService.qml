// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell
import ".."

Singleton {
    id: root

    property bool visible: false
    property string kind: "volume"
    property string title: "Volume"
    property int value: 0
    property bool muted: false

    readonly property string iconName: {
        if (kind === "brightness")
            return "brightness";
        if (kind === "mic")
            return Icons.microphoneName(true, muted, value);
        return Icons.audioVolumeName(muted, value);
    }

    function show(nextKind, nextTitle, nextValue, nextMuted) {
        kind = nextKind || "volume";
        title = nextTitle || "Volume";
        value = Math.max(0, Math.min(100, parseInt(nextValue || 0)));
        muted = nextMuted === true || nextMuted === "true" || nextMuted === "muted";
        visible = true;
        hideTimer.restart();
    }

    function showPayload(payload) {
        const parts = (payload || "").split("|");
        show(parts[0], parts[1], parts[2], parts[3]);
    }

    Timer {
        id: hideTimer

        interval: 1300
        repeat: false
        onTriggered: root.visible = false
    }
}
