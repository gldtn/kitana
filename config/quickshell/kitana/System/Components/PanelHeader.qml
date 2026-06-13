// Kitana managed Quickshell system component

import QtQuick
import Quickshell
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom
import "../../Services" as Services

Row {
    id: root

    Custom.Settings { id: settings }

    property var panel: null

    width: parent ? parent.width : 0
    height: 34
    spacing: 12

    Controls.Icon {
        id: brandIcon
        anchors.verticalCenter: parent.verticalCenter
        name: "brand.arch"
        tone: "brand"
        sizeRole: "button"
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

        HeaderIcon { name: Icons.notificationName(Services.NotificationService.count, Services.NotificationService.doNotDisturb); onClicked: if (root.panel) root.panel.section = "notifications" }
    }
}
