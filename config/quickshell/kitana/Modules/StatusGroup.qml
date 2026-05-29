// Kitana managed Quickshell module

import QtQuick
import QtQuick.Layouts
import ".."
import "../custom" as Custom
import "../Services" as Services

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property var systemPanel: null

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
