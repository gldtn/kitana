// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom
import "../../Services" as Services

Rectangle {
    id: root

    Custom.Settings { id: settings }

    required property var modelData

    readonly property bool saved: modelData.paired || modelData.trusted
    readonly property string title: modelData.name || modelData.deviceName || modelData.address || "Unknown device"
    readonly property string subtitle: Services.SystemStatus.bluetoothDeviceStatus(modelData)
    readonly property var actionButton: disconnectButton.visible ? disconnectButton : (forgetButton.visible ? forgetButton : null)

    width: parent ? parent.width : 0
    height: 48
    radius: 11
    color: rowMouse.containsMouse ? Colors.surfaceHover : Colors.surface
    border.color: modelData.connected ? Colors.panelBorderStrong : "transparent"
    border.width: modelData.connected ? 1 : 0

    Controls.Icon {
        id: bluetoothIcon
        anchors.left: parent.left
        anchors.leftMargin: 9
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        icon: modelData.connected ? Icons.bluetoothConnected : Icons.bluetooth
        color: modelData.connected ? Colors.accent : Colors.foreground
        size: 16
    }

    Column {
        anchors.left: bluetoothIcon.right
        anchors.right: root.actionButton ? root.actionButton.left : parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10
        anchors.rightMargin: 8

        Text {
            width: parent.width
            text: root.title
            color: Colors.foreground
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.Bold
        }

        Text {
            width: parent.width
            text: root.subtitle
            color: Colors.muted
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize - 1
        }
    }

    Rectangle {
        id: disconnectButton
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        visible: modelData.connected
        width: visible ? 30 : 0
        height: 30
        radius: 9
        color: disconnectMouse.containsMouse ? Colors.surfaceHighlight : Colors.surfaceAlt

        Controls.Icon {
            anchors.centerIn: parent
            icon: Icons.disconnect
            color: disconnectMouse.containsMouse ? Colors.danger : Colors.muted
            size: 14
        }

        MouseArea {
            id: disconnectMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Services.SystemStatus.disconnectBluetoothDevice(root.modelData)
        }
    }

    Rectangle {
        id: forgetButton
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        visible: root.saved && !modelData.connected
        width: visible ? 30 : 0
        height: 30
        radius: 9
        color: forgetMouse.containsMouse ? Colors.surfaceHighlight : Colors.surfaceAlt

        Controls.Icon {
            anchors.centerIn: parent
            icon: Icons.trash
            color: forgetMouse.containsMouse ? Colors.danger : Colors.muted
            size: 14
        }

        MouseArea {
            id: forgetMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Services.SystemStatus.forgetBluetoothDevice(root.modelData)
        }
    }

    Rectangle {
        id: actionTooltip
        visible: disconnectMouse.containsMouse || forgetMouse.containsMouse
        z: 3
        x: Math.max(8, (root.actionButton ? root.actionButton.x : root.width) - width - 8)
        anchors.verticalCenter: parent.verticalCenter
        width: actionTooltipLabel.implicitWidth + 14
        height: 22
        radius: 8
        color: Colors.panelBackground
        border.color: Colors.panelBorder
        border.width: 1

        Text {
            id: actionTooltipLabel
            anchors.centerIn: parent
            text: disconnectMouse.containsMouse ? "Disconnect" : "Forget"
            color: Colors.foreground
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize - 2
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: rowMouse
        anchors.left: parent.left
        anchors.right: root.actionButton ? root.actionButton.left : parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        enabled: !modelData.connected
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: Services.SystemStatus.connectBluetoothDevice(root.modelData)
    }
}
