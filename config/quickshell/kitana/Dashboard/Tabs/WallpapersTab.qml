// Kitana managed Quickshell dashboard tab

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
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

    // Wallpaper thumbnail grid area
    Item {
        id: wallpaperGrid

        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        readonly property int columns: 4
        readonly property int gap: 10
        readonly property int edgeInset: 5
        readonly property real cardWidth: Math.floor((width - 2 * edgeInset - (columns - 1) * gap) / columns)
        readonly property real cardHeight: Math.floor((height - 2 * edgeInset - 2 * gap) / 3)
        readonly property real trackWidth: columns * cardWidth + (columns - 1) * gap

        // Wallpaper page item repeater
        Repeater {
            model: tabRoot.panel.wallpaperPageItems()

            // Selectable wallpaper thumbnail card
            Rectangle {
                id: wallpaperCard

                required property string modelData
                required property int index
                readonly property int sourceIndex: tabRoot.panel.wallpaperPage * tabRoot.panel.wallpaperPageSize + index
                readonly property bool selected: sourceIndex === tabRoot.panel.wallpaperCurrentIndex
                readonly property int row: Math.floor(index / wallpaperGrid.columns)
                readonly property int column: index % wallpaperGrid.columns
                x: Math.round((wallpaperGrid.width - wallpaperGrid.trackWidth) / 2 + column * (wallpaperGrid.cardWidth + wallpaperGrid.gap))
                y: wallpaperGrid.edgeInset + row * (wallpaperGrid.cardHeight + wallpaperGrid.gap)
                width: wallpaperGrid.cardWidth
                height: wallpaperGrid.cardHeight
                radius: 12
                color: Colors.bgTertiary
                clip: true
                scale: selected || wallpaperMouse.containsMouse ? 1.015 : 1

                Behavior on scale { NumberAnimation { duration: 120 } }

                // Raw wallpaper thumbnail image
                Image {
                    id: wallpaperImage
                    anchors.fill: parent
                    source: tabRoot.panel.fileUrl(wallpaperCard.modelData)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize.width: Math.max(1, wallpaperCard.width)
                    sourceSize.height: Math.max(1, wallpaperCard.height)
                    visible: false
                }

                // Rounded thumbnail mask
                Rectangle {
                    id: wallpaperMask
                    anchors.fill: parent
                    radius: parent.radius
                    visible: false
                    layer.enabled: true
                }

                // Masked thumbnail effect
                MultiEffect {
                    anchors.fill: wallpaperImage
                    source: wallpaperImage
                    maskEnabled: true
                    maskSource: wallpaperMask
                }

                // Selection and hover border
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.color: wallpaperCard.selected || wallpaperMouse.containsMouse ? Colors.fgAccent : Colors.borderFaint
                    border.width: wallpaperCard.selected || wallpaperMouse.containsMouse ? 2 : 1
                }

                // Wallpaper selection click target
                MouseArea {
                    id: wallpaperMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: tabRoot.panel.wallpaperCurrentIndex = wallpaperCard.sourceIndex
                    onClicked: tabRoot.panel.applyWallpaper(wallpaperCard.modelData)
                }
            }
        }
    }

    // Wallpaper pagination footer
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 30

        // Page controls
        Controls.Pagination {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            currentPage: tabRoot.panel.wallpaperPage
            pageCount: tabRoot.panel.wallpaperPageCount()
            wrap: true

            onPageRequested: page => tabRoot.panel.setWallpaperPage(page)
        }

        // Filtered wallpaper count label
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            width: 110
            text: tabRoot.panel.filteredWallpapers().length + " wallpapers"
            color: Colors.fgSecondary
            horizontalAlignment: Text.AlignRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.DemiBold
        }
    }
}
