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

    signal clicked

    width: parent ? parent.width : 0
    height: 64
    radius: 13
    color: mouse.containsMouse ? Colors.bgTertiary : Colors.bgTertiary

    // Quick tile icon and labels
    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Tile icon badge
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 38
            height: 38
            radius: 12
            color: root.active ? Colors.fgAccent : Colors.subtleSecondary

            // Tile icon glyph
            Controls.Icon {
                anchors.centerIn: parent
                name: root.iconName
                tone: root.active ? "onAccent" : "primary"
                sizeRole: "tile"
            }
        }

        // Tile title and subtitle
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 48
            spacing: 2

            Text {
                width: parent.width
                text: root.title
                color: Colors.fgPrimary
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                text: root.subtitle
                color: Colors.fgSecondary
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 1
                font.weight: Font.DemiBold
            }
        }
    }

    // Quick tile click target
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
