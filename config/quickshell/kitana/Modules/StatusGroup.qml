// Kitana managed Quickshell module

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets as QW
import ".."
import "../custom" as Custom
import "../Services" as Services

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property var systemPanel: null
    property var panelWindow: null
    property bool trayExpanded: false

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

    implicitHeight: settings.pillHeight
    implicitWidth: statusRow.implicitWidth + settings.statusHorizontalPadding
    width: implicitWidth
    height: implicitHeight

    radius: height / settings.radiusDivisor
    color: Colors.panelBackground
    border.color: Colors.panelBorder
    border.width: settings.borderWidth

    Row {
        id: statusRow

        anchors.right: parent.right
        anchors.rightMargin: settings.statusHorizontalPadding / 2
        anchors.verticalCenter: parent.verticalCenter
        spacing: settings.statusSpacing

        QsMenuAnchor {
            id: trayMenuAnchor

            anchor.edges: Edges.Bottom | Edges.Left
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.adjustment: PopupAdjustment.None
        }

        Item {
            id: traySection

            anchors.verticalCenter: parent.verticalCenter
            visible: SystemTray.items.values.length > 0
            width: trayToggle.width + trayContainer.width + (root.trayExpanded && trayContainer.width > 0 ? settings.statusItemSpacing : 0)
            implicitWidth: width
            height: statusRow.height

            StatusButton {
                id: trayToggle
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                icon: root.trayExpanded ? "" : ""
                label: ""
                onClicked: root.trayExpanded = !root.trayExpanded
            }

            Item {
                id: trayContainer

                anchors.left: trayToggle.right
                anchors.leftMargin: root.trayExpanded ? settings.statusItemSpacing : 0
                anchors.verticalCenter: parent.verticalCenter
                width: root.trayExpanded ? trayRow.implicitWidth : 0
                height: parent.height
                clip: true

                Behavior on width {
                    NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                }

                Behavior on anchors.leftMargin {
                    NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                }

                Row {
                    id: trayRow

                    anchors.verticalCenter: parent.verticalCenter
                    spacing: settings.statusItemSpacing

                    Repeater {
                        model: SystemTray.items

                        delegate: Item {
                            id: trayButton

                            required property var modelData

                            width: settings.iconPixelSize + 6
                            height: settings.iconPixelSize + 8
                            clip: true

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

                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                                color: trayMouse.containsMouse ? Colors.surfaceHover : "transparent"
                            }

                            QW.IconImage {
                                anchors.centerIn: parent
                                width: settings.iconPixelSize
                                height: settings.iconPixelSize
                                implicitSize: settings.iconPixelSize
                                source: root.traySource(trayButton.modelData)
                                mipmap: true
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
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: traySection.visible && root.trayExpanded && trayContainer.width > 0
            text: "|"
            color: Colors.muted
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize
            verticalAlignment: Text.AlignVCenter
        }

        StatusButton {
            icon: Services.NotificationService.count > 0 ? "󱅫" : "󰂚"
            label: ""
            onClicked: if (root.systemPanel) root.systemPanel.toggle("notifications")
        }

        StatusButton {
            icon: Services.SystemStatus.audioIcon
            label: ""
            onClicked: if (root.systemPanel) root.systemPanel.toggle("audio")
        }

        StatusButton {
            visible: Services.SystemStatus.micAvailable
            icon: Services.SystemStatus.micIcon
            label: ""
            onClicked: if (root.systemPanel) root.systemPanel.toggle("audio")
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
            icon: "󰦖"
            label: ""
            onClicked: if (root.systemPanel) root.systemPanel.toggle("sessions")
        }
    }

    component StatusButton: Item {
        id: button

        property string icon: ""
        property string label: ""
        signal clicked

        width: visible ? buttonRow.implicitWidth : 0
        height: settings.iconPixelSize + 8

        Row {
            id: buttonRow

            anchors.centerIn: parent
            spacing: settings.statusItemSpacing

            Text {
                width: settings.iconPixelSize + 4
                height: button.height
                text: button.icon
                color: mouse.containsMouse ? Colors.foreground : Colors.accent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: settings.fontFamily
                font.pixelSize: settings.iconPixelSize
            }

            Text {
                height: button.height
                text: button.label
                visible: text.length > 0
                color: Colors.foreground
                verticalAlignment: Text.AlignVCenter
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
