// Kitana managed Quickshell dashboard tab

import QtQuick
import QtQuick.Layouts
import "../.."
import "../Components"
import "../../custom" as Custom

ColumnLayout {
    Custom.Settings { id: settings }

    property var dashboard: null
    property var weatherPrefs: null
    property var worldClockPrefs: null
    readonly property var root: dashboard

    spacing: 12

    Text {
        Layout.fillWidth: true
        text: "Dashboard Settings"
        color: Colors.foreground
        font.family: Typography.fontFamily
        font.pixelSize: 16
        font.weight: Font.Bold
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 128
        radius: 16
        color: Colors.containerBackground
        border.color: Colors.containerBorder
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: "Weather"
                color: Colors.foreground
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                DashboardField {
                    Layout.fillWidth: true
                    label: "Location"
                    value: root.weatherLocation
                    secret: weatherPrefs.hideLocation
                    onCommitted: value => {
                        root.weatherLocation = value;
                        root.refreshWeather();
                    }
                }

                MiniButton {
                    Layout.alignment: Qt.AlignBottom
                    iconName: weatherPrefs.hideLocation ? "weather.visibility.off" : "weather.visibility"
                    widthOverride: 46
                    heightOverride: 34
                    onClicked: weatherPrefs.hideLocation = !weatherPrefs.hideLocation
                }

                MiniButton {
                    Layout.alignment: Qt.AlignBottom
                    text: root.weatherUnits === "C" ? "°C" : "°F"
                    widthOverride: 46
                    heightOverride: 34
                    onClicked: root.weatherUnits = root.weatherUnits === "C" ? "F" : "C"
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 184
        radius: 16
        color: Colors.containerBackground
        border.color: Colors.containerBorder
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: "World Clocks"
                color: Colors.foreground
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                DashboardField {
                    Layout.fillWidth: true
                    label: "Clock 1 Name"
                    value: worldClockPrefs.firstName
                    onCommitted: value => worldClockPrefs.firstName = value
                }

                DashboardField {
                    Layout.fillWidth: true
                    label: "Clock 1 Timezone"
                    value: worldClockPrefs.firstTimeZone
                    onCommitted: value => {
                        worldClockPrefs.firstTimeZone = value;
                        root.refreshWorldClocks();
                    }
                }

                DashboardField {
                    Layout.fillWidth: true
                    label: "Clock 2 Name"
                    value: worldClockPrefs.secondName
                    onCommitted: value => worldClockPrefs.secondName = value
                }

                DashboardField {
                    Layout.fillWidth: true
                    label: "Clock 2 Timezone"
                    value: worldClockPrefs.secondTimeZone
                    onCommitted: value => {
                        worldClockPrefs.secondTimeZone = value;
                        root.refreshWorldClocks();
                    }
                }
            }
        }
    }

    Item { Layout.fillHeight: true }
}
