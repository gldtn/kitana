// Kitana managed Quickshell module

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings {
        id: settings
    }

    property var dashboardPanel: null

    implicitHeight: settings.pillHeight
    implicitWidth: clockRow.implicitWidth + settings.clockHorizontalPadding
    width: implicitWidth
    height: implicitHeight

    radius: height / settings.radiusDivisor
    color: Colors.panelBackground
    border.color: Colors.panelBorder
    border.width: settings.borderWidth

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 10

        property date now: new Date()

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDate(clockRow.now, "ddd MMM d")
            color: Colors.foreground
            font.family: Typography.fontFamily
            font.pixelSize: settings.clockPixelSize
            font.weight: Font.DemiBold
        }

        Rectangle {
            id: dashboardButton

            anchors.verticalCenter: parent.verticalCenter
            width: settings.iconPixelSize + 10
            height: settings.iconPixelSize + 8
            radius: 8
            color: dashboardMouse.containsMouse ? Colors.surfaceHover : "transparent"

            Controls.MaterialIcon {
                anchors.centerIn: parent
                icon: Icons.dashboard
                color: dashboardMouse.containsMouse ? Colors.foreground : Colors.accent
                size: settings.iconPixelSize
            }

            MouseArea {
                id: dashboardMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.dashboardPanel) root.dashboardPanel.toggle("datetime")
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(clockRow.now, "h:mm AP")
            color: Colors.foreground
            font.family: Typography.fontFamily
            font.pixelSize: settings.clockPixelSize
            font.weight: Font.DemiBold
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockRow.now = new Date()
        }
    }
}
