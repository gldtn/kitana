// Kitana managed Quickshell bar item

import QtQuick
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Item {
    id: root

    Custom.Settings { id: settings }

    property var screenshotPanel: null
    property bool embedded: false

    implicitHeight: settings.pillHeight
    implicitWidth: settings.pillHeight
    width: implicitWidth
    height: implicitHeight

    // Screenshot button pill background
    Rectangle {
        anchors.fill: parent
        visible: !root.embedded || screenshotMouse.containsMouse
        radius: root.height / settings.radiusDivisor
        color: screenshotMouse.containsMouse ? Colors.barHoverBackground : Colors.barBackground
        border.color: Colors.barBorder
        border.width: root.embedded ? 0 : settings.borderWidth
    }

    // Screenshot icon
    Controls.Icon {
        anchors.fill: parent
        name: "screenshot.default"
        tone: "accent"
        sizeRole: "bar"
    }

    // Screenshot panel click target
    MouseArea {
        id: screenshotMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.screenshotPanel) root.screenshotPanel.toggle()
    }
}
