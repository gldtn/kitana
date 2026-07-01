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

    Custom.Settings { id: settings }

    property var dashboard: null
    readonly property var panel: dashboard

    spacing: 8

    // Top breathing space for picker tabs
    PickerTopInset {}

    // Search/help overlay for picker navigation
    PickerHelp { dashboard: tabRoot.panel }

    // Theme preview grid area
    Item {
        id: themeGrid

        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        readonly property int columns: 3
        readonly property int gap: 10
        readonly property int edgeInset: 5
        readonly property real cardWidth: Math.floor((width - 2 * edgeInset - (columns - 1) * gap) / columns)
        readonly property real cardHeight: Math.floor((height - 2 * edgeInset - gap) / 2)
        readonly property real trackWidth: columns * cardWidth + (columns - 1) * gap

        // Theme page item repeater
        Repeater {
            model: tabRoot.panel.themePageItems()

            // Selectable theme preview card
            Rectangle {
                id: themeCard

                required property int index
                required property var modelData
                readonly property int sourceIndex: tabRoot.panel.themePage * tabRoot.panel.themePageSize + index
                readonly property bool selected: sourceIndex === tabRoot.panel.themeCurrentIndex
                readonly property int row: Math.floor(index / themeGrid.columns)
                readonly property int column: index % themeGrid.columns
                x: Math.round((themeGrid.width - themeGrid.trackWidth) / 2 + column * (themeGrid.cardWidth + themeGrid.gap))
                y: themeGrid.edgeInset + row * (themeGrid.cardHeight + themeGrid.gap)
                width: themeGrid.cardWidth
                height: themeGrid.cardHeight
                radius: 14
                color: modelData.previewBackground
                border.color: selected || themeMouse.containsMouse ? modelData.previewAccent : modelData.previewBorder
                border.width: selected || themeMouse.containsMouse ? 2 : 1
                clip: true
                scale: selected || themeMouse.containsMouse ? 1.015 : 1

                Behavior on scale { NumberAnimation { duration: 120 } }

                // Theme preview surface
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 14
                    radius: 12
                    color: themeCard.modelData.previewSurface
                    border.color: themeCard.modelData.previewBorder
                    border.width: 1

                    // Theme accent swatches
                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.top: parent.top
                        anchors.topMargin: 14
                        spacing: 8

                        // Color swatch repeater
                        Repeater {
                            model: [themeCard.modelData.previewAccent, themeCard.modelData.previewWarning, themeCard.modelData.previewDanger, themeCard.modelData.previewMuted]

                            // Theme color swatch
                            Rectangle {
                                required property color modelData

                                width: 18
                                height: 18
                                radius: 9
                                color: modelData
                            }
                        }
                    }

                    // Theme name and slug labels
                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 14
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: themeCard.modelData.name
                            color: themeCard.modelData.previewForeground
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize + 1
                            font.weight: Font.DemiBold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: themeCard.modelData.slug
                            color: themeCard.modelData.previewMuted
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize
                        }
                    }
                }

                // Theme selection click target
                MouseArea {
                    id: themeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: tabRoot.panel.themeCurrentIndex = themeCard.sourceIndex
                    onClicked: tabRoot.panel.applyTheme(themeCard.modelData)
                }
            }
        }
    }

    // Theme pagination footer
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 30

        // Page controls
        Controls.Pagination {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            currentPage: tabRoot.panel.themePage
            pageCount: tabRoot.panel.themePageCount()
            wrap: true

            onPageRequested: page => tabRoot.panel.setThemePage(page)
        }

        // Filtered theme count label
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            width: 90
            text: tabRoot.panel.filteredThemes().length + " themes"
            color: Colors.fgSecondary
            horizontalAlignment: Text.AlignRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.DemiBold
        }
    }
}
