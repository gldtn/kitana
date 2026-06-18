// Kitana managed Quickshell module

import QtQuick
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Item {
    id: root

    Custom.Settings {
        id: settings
    }

    property var dashboardPanel: null
    property bool embedded: false

    implicitHeight: settings.pillHeight
    implicitWidth: clockRow.implicitWidth + settings.clockHorizontalPadding
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        anchors.fill: parent
        visible: !root.embedded
        radius: root.height / settings.radiusDivisor
        color: Colors.barBackground
        border.color: Colors.barBorder
        border.width: settings.borderWidth
    }

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 10

        property date now: new Date()

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDate(clockRow.now, "ddd MMM d")
            textFormat: Text.PlainText
            color: Colors.barForeground
            font.family: Typography.fontFamily
            font.pixelSize: settings.clockPixelSize
            font.weight: Font.DemiBold
        }

        Item {
            id: dashboardButton

            anchors.verticalCenter: parent.verticalCenter
            width: settings.iconPixelSize + 10
            height: settings.iconPixelSize + 8

            Rectangle {
                anchors.fill: parent
                visible: dashboardMouse.containsMouse
                radius: 8
                color: Colors.barHoverBackground
            }

            Controls.Icon {
                anchors.centerIn: parent
                name: "dashboard"
                tone: dashboardMouse.containsMouse ? "primary" : "accent"
                sizeRole: "bar"
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
            textFormat: Text.PlainText
            color: Colors.barForeground
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
