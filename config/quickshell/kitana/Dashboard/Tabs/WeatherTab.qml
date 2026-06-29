// Kitana managed Quickshell dashboard tab

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../.."
import "../Components"
import "../../Components/Controls" as Controls
import "../../custom" as Custom

ColumnLayout {
    id: tabRoot

    Custom.Settings {
        id: settings
    }

    property var dashboard: null
    property var weatherPrefs: null
    readonly property var panel: dashboard
    readonly property var weatherData: panel ? panel.weather : ({})

    spacing: 12

    // Weather search and unit controls
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Controls.InputField {
            id: locationInput

            Layout.fillWidth: true
            fieldHeight: 34
            radius: 10
            text: tabRoot.panel.weatherLocation
            echoMode: tabRoot.weatherPrefs.hideLocation ? TextInput.Password : TextInput.Normal
            onEscaped: tabRoot.panel.close()
            onEditingFinished: {
                tabRoot.panel.weatherLocation = locationInput.text;
                tabRoot.panel.refreshWeather();
            }
        }

        MiniButton {
            iconName: tabRoot.weatherPrefs.hideLocation ? "weather.visibility.off" : "weather.visibility"
            widthOverride: 46
            heightOverride: 34
            onClicked: tabRoot.weatherPrefs.hideLocation = !tabRoot.weatherPrefs.hideLocation
        }

        MiniButton {
            text: tabRoot.panel.weatherUnits === "C" ? "°C" : "°F"
            widthOverride: 46
            heightOverride: 34
            onClicked: tabRoot.panel.weatherUnits = tabRoot.panel.weatherUnits === "C" ? "F" : "C"
        }

        MiniButton {
            iconName: "ui.refresh"
            heightOverride: 34
            onClicked: tabRoot.panel.refreshWeather()
        }
    }

    // Current weather summary card
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 122
        radius: tabRoot.panel.sectionRadius
        color: tabRoot.panel.sectionContainer
        border.color: tabRoot.panel.sectionBorder
        border.width: tabRoot.panel.sectionBorderWidth

        // Weather condition and metric content
        RowLayout {
            id: weatherSummaryContent
            anchors.centerIn: parent
            width: Math.min(parent.width - 32, implicitWidth)
            spacing: 14

            Controls.Icon {
                Layout.alignment: Qt.AlignVCenter
                name: "weather.default"
                tone: "accent"
                size: 42
            }

            // Temperature, condition, and location labels
            ColumnLayout {
                Layout.preferredWidth: 150
                Layout.alignment: Qt.AlignVCenter
                spacing: 4

                Text {
                    text: tabRoot.weatherData.current_condition ? tabRoot.panel.tempValue(tabRoot.weatherData.current_condition[0], "temp_C", "temp_F") : "--°"
                    color: Colors.fgPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: 28
                    font.weight: Font.Bold
                }

                Text {
                    text: tabRoot.weatherData.current_condition ? tabRoot.weatherData.current_condition[0].weatherDesc[0].value : tabRoot.panel.weatherStatus
                    color: Colors.fgSecondary
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize + 1
                }

                Text {
                    text: tabRoot.weatherData.nearest_area ? tabRoot.weatherData.nearest_area[0].areaName[0].value : tabRoot.panel.weatherLocation
                    color: Colors.fgSecondary
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                }
            }

            // Current weather metric grid wrapper
            Item {
                Layout.preferredWidth: weatherMetricGrid.width
                Layout.preferredHeight: weatherMetricGrid.implicitHeight
                Layout.alignment: Qt.AlignVCenter

                // Humidity, wind, feels-like, and visibility metrics
                GridLayout {
                    id: weatherMetricGrid
                    anchors.centerIn: parent
                    width: (3 * 108) + (2 * 28)
                    columns: 3
                    rowSpacing: 10
                    columnSpacing: 28
                    WeatherMetric {
                        iconName: "weather.water"
                        label: "Humidity"
                        value: tabRoot.weatherData.current_condition ? tabRoot.weatherData.current_condition[0].humidity + "%" : "--"
                    }
                    WeatherMetric {
                        iconName: "weather.wind"
                        label: "Wind"
                        value: tabRoot.panel.windValue(tabRoot.weatherData.current_condition ? tabRoot.weatherData.current_condition[0] : null)
                    }
                    WeatherMetric {
                        iconName: "weather.thermometer"
                        label: "Feels"
                        value: tabRoot.weatherData.current_condition ? tabRoot.panel.tempValue(tabRoot.weatherData.current_condition[0], "FeelsLikeC", "FeelsLikeF") : "--"
                    }
                    WeatherMetric {
                        iconName: "weather.water"
                        label: "Precip"
                        value: tabRoot.weatherData.current_condition ? tabRoot.weatherData.current_condition[0].precipMM + " mm" : "--"
                    }
                    WeatherMetric {
                        iconName: "weather.pressure"
                        label: "Pressure"
                        value: tabRoot.weatherData.current_condition ? tabRoot.weatherData.current_condition[0].pressure + " hPa" : "--"
                    }
                    WeatherMetric {
                        iconName: "weather.visibility"
                        label: "Visibility"
                        value: tabRoot.weatherData.current_condition ? tabRoot.weatherData.current_condition[0].visibility + " km" : "--"
                    }
                }
            }
        }
    }

    // Astronomy summary card
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 74
        radius: tabRoot.panel.sectionRadius
        color: tabRoot.panel.sectionContainer
        border.color: tabRoot.panel.sectionBorder
        border.width: tabRoot.panel.sectionBorderWidth

        // Sunrise, sunset, and moon metrics
        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            WeatherMetric {
                iconName: "weather.sunrise"
                label: "Sunrise"
                value: tabRoot.weatherData.weather ? tabRoot.weatherData.weather[0].astronomy[0].sunrise : "--"
                centerContent: true
                Layout.fillWidth: true
            }
            WeatherMetric {
                iconName: "weather.sunset"
                label: "Sunset"
                value: tabRoot.weatherData.weather ? tabRoot.weatherData.weather[0].astronomy[0].sunset : "--"
                centerContent: true
                Layout.fillWidth: true
            }
            WeatherMetric {
                iconName: "weather.moon"
                label: "Moon"
                value: tabRoot.weatherData.weather ? tabRoot.weatherData.weather[0].astronomy[0].moon_phase : "--"
                centerContent: true
                Layout.fillWidth: true
            }
        }
    }

    // Forecast card grid
    GridLayout {
        Layout.fillWidth: true
        columns: 5
        rowSpacing: 10
        columnSpacing: 10

        // One forecast card per day
        Repeater {
            model: tabRoot.panel.forecastDays()

            // Daily forecast card
            Rectangle {
                id: forecastCard

                required property var modelData
                readonly property var forecastHours: modelData.hourly || []
                readonly property var forecastHour: forecastHours.length > 4 ? forecastHours[4] : (forecastHours.length > 0 ? forecastHours[0] : null)

                Layout.fillWidth: true
                Layout.preferredHeight: 96
                radius: tabRoot.panel.sectionRadius
                color: tabRoot.panel.sectionContainer
                border.color: tabRoot.panel.sectionBorder
                border.width: tabRoot.panel.sectionBorderWidth

                // Forecast day details
                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Text {
                        width: parent.width
                        text: Qt.formatDate(new Date(forecastCard.modelData.date), "ddd")
                        color: Colors.fgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }

                    Text {
                        width: parent.width
                        text: forecastCard.forecastHour ? forecastCard.forecastHour.weatherDesc[0].value : ""
                        color: Colors.fgSecondary
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                    }

                    // Rain chance row
                    Row {
                        width: implicitWidth
                        spacing: 3
                        anchors.horizontalCenter: parent.horizontalCenter

                        Controls.Icon {
                            id: forecastIcon

                            name: forecastCard.forecastHour && forecastCard.forecastHour.chanceofrain > 0 ? "weather.water" : "weather.default"
                            tone: "accent"
                            size: settings.textPixelSize
                        }

                        Text {
                            id: chanceText

                            visible: forecastCard.forecastHour && forecastCard.forecastHour.chanceofrain > 0
                            text: visible ? forecastCard.forecastHour.chanceofrain + "%" : ""
                            color: Colors.fgAccent
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                        }
                    }

                    Text {
                        width: parent.width
                        text: tabRoot.panel.weatherUnits === "F" ? forecastCard.modelData.mintempF + "°/" + forecastCard.modelData.maxtempF + "°" : forecastCard.modelData.mintempC + "°/" + forecastCard.modelData.maxtempC + "°"
                        color: Colors.fgSecondary
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                    }
                }
            }
        }
    }

    // Flexible spacer below forecast
    Item {
        Layout.fillHeight: true
    }

    // Weather data attribution
    Text {
        Layout.fillWidth: true
        text: "Weather data from wttr.in"
        color: Colors.fgSecondary
        horizontalAlignment: Text.AlignRight
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize - 1
    }
}
