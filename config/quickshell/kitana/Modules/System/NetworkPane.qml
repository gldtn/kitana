// Kitana managed Quickshell system pane

import QtQuick
import "../.."
import "../../Services" as Services

Flickable {
    id: root

    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    clip: true
    contentWidth: width
    contentHeight: networkList.implicitHeight

    DetailList {
        id: networkList
        width: parent.width
        title: "Networks"
        emptyText: "No Wi-Fi networks found"
        modelData: Services.SystemStatus.wifiNetworks
        delegateComponent: wifiRow
        headerComponent: networkHeader
    }

    Component {
        id: networkHeader

        Column {
            width: parent.width
            spacing: 10

            DetailRow {
                icon: Services.SystemStatus.networkIcon
                title: Services.SystemStatus.networkKind === "off" ? "Not connected" : Services.SystemStatus.networkName
                subtitle: Services.SystemStatus.networkKind === "wired" ? "Ethernet connected" : (Services.SystemStatus.networkKind === "wifi" ? "Wi-Fi connected • " + Services.SystemStatus.networkSignal + "%" : "No active network")
                active: Services.SystemStatus.networkKind !== "off"
                clickable: false
            }

            DetailRow {
                icon: Services.SystemStatus.wifiEnabled ? "󰤨" : "󰤭"
                title: Services.SystemStatus.wifiEnabled ? "Turn Wi-Fi off" : "Turn Wi-Fi on"
                subtitle: "Wireless radio"
                active: Services.SystemStatus.wifiEnabled
                onClicked: Services.SystemStatus.toggleWifi()
            }

            DetailRow {
                icon: Services.SystemStatus.wifiScanning ? "󰑓" : "󰑑"
                title: Services.SystemStatus.wifiScanning ? "Scanning networks" : "Scan networks"
                subtitle: "Refresh nearby Wi-Fi networks"
                active: Services.SystemStatus.wifiScanning
                onClicked: Services.SystemStatus.scanWifi()
            }
        }
    }

    Component {
        id: wifiRow

        DetailRow {
            required property var modelData
            icon: modelData.active ? "󰤨" : (modelData.signal >= 70 ? "󰤨" : (modelData.signal >= 40 ? "󰤢" : "󰤟"))
            title: modelData.ssid
            subtitle: (modelData.active ? "Connected" : (modelData.security ? "Secured" : "Open")) + " • " + modelData.signal + "%"
            active: modelData.active
            onClicked: if (!modelData.active) Services.SystemStatus.connectWifi(modelData.ssid)
        }
    }
}
