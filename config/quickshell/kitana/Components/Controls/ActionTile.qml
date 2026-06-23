// Kitana managed Quickshell control

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

// Reusable centered action tile with shortcut badge
Rectangle {
    id: root

    Custom.Settings {
        id: settings
    }

    property string iconName: Icons.defaultIcon
    property string shortcut: ""
    property string title: ""
    property string subtitle: ""

    signal clicked

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 14
    color: actionMouse.containsMouse ? Colors.scrimTertiary : Colors.bgTertiary
    border.color: actionMouse.containsMouse ? Colors.borderAccent : Colors.borderLight
    border.width: 1

    // Shortcut badge
    ShortcutBadge {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.rightMargin: 8
        text: root.shortcut
    }

    // Action icon and labels
    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - 16
        spacing: 6

        Icon {
            Layout.alignment: Qt.AlignHCenter
            name: root.iconName
            tone: "accent"
            size: settings.iconPixelSize + 6
        }

        Text {
            Layout.fillWidth: true
            text: root.title
            color: Colors.fgPrimary
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.Bold
        }

        Text {
            Layout.fillWidth: true
            text: root.subtitle
            color: Colors.fgSecondary
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize - 2
        }
    }

    // Action tile click target
    MouseArea {
        id: actionMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
