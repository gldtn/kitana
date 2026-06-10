// Kitana managed Quickshell system pane

import QtQuick
import "../.."
import "../../custom" as Custom
import "../../Services" as Services

Flickable {
    id: root

    Custom.Settings { id: settings }

    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    clip: true
    contentWidth: width
    contentHeight: bluetoothList.implicitHeight

    Column {
        id: bluetoothList

        readonly property bool empty: Services.SystemStatus.bluetoothSavedDevices.length === 0 && Services.SystemStatus.bluetoothAvailableDevices.length === 0

        width: parent.width
        spacing: 10

        Text {
            width: bluetoothList.width
            text: "Bluetooth"
            color: Colors.foreground
            font.family: settings.fontFamily
            font.pixelSize: 14
            font.weight: Font.Bold
        }

        DetailRow {
            visible: Services.SystemStatus.bluetoothAvailable
            icon: Services.SystemStatus.bluetoothDiscovering ? "󰑓" : "󰂯"
            title: Services.SystemStatus.bluetoothDiscovering ? "Scanning for devices" : (Services.SystemStatus.bluetoothEnabled ? "Scan for devices" : "Turn Bluetooth on")
            subtitle: Services.SystemStatus.bluetoothEnabled ? "Click to refresh nearby devices" : "Click to enable adapter"
            active: Services.SystemStatus.bluetoothDiscovering
            onClicked: {
                if (!Services.SystemStatus.bluetoothEnabled)
                    Services.SystemStatus.toggleBluetooth();
                else
                    Services.SystemStatus.toggleBluetoothScan();
            }
        }

        Text {
            width: bluetoothList.width
            visible: bluetoothList.empty
            text: Services.SystemStatus.bluetoothEnabled ? "No devices found" : "Bluetooth is off"
            color: Colors.muted
            horizontalAlignment: Text.AlignHCenter
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize
        }

        Repeater {
            model: Services.SystemStatus.bluetoothSavedDevices
            delegate: BluetoothDeviceRow {}
        }

        Row {
            visible: Services.SystemStatus.bluetoothSavedDevices.length > 0 && Services.SystemStatus.bluetoothAvailableDevices.length > 0
            width: bluetoothList.width
            height: visible ? 18 : 0
            spacing: 10

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 42
                height: 1
                color: Colors.panelBorder
            }

            Text {
                id: nearbyDividerLabel
                anchors.verticalCenter: parent.verticalCenter
                text: "Nearby devices"
                color: Colors.muted
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize - 2
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 42 - parent.spacing * 2 - nearbyDividerLabel.implicitWidth
                height: 1
                color: Colors.panelBorder
            }
        }

        Repeater {
            model: Services.SystemStatus.bluetoothAvailableDevices
            delegate: BluetoothDeviceRow {}
        }
    }
}
