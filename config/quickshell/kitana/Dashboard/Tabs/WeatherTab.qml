// Kitana managed Quickshell dashboard tab

import QtQuick
import QtQuick.Layouts
import "../.."
import "../Components"
import "../../Components/Controls" as Controls
import "../../custom" as Custom

ColumnLayout {
    Custom.Settings { id: settings }

    property var dashboard: null
    property var weatherPrefs: null
    readonly property var root: dashboard
    readonly property var weather: root ? root.weather : ({})

    spacing: 12

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            radius: 10
            color: Colors.panelCardBackground
            border.color: locationInput.activeFocus ? Colors.panelButtonBorderActive : Colors.panelBorder
            border.width: 1

            TextInput {
                id: locationInput
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                text: root.weatherLocation
                echoMode: weatherPrefs.hideLocation ? TextInput.Password : TextInput.Normal
                color: Colors.primaryForeground
                selectionColor: Colors.panelButtonBackgroundActive
                selectedTextColor: Colors.primaryForeground
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                onEditingFinished: {
                    root.weatherLocation = text;
                    root.refreshWeather();
                }
            }
        }

        MiniButton {
            text: weatherPrefs.hideLocation ? Icons.visibilityOff : Icons.visibility
            iconText: true
            widthOverride: 46
            heightOverride: 34
            onClicked: weatherPrefs.hideLocation = !weatherPrefs.hideLocation
        }

        MiniButton {
            text: root.weatherUnits === "C" ? "°C" : "°F"
            widthOverride: 46
            heightOverride: 34
            onClicked: root.weatherUnits = root.weatherUnits === "C" ? "F" : "C"
        }

        MiniButton { text: Icons.refresh; iconText: true; heightOverride: 34; onClicked: root.refreshWeather() }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 122
        radius: 16
        color: Colors.panelContainerBackground
        border.color: Colors.panelContainerBorder
        border.width: 1

        RowLayout {
            id: weatherSummaryContent
            anchors.centerIn: parent
            width: Math.min(parent.width - 32, implicitWidth)
            spacing: 14

            Controls.Icon {
                Layout.alignment: Qt.AlignVCenter
                icon: Icons.weather
                color: Colors.accentForeground
                size: 42
            }

            ColumnLayout {
                Layout.preferredWidth: 150
                Layout.alignment: Qt.AlignVCenter
                spacing: 4

                Text {
                    text: weather.current_condition ? root.tempValue(weather.current_condition[0], "temp_C", "temp_F") : "--°"
                    color: Colors.primaryForeground
                    font.family: Typography.fontFamily
                    font.pixelSize: 28
                    font.weight: Font.Bold
                }

                Text {
                    text: weather.current_condition ? weather.current_condition[0].weatherDesc[0].value : root.weatherStatus
                    color: Colors.mutedForeground
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize + 1
                }

                Text {
                    text: weather.nearest_area ? weather.nearest_area[0].areaName[0].value : root.weatherLocation
                    color: Colors.mutedForeground
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                }
            }

            Item {
                Layout.preferredWidth: weatherMetricGrid.width
                Layout.preferredHeight: weatherMetricGrid.implicitHeight
                Layout.alignment: Qt.AlignVCenter

                GridLayout {
                    id: weatherMetricGrid
                    anchors.centerIn: parent
                    width: (3 * 108) + (2 * 28)
                    columns: 3
                    rowSpacing: 10
                    columnSpacing: 28
                    WeatherMetric { icon: Icons.waterDrop; label: "Humidity"; value: weather.current_condition ? weather.current_condition[0].humidity + "%" : "--" }
                    WeatherMetric { icon: Icons.wind; label: "Wind"; value: root.windValue(weather.current_condition ? weather.current_condition[0] : null) }
                    WeatherMetric { icon: Icons.thermometer; label: "Feels"; value: weather.current_condition ? root.tempValue(weather.current_condition[0], "FeelsLikeC", "FeelsLikeF") : "--" }
                    WeatherMetric { icon: Icons.waterDrop; label: "Precip"; value: weather.current_condition ? weather.current_condition[0].precipMM + " mm" : "--" }
                    WeatherMetric { icon: Icons.pressure; label: "Pressure"; value: weather.current_condition ? weather.current_condition[0].pressure + " hPa" : "--" }
                    WeatherMetric { icon: Icons.visibility; label: "Visibility"; value: weather.current_condition ? weather.current_condition[0].visibility + " km" : "--" }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 74
        radius: 14
        color: Colors.panelContainerBackground
        border.color: Colors.panelContainerBorder
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            WeatherMetric { icon: Icons.sunrise; label: "Sunrise"; value: weather.weather ? weather.weather[0].astronomy[0].sunrise : "--"; centerContent: true; Layout.fillWidth: true }
            WeatherMetric { icon: Icons.sunset; label: "Sunset"; value: weather.weather ? weather.weather[0].astronomy[0].sunset : "--"; centerContent: true; Layout.fillWidth: true }
            WeatherMetric { icon: Icons.moon; label: "Moon"; value: weather.weather ? weather.weather[0].astronomy[0].moon_phase : "--"; centerContent: true; Layout.fillWidth: true }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 5
        rowSpacing: 10
        columnSpacing: 10

        Repeater {
            model: root.forecastDays()

            Rectangle {
                required property var modelData

                Layout.fillWidth: true
                Layout.preferredHeight: 96
                radius: 14
                color: Colors.panelCardBackground
                border.color: Colors.panelBorder
                border.width: 1

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Text {
                        width: parent.width
                        text: Qt.formatDate(new Date(modelData.date), "ddd")
                        color: Colors.primaryForeground
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }

                    Text {
                        width: parent.width
                        text: modelData.hourly && modelData.hourly.length > 0 ? modelData.hourly[4].weatherDesc[0].value : ""
                        color: Colors.mutedForeground
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                    }

                    Row {
                        width: implicitWidth
                        spacing: 3
                        anchors.horizontalCenter: parent.horizontalCenter

                        Controls.Icon {
                            id: forecastIcon

                            icon: modelData.hourly && modelData.hourly.length > 0 && modelData.hourly[4].chanceofrain > 0 ? Icons.waterDrop : Icons.weather
                            color: Colors.accentForeground
                            size: settings.textPixelSize
                        }

                        Text {
                            id: chanceText

                            visible: modelData.hourly && modelData.hourly.length > 0 && modelData.hourly[4].chanceofrain > 0
                            text: visible ? modelData.hourly[4].chanceofrain + "%" : ""
                            color: Colors.accentForeground
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                        }
                    }

                    Text {
                        width: parent.width
                        text: root.weatherUnits === "F" ? modelData.mintempF + "°/" + modelData.maxtempF + "°" : modelData.mintempC + "°/" + modelData.maxtempC + "°"
                        color: Colors.mutedForeground
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                    }
                }
            }
        }
    }

    Item { Layout.fillHeight: true }

    Text {
        Layout.fillWidth: true
        text: "Weather data from wttr.in"
        color: Colors.mutedForeground
        horizontalAlignment: Text.AlignRight
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize - 1
    }
}
