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

    Custom.Settings {
        id: settings
    }

    property var dashboard: null
    readonly property var panel: dashboard

    spacing: 8

    function currentPageIndex(): int {
        const pageIndex = tabRoot.panel.wallpaperCurrentIndex - tabRoot.panel.wallpaperPage * tabRoot.panel.wallpaperPageSize;
        const pageCount = tabRoot.panel.wallpaperPageItems().length;
        return pageIndex >= 0 && pageIndex < pageCount ? pageIndex : -1;
    }

    function preloadPaths(): var {
        const seen = ({});
        const paths = [];

        function append(items): void {
            for (const item of items || []) {
                if (!item || seen[item])
                    continue;

                seen[item] = true;
                paths.push(item);
            }
        }

        append(tabRoot.panel.wallpaperPageItems());
        append(tabRoot.panel.filteredWallpapers());
        return paths;
    }

    // Top breathing space for picker tabs
    PickerTopInset {}

    // Search/help overlay for picker navigation
    PickerHelp {
        dashboard: tabRoot.panel
    }

    // Wallpaper thumbnail grid area
    Item {
        id: wallpaperGrid

        Layout.fillWidth: true
        Layout.fillHeight: true

        readonly property int columns: 4
        readonly property int rows: 4
        readonly property int cardMargin: Math.max(1, Math.round(tabRoot.panel.tabCardSpacing / 2))
        readonly property int cardRadius: 14
        readonly property int visualBalanceOffset: -8
        readonly property real idealGridHeight: Math.round(width / columns * rows * 9 / 16)

        WallpaperThumbnailPreloader {
            paths: tabRoot.preloadPaths()
            cacheSize: 256
        }

        // Paged wallpaper grid with native current-index highlight handling.
        GridView {
            id: wallpaperView

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: wallpaperGrid.visualBalanceOffset
            width: parent.width
            height: Math.min(parent.height, wallpaperGrid.idealGridHeight)
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: false
            keyNavigationEnabled: false
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 120
            currentIndex: tabRoot.currentPageIndex()
            cellWidth: width / wallpaperGrid.columns
            cellHeight: height / wallpaperGrid.rows
            model: tabRoot.panel.wallpaperPageItems()

            onCurrentIndexChanged: if (currentIndex >= 0)
                positionViewAtIndex(currentIndex, GridView.Contain)

            highlight: Item {
                z: 1000

                // Keyboard and mouse selection border
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: wallpaperGrid.cardMargin
                    radius: wallpaperGrid.cardRadius
                    color: "transparent"
                    border.color: Colors.fgAccent
                    border.width: 1
                    antialiasing: true
                }
            }

            // Wallpaper thumbnail cell
            delegate: Item {
                id: wallpaperCell

                required property string modelData
                required property int index

                readonly property int sourceIndex: tabRoot.panel.wallpaperPage * tabRoot.panel.wallpaperPageSize + index
                readonly property bool selected: wallpaperView.currentIndex === index

                width: wallpaperView.cellWidth
                height: wallpaperView.cellHeight

                // Rounded wallpaper card surface
                Rectangle {
                    id: wallpaperCard

                    anchors.fill: parent
                    anchors.margins: wallpaperGrid.cardMargin
                    radius: wallpaperGrid.cardRadius
                    color: Colors.bgPrimary
                    antialiasing: true

                    Rectangle {
                        id: maskRect

                        width: thumbnailImage.width
                        height: thumbnailImage.height
                        radius: wallpaperCard.radius
                        visible: false
                        layer.enabled: true
                    }

                    CachedWallpaperImage {
                        id: thumbnailImage

                        anchors.fill: parent
                        sourcePath: wallpaperCell.modelData
                        cacheSize: 256

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskThresholdMin: 0.5
                            maskSpreadAtMin: 1.0
                            maskSource: maskRect
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: wallpaperMouse.containsMouse ? Colors.alpha(Colors.scrimTertiary, 0.28) : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }
                    }

                    MouseArea {
                        id: wallpaperMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: tabRoot.panel.wallpaperCurrentIndex = wallpaperCell.sourceIndex
                        onClicked: {
                            tabRoot.panel.wallpaperCurrentIndex = wallpaperCell.sourceIndex;
                            tabRoot.panel.applyWallpaper(wallpaperCell.modelData);
                        }
                    }
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
