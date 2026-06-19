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
    color: mouse.containsMouse ? (danger ? Colors.subtleAccent : Colors.bgTertiary) : Colors.bgTertiary
    border.color: danger ? Colors.error : Colors.borderFaint
    border.width: 1

    // Confirm button label
    Text {
        anchors.centerIn: parent
        text: root.label
        color: root.danger ? Colors.error : Colors.fgPrimary
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize
        font.weight: Font.Bold
    }

    // Confirm button click target
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
