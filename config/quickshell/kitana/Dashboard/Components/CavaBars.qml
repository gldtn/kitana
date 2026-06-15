// Kitana managed Quickshell dashboard component

import QtQuick
import "../.."

Item {
    id: root

    property var dashboard: null
    readonly property var levels: dashboard ? dashboard.cavaLevels : []
    readonly property bool playing: dashboard ? dashboard.mediaPlaying : false

    Repeater {
        model: root.levels.length

        Rectangle {
            required property int index

            readonly property real level: root.playing ? Math.max(1, root.levels[index] || 1) : 1
            width: Math.max(2, (root.width - (root.levels.length - 1) * 6) / root.levels.length)
            height: Math.max(4, root.height * level / 8)
            x: index * (width + 6)
            y: root.height - height
            radius: width / 2
            color: root.playing ? Colors.accent : Colors.controlActiveBackground
            opacity: root.playing ? 0.9 : 0.45

            Behavior on height { NumberAnimation { duration: 90 } }
            Behavior on y { NumberAnimation { duration: 90 } }
        }
    }
}
