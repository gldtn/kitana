// Kitana managed Quickshell module

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import ".."
import "../custom" as Custom
import "../Services" as Services

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property var systemPanel: null
    property var panelWindow: null

    function trayIconSourceFor(item: var): string {
        const icon = item && item.icon;
        if (typeof icon !== "string" && !(icon instanceof String))
            return "";

        if (icon.length === 0)
            return "";

        const iconName = icon.replace("image://icon/", "");
        if (iconName === "insync-synced")
            return "file:///usr/share/icons/hicolor/scalable/status/insync-synced.svg";
        if (iconName === "insync-syncing")
            return "file:///usr/share/icons/hicolor/scalable/status/insync-syncing.svg";
        if (iconName === "insync-paused")
            return "file:///usr/share/icons/hicolor/scalable/status/insync-paused.svg";
        if (iconName === "insync-offline")
            return "file:///usr/share/icons/hicolor/scalable/status/insync-offline.svg";
        if (iconName === "insync-alert")
            return "file:///usr/share/icons/hicolor/scalable/status/insync-alert.svg";

        const pathIndex = icon.indexOf("?path=");
        if (pathIndex === -1)
            return icon;

        let name = icon.slice(0, pathIndex);
        const path = icon.slice(pathIndex + 6);

        name = name.slice(name.lastIndexOf("/") + 1);
        if (name.indexOf("dropboxstatus") === 0)
            name = "hicolor/16x16/status/" + name + ".png";

        return "file://" + path + "/" + name;
    }

    function trayFallbackText(item: var): string {
        const title = item && item.title ? item.title : "";
        const id = item && item.id ? item.id : "";
        const label = title || id;

        return label.length > 0 ? label.charAt(0).toUpperCase() : "?";
    }

    function callContextMenuFallback(item: var, globalX: int, globalY: int): void {
        if (!item || !item.id)
            return;

        const script = [
            'ITEMS=$(dbus-send --session --print-reply --dest=org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.freedesktop.DBus.Properties.Get string:org.kde.StatusNotifierWatcher string:RegisteredStatusNotifierItems 2>/dev/null)',
            'while IFS= read -r line; do',
            '  line="${line#*\\\"}"',
            '  line="${line%\\\"*}"',
            '  [ -z "$line" ] && continue',
            '  BUS="${line%%/*}"',
            '  OBJ="/${line#*/}"',
            '  ID=$(dbus-send --session --print-reply --dest="$BUS" "$OBJ" org.freedesktop.DBus.Properties.Get string:org.kde.StatusNotifierItem string:Id 2>/dev/null | grep -oP "(?<=\\\")(.*?)(?=\\\")" | tail -1)',
            '  if [ "$ID" = "$1" ]; then',
            '    dbus-send --session --type=method_call --dest="$BUS" "$OBJ" org.kde.StatusNotifierItem.ContextMenu int32:"$2" int32:"$3"',
            '    exit 0',
            '  fi',
            'done <<< "$ITEMS"'
        ].join("\n");

        Quickshell.execDetached(["bash", "-c", script, "_", item.id, String(globalX), String(globalY)]);
    }

    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
    Layout.preferredHeight: settings.pillHeight
    Layout.preferredWidth: statusRow.implicitWidth + settings.statusHorizontalPadding

    radius: height / settings.radiusDivisor
    color: Colors.panel
    border.color: Colors.panelBorder
    border.width: settings.borderWidth

    Row {
        id: statusRow

        anchors.centerIn: parent
        spacing: settings.statusSpacing

        Row {
            id: trayRow

            anchors.verticalCenter: parent.verticalCenter
            visible: SystemTray.items.values.length > 0
            spacing: settings.statusItemSpacing

            Repeater {
                model: SystemTray.items

                delegate: Item {
                    id: trayButton

                    required property var modelData

                    width: settings.iconPixelSize + 6
                    height: settings.iconPixelSize + 6

                    function displayMenu(mouse: var): void {
                        if (!root.panelWindow)
                            return;

                        if (modelData.hasMenu) {
                            const point = trayButton.mapToItem(null, 0, trayButton.height);
                            modelData.display(root.panelWindow, Math.round(point.x), Math.round(point.y));
                            return;
                        }

                        const globalPoint = trayMouse.mapToGlobal(mouse.x, mouse.y);
                        root.callContextMenuFallback(modelData, Math.round(globalPoint.x), Math.round(globalPoint.y));
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: trayMouse.containsMouse ? Colors.surfaceHover : "transparent"
                    }

                    Image {
                        id: trayIcon

                        anchors.centerIn: parent
                        visible: source.length > 0 && status === Image.Ready
                        width: settings.iconPixelSize
                        height: settings.iconPixelSize
                        source: root.trayIconSourceFor(trayButton.modelData)
                        asynchronous: true
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                    }

                    Text {
                        id: trayGlyph

                        anchors.centerIn: parent
                        visible: !trayIcon.visible
                        text: root.trayFallbackText(trayButton.modelData)
                        color: trayMouse.containsMouse ? Colors.foreground : Colors.accent
                        horizontalAlignment: Text.AlignHCenter
                        font.family: settings.fontFamily
                        font.pixelSize: settings.iconPixelSize
                    }

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

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            visible: trayRow.visible
            width: 1
            height: settings.iconPixelSize
            radius: 1
            color: Colors.panelBorder
        }

        StatusButton {
            icon: Services.NotificationService.count > 0 ? "󱅫" : "󰂚"
            label: ""
            onClicked: if (root.systemPanel) root.systemPanel.toggle("notifications")
        }

        StatusButton {
            icon: "󰦖"
            label: ""
            onClicked: if (root.systemPanel) root.systemPanel.toggle("sessions")
        }

        StatusButton {
            icon: Services.SystemStatus.bluetoothIcon
            label: ""
            onClicked: if (root.systemPanel) root.systemPanel.toggle("bluetooth")
        }

        StatusButton {
            icon: Services.SystemStatus.networkIcon
            label: ""
            onClicked: if (root.systemPanel) root.systemPanel.toggle("network")
        }

        StatusButton {
            icon: Services.SystemStatus.audioIcon
            label: ""
            onClicked: if (root.systemPanel) root.systemPanel.toggle("audio")
        }
    }

    component StatusButton: Item {
        id: button

        property string icon: ""
        property string label: ""
        signal clicked

        width: buttonRow.implicitWidth
        height: buttonRow.implicitHeight

        Row {
            id: buttonRow

            spacing: settings.statusItemSpacing

            Text {
                width: settings.iconPixelSize + 4
                text: button.icon
                color: mouse.containsMouse ? Colors.foreground : Colors.accent
                horizontalAlignment: Text.AlignHCenter
                font.family: settings.fontFamily
                font.pixelSize: settings.iconPixelSize
            }

            Text {
                text: button.label
                visible: text.length > 0
                color: Colors.foreground
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
