// Kitana managed Quickshell widget

import QtQuick
import ".."
import "../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool highlighted: false
    property bool clickable: true

    signal clicked

    width: parent ? parent.width : 320
    height: 48
    radius: 10
    color: highlighted ? Colors.surfaceHighlight : (mouse.containsMouse && clickable ? Colors.surfaceHover : Colors.surface)
    border.color: highlighted ? Colors.panelBorderStrong : Colors.panelBorder
    border.width: 1

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.highlighted ? Colors.accent : Colors.foreground
            font.family: settings.fontFamily
            font.pixelSize: 18
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 42
            spacing: 2

            Text {
                width: parent.width
                text: root.title
                color: Colors.foreground
                elide: Text.ElideRight
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                text: root.subtitle
                color: Colors.muted
                elide: Text.ElideRight
                font.family: settings.fontFamily
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
