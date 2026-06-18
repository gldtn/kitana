// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string iconName: Icons.defaultIcon
    property string title: ""
    property string subtitle: ""
    property bool active: false
    property bool clickable: true

    signal clicked

    width: parent ? parent.width : 0
    height: 48
    radius: 11
    color: mouse.containsMouse ? Colors.controlHoverBackground : Colors.controlBackground
    border.color: active ? Colors.controlActiveBorder : Colors.controlBorder
    border.width: 0.8

    // Detail icon and text row
    Row {
        anchors.fill: parent
        anchors.margins: 9
        spacing: 10

        // Detail row icon
        Controls.Icon {
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            name: root.iconName
            tone: root.active ? "accent" : "primary"
            sizeRole: "button"
        }

        // Detail title and subtitle
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
                color: Colors.foregroundMuted
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 1
            }
        }
    }

    // Detail row click target
    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
