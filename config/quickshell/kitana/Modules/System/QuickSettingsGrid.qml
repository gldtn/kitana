// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../Services" as Services

Row {
    id: root

    property var panel: null

    width: parent ? parent.width : 0
    height: implicitHeight
    spacing: 10

    function toggleSection(name: string): void {
        if (panel)
            panel.section = panel.section === name ? "notifications" : name;
    }

    Column {
        width: (root.width - root.spacing) / 2
        height: implicitHeight
        spacing: 10

        QuickTile {
            width: parent.width
            icon: Services.SystemStatus.networkIcon
            title: Services.SystemStatus.networkKind === "wired" ? "Ethernet" : (Services.SystemStatus.networkKind === "wifi" ? "Wi-Fi" : "Network")
            subtitle: Services.SystemStatus.networkKind === "off" ? "Off" : "Connected"
            active: Services.SystemStatus.networkKind !== "off"
            onClicked: root.toggleSection("network")
        }

        Row {
            visible: Services.SystemStatus.micAvailable
            width: parent.width
            height: visible ? implicitHeight : 0
            spacing: 10

            CompactIconTile {
                width: (parent.width - parent.spacing) / 2
                icon: Services.SystemStatus.audioIcon
                active: !Services.SystemStatus.audioMuted
                onClicked: root.toggleSection("audio")
            }

            CompactIconTile {
                width: (parent.width - parent.spacing) / 2
                icon: Services.SystemStatus.micIcon
                active: Services.SystemStatus.micAvailable && !Services.SystemStatus.micMuted
                onClicked: root.toggleSection("audio")
            }
        }

        QuickTile {
            visible: !Services.SystemStatus.micAvailable
            width: parent.width
            height: visible ? 64 : 0
            icon: Services.SystemStatus.audioIcon
            title: "Audio"
            subtitle: Services.SystemStatus.audioLabel
            active: !Services.SystemStatus.audioMuted
            onClicked: root.toggleSection("audio")
        }
    }

    Column {
        width: (root.width - root.spacing) / 2
        height: implicitHeight
        spacing: 10

        QuickTile {
            width: parent.width
            icon: Services.SystemStatus.bluetoothIcon
            title: "Bluetooth"
            subtitle: Services.SystemStatus.bluetoothEnabled ? "On" : "Off"
            active: Services.SystemStatus.bluetoothEnabled
            onClicked: root.toggleSection("bluetooth")
        }

        QuickTile {
            width: parent.width
            icon: Services.NotificationService.doNotDisturb ? "󰂛" : "󰂚"
            title: "Do Not Disturb"
            subtitle: Services.NotificationService.doNotDisturb ? "On" : "Off"
            active: Services.NotificationService.doNotDisturb
            onClicked: Services.NotificationService.toggleDoNotDisturb()
        }

        QuickTile {
            width: parent.width
            icon: "󰌌"
            title: "Keyboard " + Services.SystemStatus.keyboardLayoutLabel
            subtitle: Services.SystemStatus.keyboardLayoutLongLabel
            active: true
            onClicked: Services.SystemStatus.nextKeyboardLayout()
        }
    }
}
