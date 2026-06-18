// Kitana managed Quickshell dashboard tab

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../.."
import "../Components"
import "../../custom" as Custom

RowLayout {
    id: tabRoot

    Custom.Settings {
        id: settings
    }

    property var dashboard: null
    property var worldClockPrefs: null
    readonly property var panel: dashboard
    readonly property var weather: panel ? panel.weather : ({})

    spacing: 14
    // Sidebar
    Rectangle {
        Layout.preferredWidth: 250
        Layout.fillHeight: true
        radius: 16
        color: Colors.containerBackground
        border.color: Colors.containerBorder
        border.width: 0.8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: Qt.formatDate(tabRoot.panel.currentTime, "dddd")
                color: Colors.foregroundMuted
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 1
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: Qt.formatDate(tabRoot.panel.currentTime, "d")
                color: Colors.containerForeground
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: 58
                font.weight: Font.Bold
            }

            Text {
                Layout.fillWidth: true
                text: Qt.formatDate(tabRoot.panel.currentTime, "MMMM yyyy")
                color: Colors.foregroundMuted
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 1
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.containerBorder
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                TodayFact {
                    iconName: "weather.default"
                    label: tabRoot.weather.current_condition ? tabRoot.weather.current_condition[0].weatherDesc[0].value : "Weather"
                    value: tabRoot.weather.current_condition ? tabRoot.panel.tempValue(tabRoot.weather.current_condition[0], "temp_C", "temp_F") : "--"
                }

                TodayFact {
                    iconName: "weather.sunset"
                    label: "Sunset"
                    value: tabRoot.weather.weather ? tabRoot.weather.weather[0].astronomy[0].sunset : "--"
                }

                TodayFact {
                    iconName: "calendar"
                    label: "Week " + tabRoot.panel.isoWeek(tabRoot.panel.currentTime)
                    value: "Day " + tabRoot.panel.dayOfYear(tabRoot.panel.currentTime) + "/" + tabRoot.panel.daysInYear(tabRoot.panel.currentTime)
                }
            }

            Item {
                Layout.fillHeight: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.containerBorder
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
                    name: tabRoot.worldClockPrefs.firstName
                    clockDateText: tabRoot.panel.firstClockDate
                    clockTimeText: tabRoot.panel.firstClockTime
                }

                WorldClockRow {
                    name: tabRoot.worldClockPrefs.secondName
                    clockDateText: tabRoot.panel.secondClockDate
                    clockTimeText: tabRoot.panel.secondClockTime
                }
            }
        }
    }
    // Calendar
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 16
        color: Colors.containerBackground
        border.color: Colors.containerBorder
        border.width: 0.8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: Qt.formatDate(tabRoot.panel.calendarMonth, "MMMM yyyy")
                    color: Colors.foreground
                    font.family: Typography.fontFamily
                    font.pixelSize: 15
                    font.weight: Font.Bold
                }

                MiniButton {
                    iconName: "ui.chevron.left"
                    onClicked: tabRoot.panel.shiftMonth(-1)
                }
                MiniButton {
                    text: "Today"
                    widthOverride: 58
                    onClicked: tabRoot.panel.calendarMonth = new Date(tabRoot.panel.currentTime.getFullYear(), tabRoot.panel.currentTime.getMonth(), 1)
                }
                MiniButton {
                    iconName: "ui.chevron.right"
                    onClicked: tabRoot.panel.shiftMonth(1)
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 6
                columnSpacing: 6

                Repeater {
                    model: ["S", "M", "T", "W", "T", "F", "S"]
                    Text {
                        required property string modelData

                        Layout.fillWidth: true
                        text: modelData
                        color: Colors.accent
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                    }
                }

                Repeater {
                    model: 42

                    Rectangle {
                        id: dayCell

                        required property int index
                        readonly property int day: tabRoot.panel.calendarDay(index)

                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: 10
                        color: tabRoot.panel.isToday(dayCell.day) ? Colors.controlActiveBackground : (dayCell.day > 0 ? Colors.controlBackground : "transparent")
                        border.color: tabRoot.panel.isToday(dayCell.day) ? Colors.controlActiveBorder : "transparent"
                        border.width: .5

                        Text {
                            anchors.centerIn: parent
                            text: dayCell.day > 0 ? dayCell.day : ""
                            color: tabRoot.panel.isToday(dayCell.day) ? Colors.accent : Colors.controlForeground
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                            font.weight: tabRoot.panel.isToday(dayCell.day) ? Font.Bold : Font.Normal
                        }
                    }
                }
            }
        }
    }
}
