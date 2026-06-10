// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    property bool clickable: true

    signal clicked

    width: parent ? parent.width : 0
    height: 48
    radius: 11
    color: mouse.containsMouse ? Colors.surfaceHover : Colors.surface
    border.color: active ? Colors.panelBorderStrong : "transparent"
    border.width: active ? 1 : 0

    Row {
        anchors.fill: parent
        anchors.margins: 9
        spacing: 10

            Controls.MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                icon: root.icon
                color: root.active ? Colors.accent : Colors.foreground
                size: 16
            }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 38

            Text {
                width: parent.width
                text: root.title
                color: Colors.foreground
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                text: root.subtitle
                color: Colors.muted
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 1
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
