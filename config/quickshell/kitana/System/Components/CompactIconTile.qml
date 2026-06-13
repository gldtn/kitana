// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string iconName: Icons.defaultIcon
    property bool active: false

    signal clicked

    height: 64
    radius: 13
    color: mouse.containsMouse ? Colors.panelButtonBackgroundHover : Colors.panelCardBackground

    Rectangle {
        anchors.centerIn: parent
        width: 38
        height: 38
        radius: 12
        color: root.active ? Colors.accentForeground : Colors.panelButtonBackgroundSubtle

        Controls.Icon {
            anchors.centerIn: parent
            name: root.iconName
            tone: root.active ? "onAccent" : "primary"
            sizeRole: "tile"
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
