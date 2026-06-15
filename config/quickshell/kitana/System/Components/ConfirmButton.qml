// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string label: ""
    property bool danger: false

    signal clicked

    width: 110
    height: 36
    radius: 10
    color: mouse.containsMouse ? (danger ? Colors.controlActiveBackground : Colors.controlHoverBackground) : Colors.cardBackground
    border.color: danger ? Colors.danger : Colors.panelBorder
    border.width: 1

    Text {
        anchors.centerIn: parent
        text: root.label
        color: danger ? Colors.danger : Colors.foreground
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize
        font.weight: Font.Bold
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
