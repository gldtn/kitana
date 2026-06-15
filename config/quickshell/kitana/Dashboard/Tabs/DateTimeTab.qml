// Kitana managed Quickshell dashboard tab

import QtQuick
import QtQuick.Layouts
import "../.."
import "../Components"
import "../../custom" as Custom

RowLayout {
    Custom.Settings { id: settings }

    property var dashboard: null
    property var worldClockPrefs: null
    readonly property var root: dashboard
    readonly property var weather: root ? root.weather : ({})

    spacing: 14

    Rectangle {
        Layout.preferredWidth: 250
        Layout.fillHeight: true
        radius: 16
        color: Colors.containerBackground
        border.color: Colors.containerBorder
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: Qt.formatDate(root.currentTime, "dddd")
                color: Colors.foregroundMuted
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 1
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: Qt.formatDate(root.currentTime, "d")
                color: Colors.foreground
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: 58
                font.weight: Font.Bold
            }

            Text {
                Layout.fillWidth: true
                text: Qt.formatDate(root.currentTime, "MMMM yyyy")
                color: Colors.foregroundMuted
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 1
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.panelBorder
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                TodayFact {
                    iconName: "weather.default"
                    label: weather.current_condition ? weather.current_condition[0].weatherDesc[0].value : "Weather"
                    value: weather.current_condition ? root.tempValue(weather.current_condition[0], "temp_C", "temp_F") : "--"
                }

                TodayFact {
                    iconName: "weather.sunset"
                    label: "Sunset"
                    value: weather.weather ? weather.weather[0].astronomy[0].sunset : "--"
                }

                TodayFact {
                    iconName: "calendar"
                    label: "Week " + root.isoWeek(root.currentTime)
                    value: "Day " + root.dayOfYear(root.currentTime) + "/" + root.daysInYear(root.currentTime)
                }
            }

            Item { Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.panelBorder
            }

            Text {
                Layout.fillWidth: true
                text: "World Clock"
                color: Colors.foreground
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                WorldClockRow {
                    name: worldClockPrefs.firstName
                    clockDateText: root.firstClockDate
                    clockTimeText: root.firstClockTime
                }

                WorldClockRow {
                    name: worldClockPrefs.secondName
                    clockDateText: root.secondClockDate
                    clockTimeText: root.secondClockTime
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 16
        color: Colors.containerBackground
        border.color: Colors.containerBorder
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: Qt.formatDate(root.calendarMonth, "MMMM yyyy")
                    color: Colors.foreground
                    font.family: Typography.fontFamily
                    font.pixelSize: 15
                    font.weight: Font.Bold
                }

                MiniButton { iconName: "ui.chevron.left"; onClicked: root.shiftMonth(-1) }
                MiniButton { text: "Today"; widthOverride: 58; onClicked: root.calendarMonth = new Date(root.currentTime.getFullYear(), root.currentTime.getMonth(), 1) }
                MiniButton { iconName: "ui.chevron.right"; onClicked: root.shiftMonth(1) }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 6
                columnSpacing: 6

                Repeater {
                    model: ["S", "M", "T", "W", "T", "F", "S"]
                    Text {
                        Layout.fillWidth: true
                        text: modelData
                        color: Colors.foregroundMuted
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                    }
                }

                Repeater {
                    model: 42

                    Rectangle {
                        required property int index
                        readonly property int day: root.calendarDay(index)

                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: 10
                        color: root.isToday(day) ? Colors.controlActiveBackground : (day > 0 ? Colors.cardBackground : "transparent")
                        border.color: root.isToday(day) ? Colors.controlActiveBorder : "transparent"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: day > 0 ? day : ""
                            color: root.isToday(day) ? Colors.accent : Colors.foreground
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                            font.weight: root.isToday(day) ? Font.Bold : Font.Normal
                        }
                    }
                }
            }
        }
    }
}
