// Kitana managed Quickshell module

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../custom" as Custom
import "../Services" as Services

PanelWindow {
    id: root

    Custom.Settings { id: settings }

    property var panelScreen: null
    property string section: "notifications"
    property string confirmAction: ""
    property string confirmTitle: ""

    function open(targetSection) {
        section = targetSection || "notifications";
        Services.SystemStatus.refresh();
        visible = true;
    }

    function close() {
        visible = false;
    }

    function toggle(targetSection) {
        if (visible && section === targetSection)
            close();
        else
            open(targetSection);
    }

    function ask(action, title) {
        confirmAction = action;
        confirmTitle = title;
    }

    function runConfirmedAction() {
        if (confirmAction === "logout")
            sessionAction.exec(["hyprctl", "dispatch", "exit"]);
        else if (confirmAction === "restart")
            sessionAction.exec(["systemctl", "reboot"]);
        else if (confirmAction === "shutdown")
            sessionAction.exec(["systemctl", "poweroff"]);

        confirmAction = "";
    }

    screen: panelScreen
    visible: false
    focusable: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    Rectangle {
        id: card

        width: 390
        height: Math.min(parent.height - settings.panelHeight - 28, 720)
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: settings.panelHeight + settings.topMargin + 10
        anchors.rightMargin: settings.sideMargin
        radius: 18
        color: Colors.panelStrong
        border.color: Colors.panelBorder
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        Column {
            id: content

            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Row {
                width: parent.width
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

                    HeaderIcon { text: Services.NotificationService.count > 0 ? "󱅫" : "󰂚"; onClicked: root.section = "notifications" }
                    HeaderIcon { text: "󰒓"; onClicked: root.section = "settings" }
                    HeaderIcon { text: "󰦖"; onClicked: root.section = "sessions" }
                }
            }

            Grid {
                id: quickGrid
                width: parent.width
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                QuickTile {
                    icon: Services.SystemStatus.networkIcon
                    title: Services.SystemStatus.networkKind === "wired" ? "Ethernet" : (Services.SystemStatus.networkKind === "wifi" ? "Wi-Fi" : "Network")
                    subtitle: Services.SystemStatus.networkKind === "off" ? "Off" : "Connected"
                    active: Services.SystemStatus.networkKind !== "off"
                    onClicked: root.section = root.section === "network" ? "notifications" : "network"
                }

                QuickTile {
                    icon: Services.SystemStatus.bluetoothIcon
                    title: "Bluetooth"
                    subtitle: Services.SystemStatus.bluetoothEnabled ? "On" : "Off"
                    active: Services.SystemStatus.bluetoothEnabled
                    onClicked: root.section = root.section === "bluetooth" ? "notifications" : "bluetooth"
                }

                QuickTile {
                    icon: Services.SystemStatus.audioIcon
                    title: "Audio"
                    subtitle: Services.SystemStatus.audioLabel
                    active: !Services.SystemStatus.audioMuted
                    onClicked: root.section = root.section === "audio" ? "notifications" : "audio"
                }

                QuickTile {
                    icon: Services.NotificationService.doNotDisturb ? "󰂛" : "󰂚"
                    title: "Do Not Disturb"
                    subtitle: Services.NotificationService.doNotDisturb ? "On" : "Off"
                    active: Services.NotificationService.doNotDisturb
                    onClicked: Services.NotificationService.toggleDoNotDisturb()
                }
            }

            Rectangle {
                width: parent.width
                height: Math.max(220, card.height - headerActions.height - quickGrid.height - sliders.height - 86)
                radius: 14
                color: Colors.panel
                border.color: Colors.panelBorder
                border.width: 1
                clip: true

                Loader {
                    anchors.fill: parent
                    anchors.margins: 14
                    sourceComponent: root.section === "bluetooth" ? bluetoothDetails : (root.section === "network" ? networkDetails : (root.section === "audio" ? audioDetails : (root.section === "settings" ? settingsDetails : (root.section === "sessions" ? sessionsDetails : notificationsView))))
                }
            }

            Column {
                id: sliders
                width: parent.width
                spacing: 10

                SliderRow {
                    icon: Services.SystemStatus.audioIcon
                    value: Services.SystemStatus.audioVolume
                    label: Services.SystemStatus.audioLabel
                    iconClickable: true
                    onIconClicked: Services.SystemStatus.toggleAudioMute()
                    onMoved: value => Services.SystemStatus.setAudioVolume(value)
                }

                SliderRow {
                    visible: Services.SystemStatus.brightnessAvailable
                    height: visible ? 28 : 0
                    icon: "󰃠"
                    value: Services.SystemStatus.brightness
                    label: Services.SystemStatus.brightness + "%"
                    onMoved: value => Services.SystemStatus.setBrightness(value)
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Colors.scrim
            visible: root.confirmAction.length > 0
            z: 20

            Rectangle {
                width: parent.width - 48
                height: 150
                anchors.centerIn: parent
                radius: 16
                color: Colors.surface
                border.color: Colors.panelBorder
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    Text {
                        width: parent.width
                        text: root.confirmTitle
                        color: Colors.foreground
                        horizontalAlignment: Text.AlignHCenter
                        font.family: settings.fontFamily
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        text: "Confirm this session action."
                        color: Colors.muted
                        horizontalAlignment: Text.AlignHCenter
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10

                        ConfirmButton { label: "Cancel"; danger: false; onClicked: root.confirmAction = "" }
                        ConfirmButton { label: "Confirm"; danger: true; onClicked: root.runConfirmedAction() }
                    }
                }
            }
        }
    }

    Process { id: sessionAction }

    component HeaderIcon: Text {
        signal clicked

        color: Colors.foreground
        font.family: settings.fontFamily
        font.pixelSize: 15

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component ConfirmButton: Rectangle {
        id: button

        property string label: ""
        property bool danger: false
        signal clicked

        width: 110
        height: 36
        radius: 10
        color: mouse.containsMouse ? (danger ? Colors.surfaceHighlight : Colors.surfaceHover) : Colors.surface
        border.color: danger ? Colors.danger : Colors.panelBorder
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: button.label
            color: danger ? Colors.danger : Colors.foreground
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.Bold
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    component QuickTile: Rectangle {
        id: tile

        property string icon: ""
        property string title: ""
        property string subtitle: ""
        property bool active: false
        signal clicked

        width: (quickGrid.width - quickGrid.columnSpacing) / 2
        height: 64
        radius: 13
        color: mouse.containsMouse ? Colors.surfaceHover : Colors.surface

        Row {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 38
                height: 38
                radius: 12
                color: tile.active ? Colors.accent : Colors.surfaceAlt

                Text {
                    anchors.centerIn: parent
                    text: tile.icon
                    color: tile.active ? Colors.accentText : Colors.foreground
                    font.family: settings.fontFamily
                    font.pixelSize: 18
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 48
                spacing: 2

                Text {
                    width: parent.width
                    text: tile.title
                    color: Colors.foreground
                    elide: Text.ElideRight
                    font.family: settings.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.Bold
                }

                Text {
                    width: parent.width
                    text: tile.subtitle
                    color: Colors.muted
                    elide: Text.ElideRight
                    font.family: settings.fontFamily
                    font.pixelSize: settings.textPixelSize - 1
                    font.weight: Font.DemiBold
                }
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.clicked()
        }
    }

    component SliderRow: Row {
        id: sliderRow

        property string icon: ""
        property int value: 0
        property string label: ""
        property bool iconClickable: false
        signal moved(real value)
        signal iconClicked

        width: parent.width
        height: 28
        spacing: 10

        Text {
            id: sliderIcon
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            text: sliderRow.icon
            color: Colors.foreground
            font.family: settings.fontFamily
            font.pixelSize: 15

            MouseArea {
                anchors.fill: parent
                enabled: sliderRow.iconClickable
                hoverEnabled: enabled
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: sliderRow.iconClicked()
            }
        }

        Slider {
            id: control

            anchors.verticalCenter: parent.verticalCenter
            width: sliderRow.width - sliderIcon.width - valueText.width - sliderRow.spacing * 2
            height: 22
            from: 0
            to: 100
            value: sliderRow.value
            onMoved: sliderRow.moved(value)

            background: Rectangle {
                x: control.leftPadding
                y: control.topPadding + control.availableHeight / 2 - height / 2
                width: control.availableWidth
                height: 6
                radius: 3
                color: Colors.surfaceAlt

                Rectangle {
                    width: control.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: Colors.accent
                }
            }

            handle: Rectangle {
                x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
                y: control.topPadding + control.availableHeight / 2 - height / 2
                width: 16
                height: 16
                radius: 8
                color: Colors.accent
                border.color: Colors.panelBorderStrong
                border.width: 1
            }
        }

        Text {
            id: valueText
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            text: sliderRow.label
            color: Colors.foreground
            horizontalAlignment: Text.AlignRight
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.DemiBold
        }
    }

    Component {
        id: notificationsView

        Item {
            Text {
                anchors.centerIn: parent
                visible: Services.NotificationService.count === 0
                text: "󰂚\n\n0 Notifications"
                color: Colors.muted
                horizontalAlignment: Text.AlignHCenter
                font.family: settings.fontFamily
                font.pixelSize: 20
            }

            Column {
                anchors.fill: parent
                spacing: 10
                visible: Services.NotificationService.count > 0

                Row {
                    width: parent.width
                    height: 24

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - clearNotifications.width
                        text: Services.NotificationService.count + " Notifications"
                        color: Colors.foreground
                        font.family: settings.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }

                    Text {
                        id: clearNotifications
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰅖"
                        color: Colors.foreground
                        font.family: settings.fontFamily
                        font.pixelSize: 15

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Services.NotificationService.clear()
                        }
                    }
                }

                Repeater {
                    model: Services.NotificationService.notifications.slice(0, 5)

                    NotificationRow {
                        required property var modelData
                        item: modelData
                    }
                }
            }
        }
    }

    Component {
        id: bluetoothDetails

        Flickable {
            width: parent.width
            height: parent.height
            clip: true
            contentWidth: width
            contentHeight: bluetoothList.implicitHeight

            DetailList {
                id: bluetoothList
                width: parent.width
                title: "Bluetooth"
                emptyText: Services.SystemStatus.bluetoothEnabled ? "No devices found" : "Bluetooth is off"
                modelData: Services.SystemStatus.bluetoothDevices
                delegateComponent: bluetoothDeviceRow
                actionVisible: Services.SystemStatus.bluetoothAvailable
                actionIcon: Services.SystemStatus.bluetoothDiscovering ? "󰑓" : "󰂯"
                actionTitle: Services.SystemStatus.bluetoothDiscovering ? "Scanning for devices" : (Services.SystemStatus.bluetoothEnabled ? "Scan for devices" : "Turn Bluetooth on")
                actionSubtitle: Services.SystemStatus.bluetoothEnabled ? "Click to refresh nearby devices" : "Click to enable adapter"
                onActionClicked: {
                    if (!Services.SystemStatus.bluetoothEnabled)
                        Services.SystemStatus.toggleBluetooth();
                    else
                        Services.SystemStatus.toggleBluetoothScan();
                }
            }
        }
    }

    Component {
        id: networkDetails

        Flickable {
            width: parent.width
            height: parent.height
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
        }
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
        id: audioDetails

        Flickable {
            width: parent.width
            height: parent.height
            clip: true
            contentWidth: width
            contentHeight: audioList.implicitHeight

            DetailList {
                id: audioList
                width: parent.width
                title: "Audio Outputs"
                emptyText: "No output devices found"
                modelData: Services.SystemStatus.audioSinks
                delegateComponent: audioSinkRow
            }
        }
    }

    Component {
        id: settingsDetails

        Column {
            width: parent.width
            height: parent.height
            spacing: 10

            Text {
                width: parent.width
                text: "Settings"
                color: Colors.foreground
                font.family: settings.fontFamily
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            DetailRow { icon: "󰂚"; title: "Do Not Disturb"; subtitle: Services.NotificationService.doNotDisturb ? "On" : "Off"; active: Services.NotificationService.doNotDisturb; onClicked: Services.NotificationService.toggleDoNotDisturb() }
            DetailRow { icon: Services.SystemStatus.networkIcon; title: "Network"; subtitle: Services.SystemStatus.networkKind === "off" ? "Off" : "Connected"; active: Services.SystemStatus.networkKind !== "off"; onClicked: root.section = "network" }
            DetailRow { icon: Services.SystemStatus.audioIcon; title: "Audio"; subtitle: Services.SystemStatus.audioLabel; active: !Services.SystemStatus.audioMuted; onClicked: root.section = "audio" }
        }
    }

    Component {
        id: sessionsDetails

        Column {
            width: parent.width
            height: parent.height
            spacing: 10

            Text {
                width: parent.width
                text: "Session"
                color: Colors.foreground
                font.family: settings.fontFamily
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            DetailRow { icon: "󰌾"; title: "Lock"; subtitle: "Lock this session"; onClicked: sessionAction.exec(["sh", "-c", "${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-lock"]) }
            DetailRow { icon: "󰗽"; title: "Log out"; subtitle: "Confirm before ending session"; onClicked: root.ask("logout", "Log out?") }
            DetailRow { icon: "󰜉"; title: "Restart"; subtitle: "Confirm before reboot"; onClicked: root.ask("restart", "Restart?") }
            DetailRow { icon: "󰐥"; title: "Shut down"; subtitle: "Confirm before poweroff"; onClicked: root.ask("shutdown", "Shut down?") }
        }
    }

    Component {
        id: bluetoothDeviceRow

        DetailRow {
            required property var modelData
            icon: modelData.connected ? "󰂱" : "󰂯"
            title: modelData.name || modelData.deviceName || modelData.address || "Unknown device"
            subtitle: modelData.connected ? "Connected" : (modelData.paired || modelData.trusted ? "Paired" : "Available")
            active: modelData.connected
            onClicked: Services.SystemStatus.connectBluetoothDevice(modelData)
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

    Component {
        id: audioSinkRow

        DetailRow {
            required property var modelData
            icon: "󰕾"
            title: modelData.name
            subtitle: "Output device"
            active: Services.SystemStatus.audioSink === modelData.name
            onClicked: Services.SystemStatus.setAudioSink(modelData.id)
        }
    }

    component DetailList: Column {
        id: detailList

        property string title: ""
        property string emptyText: ""
        property var modelData: []
        property Component delegateComponent
        property Component headerComponent: null
        property bool actionVisible: false
        property string actionIcon: ""
        property string actionTitle: ""
        property string actionSubtitle: ""
        signal actionClicked

        width: parent ? parent.width : 0
        spacing: 10

        Text {
            width: detailList.width
            text: detailList.title
            color: Colors.foreground
            font.family: settings.fontFamily
            font.pixelSize: 14
            font.weight: Font.Bold
        }

        Loader {
            width: detailList.width
            sourceComponent: detailList.headerComponent
        }

        Text {
            width: detailList.width
            visible: detailList.modelData.length === 0 && !detailList.headerComponent
            text: detailList.emptyText
            color: Colors.muted
            horizontalAlignment: Text.AlignHCenter
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize
        }

        DetailRow {
            visible: detailList.actionVisible
            icon: detailList.actionIcon
            title: detailList.actionTitle
            subtitle: detailList.actionSubtitle
            active: Services.SystemStatus.bluetoothDiscovering
            onClicked: detailList.actionClicked()
        }

        Repeater {
            model: detailList.modelData
            delegate: detailList.delegateComponent
        }
    }

    component DetailRow: Rectangle {
        id: row

        property string icon: ""
        property string title: ""
        property string subtitle: ""
        property bool active: false
        property bool clickable: true
        signal clicked

        width: parent ? parent.width : 0
        height: 48
        radius: 11
        color: mouse.containsMouse ? Colors.surfaceHover : Colors.surface
        border.color: active ? Colors.panelBorderStrong : "transparent"
        border.width: active ? 1 : 0

        Row {
            anchors.fill: parent
            anchors.margins: 9
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                text: row.icon
                color: row.active ? Colors.accent : Colors.foreground
                font.family: settings.fontFamily
                font.pixelSize: 16
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 38

                Text {
                    width: parent.width
                    text: row.title
                    color: Colors.foreground
                    elide: Text.ElideRight
                    font.family: settings.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.Bold
                }

                Text {
                    width: parent.width
                    text: row.subtitle
                    color: Colors.muted
                    elide: Text.ElideRight
                    font.family: settings.fontFamily
                    font.pixelSize: settings.textPixelSize - 1
                }
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            enabled: row.clickable
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: row.clicked()
        }
    }

    component NotificationRow: Rectangle {
        id: notificationRow

        property var item: null

        width: parent ? parent.width : 0
        height: Math.max(58, bodyText.visible ? 76 : 58)
        radius: 11
        color: mouse.containsMouse ? Colors.surfaceHover : Colors.surface

        Column {
            anchors.left: parent.left
            anchors.right: dismissButton.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            anchors.rightMargin: 8
            spacing: 3

            Text {
                width: parent.width
                text: notificationRow.item ? notificationRow.item.summary : "Notification"
                color: Colors.foreground
                elide: Text.ElideRight
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                text: notificationRow.item ? notificationRow.item.appName : "app"
                color: Colors.muted
                elide: Text.ElideRight
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize - 1
            }

            Text {
                id: bodyText
                width: parent.width
                visible: text.length > 0
                text: notificationRow.item ? notificationRow.item.body : ""
                color: Colors.muted
                elide: Text.ElideRight
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize - 1
                textFormat: Text.PlainText
            }
        }

        Text {
            id: dismissButton
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "󰅖"
            color: Colors.foreground
            font.family: settings.fontFamily
            font.pixelSize: 14

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.NotificationService.dismiss(notificationRow.item)
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Services.NotificationService.dismiss(notificationRow.item)
        }
    }
}
