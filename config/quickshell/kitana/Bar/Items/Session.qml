// Kitana managed Quickshell module

import QtQuick
import Quickshell.Io
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    implicitHeight: settings.pillHeight
    implicitWidth: settings.pillHeight
    width: implicitWidth
    height: implicitHeight

    radius: height / settings.radiusDivisor
    color: sessionMouse.containsMouse ? Colors.panelButtonBackgroundHover : Colors.panelBackground
    border.color: sessionMouse.containsMouse ? Colors.panelButtonBorderActive : Colors.panelBorder
    border.width: settings.borderWidth

    Process { id: sessionMenu }

    Controls.Icon {
        anchors.centerIn: parent
        icon: Icons.power
        color: sessionMouse.containsMouse ? Colors.primaryForeground : Colors.accentForeground
        size: settings.iconPixelSize
    }

    MouseArea {
        id: sessionMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: sessionMenu.exec(["quickshell", "ipc", "-c", "kitana", "call", "kitana-session", "toggle"])
    }
}
