// Kitana managed Quickshell dashboard tab

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic as QtControls
import QtQuick.Layouts
import "../.."
import "../Components"
import "../../custom" as Custom

ColumnLayout {
    id: tabRoot

    Custom.Settings {
        id: settings
    }

    property var dashboard: null
    readonly property var panel: dashboard

    spacing: 10

    // Dashboard settings heading
    Text {
        id: settingsTitle

        Layout.fillWidth: true
        text: "Dashboard Settings"
        color: Colors.fgPrimary
        font.family: Typography.fontFamily
        font.pixelSize: 16
        font.weight: Font.Bold
    }

    readonly property real preferredContentHeight: settingsTitle.implicitHeight + spacing + settingsContent.implicitHeight

    function syncPreferredContentHeight(): void {
        if (tabRoot.panel)
            tabRoot.panel.settingsPreferredContentHeight = preferredContentHeight;
    }

    onPreferredContentHeightChanged: syncPreferredContentHeight()
    Component.onCompleted: syncPreferredContentHeight()

    // Scrollable settings cards
    Flickable {
        id: settingsFlickable

        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        contentWidth: width
        contentHeight: settingsContent.y + settingsContent.implicitHeight + tabRoot.panel.tabCardVerticalInset

        QtControls.ScrollBar.vertical: QtControls.ScrollBar {
            policy: QtControls.ScrollBar.AsNeeded
        }

        ColumnLayout {
            id: settingsContent

            x: tabRoot.panel.tabCardHorizontalInset
            y: tabRoot.panel.tabCardVerticalInset
            width: Math.max(0, settingsFlickable.width - 2 * tabRoot.panel.tabCardHorizontalInset)
            spacing: tabRoot.panel.tabCardSpacing

            // Weather location and unit settings card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 128
                radius: tabRoot.panel.sectionRadius
                color: tabRoot.panel.sectionContainer
                border.color: tabRoot.panel.sectionBorder
                border.width: tabRoot.panel.sectionBorderWidth
                border.pixelAligned: false
                antialiasing: true

                // Weather settings form
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: "Weather"
                        color: Colors.fgPrimary
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
                            secret: tabRoot.panel.weatherHideLocation
                            onEscaped: tabRoot.panel.close()
                            onCommitted: value => tabRoot.panel.setWeatherLocation(value)
                        }

                        MiniButton {
                            Layout.alignment: Qt.AlignBottom
                            iconName: tabRoot.panel.weatherHideLocation ? "weather.visibility.off" : "weather.visibility"
                            widthOverride: 46
                            heightOverride: 34
                            onClicked: tabRoot.panel.setWeatherHideLocation(!tabRoot.panel.weatherHideLocation)
                        }

                        MiniButton {
                            Layout.alignment: Qt.AlignBottom
                            text: tabRoot.panel.weatherUnits === "C" ? "°C" : "°F"
                            widthOverride: 46
                            heightOverride: 34
                            onClicked: tabRoot.panel.toggleWeatherUnits()
                        }
                    }
                }
            }

            // World clock name and timezone settings card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 184
                radius: 16
                color: Colors.bgSecondary
                border.color: Colors.borderFaint
                border.width: 0.8
                border.pixelAligned: false
                antialiasing: true

                // World clock settings form
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: "World Clocks"
                        color: Colors.fgPrimary
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
                            label: "Clock 1 Label"
                            value: tabRoot.panel.worldClockLabel(0)
                            onEscaped: tabRoot.panel.close()
                            onCommitted: value => tabRoot.panel.setWorldClockLabel(0, value)
                        }

                        DashboardField {
                            Layout.fillWidth: true
                            label: "Clock 1 Timezone"
                            value: tabRoot.panel.worldClockTimezone(0)
                            onEscaped: tabRoot.panel.close()
                            onCommitted: value => tabRoot.panel.setWorldClockTimezone(0, value)
                        }

                        DashboardField {
                            Layout.fillWidth: true
                            label: "Clock 2 Label"
                            value: tabRoot.panel.worldClockLabel(1)
                            onEscaped: tabRoot.panel.close()
                            onCommitted: value => tabRoot.panel.setWorldClockLabel(1, value)
                        }

                        DashboardField {
                            Layout.fillWidth: true
                            label: "Clock 2 Timezone"
                            value: tabRoot.panel.worldClockTimezone(1)
                            onEscaped: tabRoot.panel.close()
                            onCommitted: value => tabRoot.panel.setWorldClockTimezone(1, value)
                        }
                    }
                }
            }

            // Wallpaper folder and custom set management card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                radius: tabRoot.panel.sectionRadius
                color: tabRoot.panel.sectionContainer
                border.color: tabRoot.panel.sectionBorder
                border.width: tabRoot.panel.sectionBorderWidth
                border.pixelAligned: false
                antialiasing: true

                // Wallpaper settings form
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: "Wallpapers"
                        color: Colors.fgPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }

                    // Active wallpaper folder path field
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        DashboardField {
                            Layout.fillWidth: true
                            label: "Folder Path"
                            value: tabRoot.panel.wallpaperDir
                            onEscaped: tabRoot.panel.close()
                            onCommitted: value => tabRoot.panel.setWallpaperDir(value)
                        }

                        MiniButton {
                            Layout.alignment: Qt.AlignBottom
                            text: "Refresh"
                            widthOverride: 72
                            heightOverride: 34
                            onClicked: tabRoot.panel.loadWallpaperDir()
                        }
                    }

                    // Custom wallpaper set controls
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        DashboardField {
                            Layout.fillWidth: true
                            label: "Custom Set"
                            value: tabRoot.panel.wallpaperSetName
                            onEscaped: tabRoot.panel.close()
                            onCommitted: value => tabRoot.panel.setWallpaperSetName(value)
                        }

                        MiniButton {
                            Layout.alignment: Qt.AlignBottom
                            text: "Create"
                            widthOverride: 64
                            heightOverride: 34
                            onClicked: tabRoot.panel.createWallpaperSet()
                        }

                        MiniButton {
                            Layout.alignment: Qt.AlignBottom
                            text: "Use"
                            widthOverride: 48
                            heightOverride: 34
                            onClicked: tabRoot.panel.activateWallpaperSet()
                        }

                        MiniButton {
                            Layout.alignment: Qt.AlignBottom
                            text: "Delete"
                            widthOverride: 62
                            heightOverride: 34
                            onClicked: tabRoot.panel.deleteWallpaperSet()
                        }
                    }

                    // Import source path field and manager actions
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        DashboardField {
                            Layout.fillWidth: true
                            label: "File or Folder to Add"
                            value: tabRoot.panel.wallpaperManagerPath
                            onEscaped: tabRoot.panel.close()
                            onCommitted: value => tabRoot.panel.setWallpaperManagerPath(value)
                        }

                        MiniButton {
                            Layout.alignment: Qt.AlignBottom
                            text: "Add"
                            widthOverride: 46
                            heightOverride: 34
                            onClicked: tabRoot.panel.addWallpaperToSet()
                        }

                        MiniButton {
                            Layout.alignment: Qt.AlignBottom
                            text: "Import"
                            widthOverride: 62
                            heightOverride: 34
                            onClicked: tabRoot.panel.importWallpaperDirToSet()
                        }

                        MiniButton {
                            Layout.alignment: Qt.AlignBottom
                            text: "Remove"
                            widthOverride: 72
                            heightOverride: 34
                            onClicked: tabRoot.panel.removeCurrentWallpaperFromSet()
                        }
                    }

                    // Themed wallpaper generation shortcuts and status
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        MiniButton {
                            text: "Theme Current"
                            widthOverride: 112
                            heightOverride: 28
                            onClicked: tabRoot.panel.generateWallpaperSetTheme()
                        }

                        MiniButton {
                            text: "Theme All"
                            widthOverride: 88
                            heightOverride: 28
                            onClicked: tabRoot.panel.generateWallpaperSetAllThemes()
                        }

                        Text {
                            Layout.fillWidth: true
                            text: tabRoot.panel.wallpaperSetBusy ? "Working..." : tabRoot.panel.wallpaperManagerStatus
                            color: Colors.fgSecondary
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
