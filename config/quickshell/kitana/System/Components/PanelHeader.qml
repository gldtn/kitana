// Kitana managed Quickshell system component

import QtQuick
import Quickshell
import "../.."
import "../../custom" as Custom
import "../../Services" as Services

Row {
    id: root

    Custom.Settings { id: settings }

    property var panel: null

    width: parent ? parent.width : 0
    height: 34
    spacing: 12

    Text {
        id: brandIcon
        anchors.verticalCenter: parent.verticalCenter
        text: Icons.arch
        color: Colors.primaryForeground
        font.family: Typography.iconFontFamily
        font.pixelSize: 16
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - brandIcon.implicitWidth - headerActions.width - parent.spacing * 2
        text: (Quickshell.env("USER") || "kitana") + "@" + (Quickshell.env("HOSTNAME") || "host")
        color: Colors.primaryForeground
        elide: Text.ElideRight
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize + 1
        font.weight: Font.Bold
    }

    Row {
        id: headerActions
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16

        HeaderIcon { text: Icons.notification(Services.NotificationService.count, Services.NotificationService.doNotDisturb); onClicked: if (root.panel) root.panel.section = "notifications" }
        HeaderIcon { text: Icons.settings; onClicked: if (root.panel) root.panel.section = "settings" }
        HeaderIcon { text: Icons.power; onClicked: if (root.panel) root.panel.section = "sessions" }
    }
}
