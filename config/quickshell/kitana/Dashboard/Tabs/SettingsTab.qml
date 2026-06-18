// Kitana managed Quickshell dashboard tab

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../.."
import "../Components"
import "../../custom" as Custom

ColumnLayout {
    id: tabRoot

    Custom.Settings { id: settings }

    property var dashboard: null
    property var weatherPrefs: null
    property var worldClockPrefs: null
    readonly property var panel: dashboard

    spacing: 12

    // Dashboard settings heading
    Text {
        Layout.fillWidth: true
        text: "Dashboard Settings"
        color: Colors.controlForeground
        font.family: Typography.fontFamily
        font.pixelSize: 16
        font.weight: Font.Bold
    }

    // Weather location and unit settings card
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 128
        radius: 16
        color: Colors.containerBackground
        border.color: Colors.containerBorder
        border.width: 0.8

        // Weather settings form
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: "Weather"
                color: Colors.controlForeground
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }

            // Location, privacy, and unit controls
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                DashboardField {
                    Layout.fillWidth: true
                    label: "Location"
                    value: tabRoot.panel.weatherLocation
                    secret: tabRoot.weatherPrefs.hideLocation
                    onCommitted: value => {
                        tabRoot.panel.weatherLocation = value;
                        tabRoot.panel.refreshWeather();
                    }
                }

                MiniButton {
                    Layout.alignment: Qt.AlignBottom
                    iconName: tabRoot.weatherPrefs.hideLocation ? "weather.visibility.off" : "weather.visibility"
                    widthOverride: 46
                    heightOverride: 34
                    onClicked: tabRoot.weatherPrefs.hideLocation = !tabRoot.weatherPrefs.hideLocation
                }

                MiniButton {
                    Layout.alignment: Qt.AlignBottom
                    text: tabRoot.panel.weatherUnits === "C" ? "°C" : "°F"
                    widthOverride: 46
                    heightOverride: 34
                    onClicked: tabRoot.panel.weatherUnits = tabRoot.panel.weatherUnits === "C" ? "F" : "C"
                }
            }
        }
    }

    // World clock name and timezone settings card
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 184
        radius: 16
        color: Colors.containerBackground
        border.color: Colors.containerBorder
        border.width: 0.8

        // World clock settings form
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: "World Clocks"
                color: Colors.controlForeground
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }

            // Clock name and timezone fields
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                DashboardField {
                    Layout.fillWidth: true
                    label: "Clock 1 Name"
                    value: tabRoot.worldClockPrefs.firstName
                    onCommitted: value => tabRoot.worldClockPrefs.firstName = value
                }

                DashboardField {
                    Layout.fillWidth: true
                    label: "Clock 1 Timezone"
                    value: tabRoot.worldClockPrefs.firstTimeZone
                    onCommitted: value => {
                        tabRoot.worldClockPrefs.firstTimeZone = value;
                        tabRoot.panel.refreshWorldClocks();
                    }
                }

                DashboardField {
                    Layout.fillWidth: true
                    label: "Clock 2 Name"
                    value: tabRoot.worldClockPrefs.secondName
                    onCommitted: value => tabRoot.worldClockPrefs.secondName = value
                }

                DashboardField {
                    Layout.fillWidth: true
                    label: "Clock 2 Timezone"
                    value: tabRoot.worldClockPrefs.secondTimeZone
                    onCommitted: value => {
                        tabRoot.worldClockPrefs.secondTimeZone = value;
                        tabRoot.panel.refreshWorldClocks();
                    }
                }
            }
        }
    }

    // Fill remaining tab space
    Item { Layout.fillHeight: true }
}
