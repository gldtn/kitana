// Kitana managed Quickshell module

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets as QW
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom
import "../../Services" as Services

Item {
    id: root

    Custom.Settings {
        id: settings
    }

    property var controlPanel: null
    property var panelWindow: null
    property bool trayExpanded: false
    property bool embedded: false

    function traySource(item: var): string {
        const icon = item && item.icon ? item.icon : "";
        if (icon.indexOf("?path=") !== -1 || icon.indexOf("dropboxstatus") !== -1 || icon.indexOf("insync-") !== -1)
            return trayFallbackIconSourceFor(item);
        return icon;
    }

    function trayFallbackIconSourceFor(item: var): string {
        const icon = item && item.icon ? item.icon : "";
        const pathIndex = icon.indexOf("?path=");

        if (pathIndex !== -1) {
            let name = icon.slice(0, pathIndex);
            const path = icon.slice(pathIndex + 6);

            name = name.slice(name.lastIndexOf("/") + 1);
            if (name.indexOf("dropboxstatus") === 0)
                name = "hicolor/16x16/status/" + name + ".png";

            return "file://" + path + "/" + name;
        }

        const iconName = icon.replace("image://icon/", "");
        if (iconName.indexOf("insync-") === 0)
            return "file:///usr/share/icons/hicolor/48x48/status/" + iconName + ".png";

        return icon;
    }

    function callContextMenuFallback(item: var, globalX: int, globalY: int): void {
        if (!item || !item.id)
            return;

        const script = ['ITEMS=$(dbus-send --session --print-reply --dest=org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.freedesktop.DBus.Properties.Get string:org.kde.StatusNotifierWatcher string:RegisteredStatusNotifierItems 2>/dev/null)', 'while IFS= read -r line; do', '  line="${line#*\\\"}"', '  line="${line%\\\"*}"', '  [ -z "$line" ] && continue', '  BUS="${line%%/*}"', '  OBJ="/${line#*/}"', '  ID=$(dbus-send --session --print-reply --dest="$BUS" "$OBJ" org.freedesktop.DBus.Properties.Get string:org.kde.StatusNotifierItem string:Id 2>/dev/null | grep -oP "(?<=\\\")(.*?)(?=\\\")" | tail -1)', '  if [ "$ID" = "$1" ]; then', '    dbus-send --session --type=method_call --dest="$BUS" "$OBJ" org.kde.StatusNotifierItem.ContextMenu int32:"$2" int32:"$3"', '    exit 0', '  fi', 'done <<< "$ITEMS"'].join("\n");

        Quickshell.execDetached(["bash", "-c", script, "_", item.id, String(globalX), String(globalY)]);
    }

    implicitHeight: Services.UiPreferences.pillHeight
    implicitWidth: controlRow.implicitWidth + Services.UiPreferences.statusHorizontalPadding
    width: implicitWidth
    height: implicitHeight

    // Control cluster pill background
    Rectangle {
        anchors.fill: parent
        visible: !root.embedded
        radius: Services.UiPreferences.pillRadius
        color: Colors.barItemBg
        border.color: Colors.barItemBorder
        border.width: Services.UiPreferences.barBorderWidth
    }

    // Tray, notifications, and system control row
    Row {
        id: controlRow

        anchors.left: parent.left
        anchors.leftMargin: Services.UiPreferences.statusHorizontalPadding / 2
        anchors.verticalCenter: parent.verticalCenter
        spacing: settings.statusSpacing

        // System tray menu anchor
        QsMenuAnchor {
            id: trayMenuAnchor

            // qmllint disable missing-type
            anchor.edges: Edges.Bottom | Edges.Left
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.adjustment: PopupAdjustment.None
            // qmllint enable missing-type
        }

        // Expandable tray icon section
        Item {
            id: traySection

            anchors.verticalCenter: parent.verticalCenter
            visible: SystemTray.items.values.length > 0
            width: trayToggle.width + trayContainer.width + (root.trayExpanded && trayContainer.width > 0 ? settings.statusItemSpacing : 0)
            implicitWidth: width
            height: settings.iconPixelSize + 8

            // Tray expand/collapse button
            ControlButton {
                id: trayToggle
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                iconName: root.trayExpanded ? "ui.chevron.right" : "ui.chevron.left"
                iconSize: Icons.size("bar") + 4
                label: ""
                onClicked: root.trayExpanded = !root.trayExpanded
            }

            // Animated tray icon container
            Item {
                id: trayContainer

                anchors.left: trayToggle.right
                anchors.leftMargin: root.trayExpanded ? settings.statusItemSpacing : 0
                anchors.verticalCenter: parent.verticalCenter
                width: root.trayExpanded ? trayRow.implicitWidth : 0
                height: parent.height
                clip: true

                Behavior on width {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on anchors.leftMargin {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                // Visible tray icon row
                Row {
                    id: trayRow

                    anchors.verticalCenter: parent.verticalCenter
                    spacing: settings.statusItemSpacing

                    // System tray item repeater
                    Repeater {
                        model: SystemTray.items

                        // One tray icon button
                        delegate: Item {
                            id: trayButton

                            required property var modelData
                            readonly property string resolvedIconSource: root.traySource(modelData)

                            width: settings.iconPixelSize + 6
                            height: settings.iconPixelSize + 8

                            function displayMenu(mouse: var): void {
                                if (modelData.hasMenu) {
                                    if (trayMenuAnchor.visible)
                                        trayMenuAnchor.close();
                                    trayMenuAnchor.menu = modelData.menu;
                                    trayMenuAnchor.anchor.item = trayButton;
                                    trayMenuAnchor.open();
                                    return;
                                }

                                const globalPoint = trayMouse.mapToGlobal(mouse.x, mouse.y);
                                root.callContextMenuFallback(modelData, Math.round(globalPoint.x), Math.round(globalPoint.y));
                            }

                            // Tray hover background
                            Rectangle {
                                anchors.fill: parent
                                visible: trayMouse.containsMouse
                                radius: 6
                                color: Colors.bgTertiary
                            }

                            // Native tray icon image
                            QW.IconImage {
                                id: trayIcon

                                anchors.centerIn: parent
                                visible: trayButton.resolvedIconSource.length > 0 && (status === Image.Ready || status === Image.Loading)
                                width: settings.iconPixelSize
                                height: settings.iconPixelSize
                                implicitSize: settings.iconPixelSize
                                source: trayButton.resolvedIconSource
                                mipmap: true
                            }

                            // Fallback tray icon
                            Controls.Icon {
                                anchors.centerIn: parent
                                visible: !trayIcon.visible
                                name: Icons.defaultIcon
                                tone: "primary"
                                sizeRole: "bar"
                            }

                            // Tray activation target
                            MouseArea {
                                id: trayMouse

                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: mouse => {
                                    if (mouse.button === Qt.MiddleButton) {
                                        trayButton.modelData.secondaryActivate();
                                    } else if (mouse.button === Qt.RightButton || trayButton.modelData.onlyMenu) {
                                        trayButton.displayMenu(mouse);
                                    } else {
                                        trayButton.modelData.activate();
                                    }
                                }

                                onWheel: wheel => trayButton.modelData.scroll(wheel.angleDelta.y, false)
                            }
                        }
                    }
                }
            }
        }

        // Tray/control separator
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: traySection.visible && root.trayExpanded && trayContainer.width > 0
            text: "|"
            color: Colors.fgSecondary
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            verticalAlignment: Text.AlignVCenter
        }

        // Notifications control button
        ControlButton {
            iconName: Icons.notificationName(Services.NotificationService.count, Services.NotificationService.doNotDisturb)
            label: ""
            onClicked: if (root.controlPanel)
                root.controlPanel.toggle("notifications")
        }

        // Audio control button
        ControlButton {
            iconName: Services.SystemStatus.audioIconName
            alignIconLeft: true
            iconVisualOffset: 2
            label: ""
            onClicked: if (root.controlPanel)
                root.controlPanel.toggle("audio")
        }

        // Microphone control button
        ControlButton {
            visible: Services.SystemStatus.micAvailable
            iconName: Services.SystemStatus.micIconName
            label: ""
            onClicked: if (root.controlPanel)
                root.controlPanel.toggle("audio")
        }

        // Bluetooth control button
        ControlButton {
            iconName: Services.SystemStatus.bluetoothIconName
            label: ""
            onClicked: if (root.controlPanel)
                root.controlPanel.toggle("bluetooth")
        }

        // Network control button
        ControlButton {
            iconName: Services.SystemStatus.networkIconName
            label: ""
            onClicked: if (root.controlPanel)
                root.controlPanel.toggle("network")
        }
    }

    // Reusable control icon button
    component ControlButton: Item {
        id: button

        property string iconName: Icons.defaultIcon
        property string label: ""
        property int iconSize: 0
        property bool alignIconLeft: false
        property real iconVisualOffset: 0
        signal clicked

        width: visible ? buttonRow.implicitWidth : 0
        height: settings.iconPixelSize + 8

        // Button icon and optional label row
        Row {
            id: buttonRow

            anchors.centerIn: parent
            spacing: settings.statusItemSpacing

            // Button control icon
            Controls.Icon {
                width: settings.iconPixelSize + 4
                height: button.height
                name: button.iconName
                tone: mouse.containsMouse ? "primary" : "subtle"
                sizeRole: "bar"
                size: button.iconSize
                horizontalAlignment: button.alignIconLeft ? Text.AlignLeft : Text.AlignHCenter
                leftPadding: button.alignIconLeft ? button.iconVisualOffset : 0
            }

            // Optional button text label
            Text {
                height: button.height
                text: button.label
                visible: text.length > 0
                color: Colors.barItemFg
                verticalAlignment: Text.AlignVCenter
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }
        }

        // Control button click target
        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
