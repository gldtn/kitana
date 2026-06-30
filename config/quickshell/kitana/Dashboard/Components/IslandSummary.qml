// Kitana managed Quickshell dashboard component

import QtQuick
import "../.."
import "../../Components/Controls" as Controls
import "../../Services" as Services
import "../../custom" as Custom

Item {
    id: root

    Custom.Settings {
        id: settings
    }

    property var dashboardPanel: null

    readonly property var weatherCondition: dashboardPanel && dashboardPanel.weather && dashboardPanel.weather.current_condition ? dashboardPanel.weather.current_condition[0] : null
    readonly property string weatherTemperature: weatherCondition && dashboardPanel ? dashboardPanel.tempValue(weatherCondition, "temp_C", "temp_F") : ""
    readonly property bool weatherVisible: weatherTemperature.length > 0 && weatherTemperature !== "--"

    implicitHeight: Services.UiPreferences.pillHeight
    implicitWidth: clockRow.implicitWidth
    width: implicitWidth
    height: implicitHeight

    // Date, time, and weather summary for the collapsed island.
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

        // Date/time separator dot
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "•"
            textFormat: Text.PlainText
            color: Colors.barItemFg
            font.family: Typography.fontFamily
            font.pixelSize: settings.clockPixelSize - 1
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

        // Time/weather separator dot
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.weatherVisible
            text: "•"
            textFormat: Text.PlainText
            color: Colors.barItemFg
            font.family: Typography.fontFamily
            font.pixelSize: settings.clockPixelSize - 1
            font.weight: Font.DemiBold
        }

        // Current weather icon and temperature
        Row {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.weatherVisible
            spacing: 5

            Controls.Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "weather.default"
                tone: "primary"
                sizeRole: "bar"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.weatherTemperature
                textFormat: Text.PlainText
                color: Colors.barItemFg
                font.family: Typography.fontFamily
                font.pixelSize: settings.clockPixelSize
                font.weight: Font.DemiBold
            }
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
