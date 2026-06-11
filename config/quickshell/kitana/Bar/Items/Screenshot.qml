// Kitana managed Quickshell bar item

import QtQuick
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property var screenshotPanel: null

    implicitHeight: settings.pillHeight
    implicitWidth: settings.pillHeight
    width: implicitWidth
    height: implicitHeight

    radius: height / settings.radiusDivisor
    color: screenshotMouse.containsMouse ? Colors.surfaceHover : Colors.panelBackground
    border.color: Colors.panelBorder
    border.width: settings.borderWidth

    Controls.Icon {
        anchors.fill: parent
        icon: Icons.screenshot
        color: Colors.accent
        size: settings.iconPixelSize + 1
    }

    MouseArea {
        id: screenshotMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.screenshotPanel) root.screenshotPanel.toggle()
    }
}
