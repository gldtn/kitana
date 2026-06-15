// Kitana managed Quickshell widget

import QtQuick
import "../.."
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string iconName: Icons.defaultIcon
    property string title: ""
    property string subtitle: ""
    property bool highlighted: false
    property bool clickable: true

    signal clicked

    width: parent ? parent.width : 320
    height: 48
    radius: 10
    color: highlighted ? Colors.controlActiveBackground : (mouse.containsMouse && clickable ? Colors.controlHoverBackground : Colors.cardBackground)
    border.color: highlighted ? Colors.controlActiveBorder : Colors.panelBorder
    border.width: 1

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            tone: root.highlighted ? "accent" : "primary"
            sizeRole: "tile"
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
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                text: root.subtitle
                color: Colors.foregroundMuted
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
