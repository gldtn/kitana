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
        text: "󰣇"
        color: Colors.foreground
        font.family: settings.fontFamily
        font.pixelSize: 16
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - brandIcon.implicitWidth - headerActions.width - parent.spacing * 2
        text: (Quickshell.env("USER") || "kitana") + "@" + (Quickshell.env("HOSTNAME") || "host")
        color: Colors.foreground
        elide: Text.ElideRight
        font.family: settings.fontFamily
        font.pixelSize: settings.textPixelSize + 1
        font.weight: Font.Bold
    }

    Row {
        id: headerActions
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16

        HeaderIcon { text: Services.NotificationService.count > 0 ? "󱅫" : "󰂚"; onClicked: if (root.panel) root.panel.section = "notifications" }
        HeaderIcon { text: "󰒓"; onClicked: if (root.panel) root.panel.section = "settings" }
        HeaderIcon { text: "󰦖"; onClicked: if (root.panel) root.panel.section = "sessions" }
    }
}
