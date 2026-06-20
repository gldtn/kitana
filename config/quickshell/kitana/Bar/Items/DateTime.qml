// Kitana managed Quickshell module

import QtQuick
import "../.."
import "../../Services" as Services
import "../../custom" as Custom

Item {
    id: root

    Custom.Settings {
        id: settings
    }

    implicitHeight: Services.UiPreferences.pillHeight
    implicitWidth: clockRow.implicitWidth
    width: implicitWidth
    height: implicitHeight

    // Date and time row
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
            color: Colors.barItemFg
            font.family: Typography.fontFamily
            font.pixelSize: settings.clockPixelSize
            font.weight: Font.DemiBold
        }

        // Current time label
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(clockRow.now, "h:mm AP")
            textFormat: Text.PlainText
            color: Colors.barItemFg
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
