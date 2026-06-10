// Kitana managed Quickshell system component

import QtQuick
import "../.."
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

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: root.active ? Colors.accentText : Colors.foreground
            font.family: settings.fontFamily
            font.pixelSize: 18
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
