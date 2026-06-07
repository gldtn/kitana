// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool visible: false
    property string kind: "volume"
    property string title: "Volume"
    property int value: 0
    property bool muted: false

    readonly property string icon: {
        if (kind === "brightness")
            return "󰃠";
        if (kind === "mic")
            return muted || value === 0 ? "󰍭" : "󰍬";
        return muted || value === 0 ? "" : (value >= 60 ? "" : "");
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
