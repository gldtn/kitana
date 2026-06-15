// Kitana managed Quickshell system pane

import QtQuick
import "../.."
import "../Components"
import "../../custom" as Custom
import "../../Services" as Services

Column {
    id: root

    Custom.Settings { id: settings }

    property var panel: null

    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    spacing: 10

    Text {
        width: parent.width
        text: "Settings"
        color: Colors.foreground
        font.family: Typography.fontFamily
        font.pixelSize: 14
        font.weight: Font.Bold
    }

    DetailRow {
        iconName: "notifications.on"
        title: "Do Not Disturb"
        subtitle: Services.NotificationService.doNotDisturb ? "On" : "Off"
        active: Services.NotificationService.doNotDisturb
        onClicked: Services.NotificationService.toggleDoNotDisturb()
    }

    DetailRow {
        iconName: Services.SystemStatus.networkIconName
        title: "Network"
        subtitle: Services.SystemStatus.networkKind === "off" ? "Off" : "Connected"
        active: Services.SystemStatus.networkKind !== "off"
        onClicked: if (root.panel) root.panel.section = "network"
    }

    DetailRow {
        iconName: Services.SystemStatus.audioIconName
        title: "Audio"
        subtitle: Services.SystemStatus.audioLabel
        active: !Services.SystemStatus.audioMuted
        onClicked: if (root.panel) root.panel.section = "audio"
    }
}
