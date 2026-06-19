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

    // Clock pill background
    Rectangle {
        anchors.fill: parent
        visible: !root.embedded
        radius: root.height / settings.radiusDivisor
        color: Colors.bgSecondary
        border.color: Colors.borderFaint
        border.width: settings.borderWidth
    }

    // Date, dashboard button, and time row
    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 10

        property date now: new Date()

        // Current date label
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDate(clockRow.now, "ddd MMM d")
            textFormat: Text.PlainText
            color: Colors.fgPrimary
            font.family: Typography.fontFamily
            font.pixelSize: settings.clockPixelSize
            font.weight: Font.DemiBold
        }

        // Dashboard opener button
        Item {
            id: dashboardButton

            anchors.verticalCenter: parent.verticalCenter
            width: settings.iconPixelSize + 10
            height: settings.iconPixelSize + 8

            // Dashboard button hover background
            Rectangle {
                anchors.fill: parent
                visible: dashboardMouse.containsMouse
                radius: 8
                color: Colors.bgTertiary
            }

            // Dashboard icon
            Controls.Icon {
                anchors.centerIn: parent
                name: "dashboard"
                tone: dashboardMouse.containsMouse ? "primary" : "accent"
                sizeRole: "bar"
            }

            // Dashboard click target
            MouseArea {
                id: dashboardMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.dashboardPanel) root.dashboardPanel.toggle("datetime")
            }
        }

        // Current time label
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(clockRow.now, "h:mm AP")
            textFormat: Text.PlainText
            color: Colors.fgPrimary
            font.family: Typography.fontFamily
            font.pixelSize: settings.clockPixelSize
            font.weight: Font.DemiBold
        }

        // Clock refresh timer
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockRow.now = new Date()
        }
    }
}
