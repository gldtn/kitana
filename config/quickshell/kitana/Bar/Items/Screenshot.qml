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
    color: screenshotMouse.containsMouse ? Colors.barHoverBackground : Colors.barBackground
    border.color: Colors.barBorder
    border.width: settings.borderWidth

    Controls.Icon {
        anchors.fill: parent
        name: "screenshot.default"
        tone: "accent"
        sizeRole: "bar"
    }

    MouseArea {
        id: screenshotMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.screenshotPanel) root.screenshotPanel.toggle()
    }
}
