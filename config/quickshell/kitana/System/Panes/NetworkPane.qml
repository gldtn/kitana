// Kitana managed Quickshell system pane

import QtQuick
import "../.."
import "../Components"
import "../../Services" as Services

Flickable {
    id: root

    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    clip: true
    contentWidth: width
    contentHeight: networkList.implicitHeight

    // Wi-Fi networks detail list
    DetailList {
        id: networkList
        width: parent.width
        title: "Networks"
        emptyText: "No Wi-Fi networks found"
        modelData: Services.SystemStatus.wifiNetworks
        delegateComponent: wifiRow
        headerComponent: networkHeader
    }

    // Network status and scan header
    Component {
        id: networkHeader

        // Network header stack
        Column {
            width: parent.width
            spacing: 10

            // Current network status row
            DetailRow {
                iconName: Services.SystemStatus.networkIconName
                title: Services.SystemStatus.networkKind === "off" ? "Not connected" : Services.SystemStatus.networkName
                subtitle: Services.SystemStatus.networkKind === "wired" ? "Ethernet connected" : (Services.SystemStatus.networkKind === "wifi" ? "Wi-Fi connected • " + Services.SystemStatus.networkSignal + "%" : "No active network")
                active: Services.SystemStatus.networkKind !== "off"
                clickable: false
            }

            // Wi-Fi enable toggle row
            DetailRow {
                iconName: Services.SystemStatus.wifiEnabled ? "network.wifi" : "network.wifi.off"
                title: Services.SystemStatus.wifiEnabled ? "Turn Wi-Fi off" : "Turn Wi-Fi on"
                subtitle: "Wireless radio"
                active: Services.SystemStatus.wifiEnabled
                onClicked: Services.SystemStatus.toggleWifi()
            }

            // Wi-Fi scan row
            DetailRow {
                iconName: Services.SystemStatus.wifiScanning ? "ui.scan" : "ui.refresh"
                title: Services.SystemStatus.wifiScanning ? "Scanning networks" : "Scan networks"
                subtitle: "Refresh nearby Wi-Fi networks"
                active: Services.SystemStatus.wifiScanning
                onClicked: Services.SystemStatus.scanWifi()
            }
        }
    }

    // Wi-Fi network row component
    Component {
        id: wifiRow

        // One Wi-Fi network row
        DetailRow {
            required property var modelData
            iconName: modelData.active ? "network.wifi" : Icons.networkName("wifi", modelData.signal)
            title: modelData.ssid
            subtitle: (modelData.active ? "Connected" : (modelData.security ? "Secured" : "Open")) + " • " + modelData.signal + "%"
            active: modelData.active
            onClicked: if (!modelData.active) Services.SystemStatus.connectWifi(modelData.ssid)
        }
    }
}
