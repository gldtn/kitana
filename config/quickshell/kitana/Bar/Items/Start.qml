// Kitana managed Quickshell bar item

import QtQuick
import "../.."
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property var startMenu: null

    implicitHeight: settings.pillHeight
    implicitWidth: settings.pillHeight
    width: implicitWidth
    height: implicitHeight

    radius: height / settings.radiusDivisor
    color: startMouse.containsMouse ? Colors.surfaceHover : Colors.panelBackground
    border.color: Colors.panelBorder
    border.width: settings.borderWidth

    Text {
        anchors.centerIn: parent
        text: ""
        color: Colors.accent
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: settings.iconPixelSize + 1
    }

    MouseArea {
        id: startMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.startMenu) root.startMenu.toggle()
    }
}
