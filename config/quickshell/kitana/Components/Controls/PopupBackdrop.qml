// Kitana managed Quickshell control

import QtQuick
import "../.."

// Reusable modal scrim with click-away dismissal for in-panel popups
Item {
    id: root

    property bool open: false
    property bool rendered: open
    property bool closeOnBackdropClick: true
    property color scrimColor: Colors.alpha(Colors.bgPrimary, 0.7)
    property real scrimRadius: 0
    property int fadeDuration: 140
    default property alias content: contentLayer.data

    signal dismissed

    visible: rendered || open
    opacity: open ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: root.fadeDuration
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.scrimRadius
        color: root.scrimColor
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.closeOnBackdropClick && root.open
        onClicked: root.dismissed()
    }

    Item {
        id: contentLayer

        anchors.fill: parent
    }
}
