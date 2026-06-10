// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string icon: ""
    property bool active: false

    signal clicked

    height: 64
    radius: 13
    color: mouse.containsMouse ? Colors.surfaceHover : Colors.surface

    Rectangle {
        anchors.centerIn: parent
        width: 38
        height: 38
        radius: 12
        color: root.active ? Colors.accent : Colors.surfaceAlt

        Controls.Icon {
            anchors.centerIn: parent
            icon: root.icon
            color: root.active ? Colors.accentText : Colors.foreground
            size: 18
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
