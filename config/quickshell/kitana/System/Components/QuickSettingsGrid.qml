// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../Services" as Services

Column {
    id: root

    property var panel: null

    width: parent ? parent.width : 0
    height: implicitHeight
    spacing: 10

    function selectSection(name: string): void {
        if (panel)
            panel.section = name;
    }

    Row {
        id: primaryRow

        width: parent.width
        height: implicitHeight
        spacing: root.spacing

        Column {
            width: (primaryRow.width - primaryRow.spacing) / 2
            height: implicitHeight
            spacing: 10

            QuickTile {
                width: parent.width
                iconName: Services.SystemStatus.networkIconName
                title: Services.SystemStatus.networkKind === "wired" ? "Ethernet" : (Services.SystemStatus.networkKind === "wifi" ? "Wi-Fi" : "Network")
                subtitle: Services.SystemStatus.networkKind === "off" ? "Off" : "Connected"
                active: Services.SystemStatus.networkKind !== "off"
                onClicked: root.selectSection("network")
            }

            Row {
                visible: Services.SystemStatus.micAvailable
                width: parent.width
                height: visible ? implicitHeight : 0
                spacing: 10

                CompactIconTile {
                    width: (parent.width - parent.spacing) / 2
                    iconName: Services.SystemStatus.audioIconName
                    active: !Services.SystemStatus.audioMuted
                    onClicked: root.selectSection("audio")
                }

                CompactIconTile {
                    width: (parent.width - parent.spacing) / 2
                    iconName: Services.SystemStatus.micIconName
                    active: Services.SystemStatus.micAvailable && !Services.SystemStatus.micMuted
                    onClicked: root.selectSection("audio")
                }
            }

            QuickTile {
                visible: !Services.SystemStatus.micAvailable
                width: parent.width
                height: visible ? 64 : 0
                iconName: Services.SystemStatus.audioIconName
                title: "Audio"
                subtitle: Services.SystemStatus.audioLabel
                active: !Services.SystemStatus.audioMuted
                onClicked: root.selectSection("audio")
            }
        }

        Column {
            width: (primaryRow.width - primaryRow.spacing) / 2
            height: implicitHeight
            spacing: 10

            QuickTile {
                width: parent.width
                iconName: Services.SystemStatus.bluetoothIconName
                title: "Bluetooth"
                subtitle: Services.SystemStatus.bluetoothEnabled ? "On" : "Off"
                active: Services.SystemStatus.bluetoothEnabled
                onClicked: root.selectSection("bluetooth")
            }

            QuickTile {
                width: parent.width
                iconName: "input.keyboard"
                title: "Keyboard " + Services.SystemStatus.keyboardLayoutLabel
                subtitle: Services.SystemStatus.keyboardLayoutLongLabel
                active: true
                onClicked: Services.SystemStatus.nextKeyboardLayout()
            }
        }
    }

    Row {
        width: parent.width
        height: implicitHeight
        spacing: root.spacing

        QuickTile {
            width: (parent.width - parent.spacing) / 2
            iconName: Icons.notificationName(Services.NotificationService.count, Services.NotificationService.doNotDisturb)
            title: "Do Not Disturb"
            subtitle: Services.NotificationService.doNotDisturb ? "On" : "Off"
            active: Services.NotificationService.doNotDisturb
            onClicked: Services.NotificationService.toggleDoNotDisturb()
        }

        QuickTile {
            width: (parent.width - parent.spacing) / 2
            iconName: Services.CaffeineService.iconName
            title: "Caffeine"
            subtitle: Services.CaffeineService.subtitle
            active: Services.CaffeineService.enabled
            onClicked: Services.CaffeineService.toggle()
        }
    }
}
