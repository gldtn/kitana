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
    property string hoveredWallpaperPath: ""

    spacing: 8

    function decodedName(value: string): string {
        try {
            return decodeURIComponent(value);
        } catch (error) {
            return value;
        }
    }

    function wallpaperDisplayName(path: string): string {
        const base = String(path || "").replace(/^file:\/\//, "").split("/").pop() || "";
        const name = decodedName(base);
        const extensionIndex = name.lastIndexOf(".");
        return extensionIndex > 0 ? name.slice(0, extensionIndex) : name;
    }

    function activeWallpaperPath(): string {
        return hoveredWallpaperPath.length > 0 ? hoveredWallpaperPath : tabRoot.panel.currentWallpaperPath();
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
        readonly property int visualBalanceOffset: 0
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
            cellWidth: width / wallpaperGrid.columns
            cellHeight: height / wallpaperGrid.rows
            model: tabRoot.panel.wallpaperPageItems()

            // Wallpaper thumbnail cell
            delegate: Item {
                id: wallpaperCell

                required property string modelData
                required property int index

                readonly property int sourceIndex: tabRoot.panel.wallpaperPage * tabRoot.panel.wallpaperPageSize + index
                readonly property bool selected: tabRoot.panel.wallpaperCurrentIndex === sourceIndex

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

                    // Keyboard and mouse selection border
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border.color: wallpaperCell.selected ? Colors.fgAccent : "transparent"
                        border.width: wallpaperCell.selected ? 1 : 0
                        border.pixelAligned: false
                        antialiasing: true
                    }

                    MouseArea {
                        id: wallpaperMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            tabRoot.hoveredWallpaperPath = wallpaperCell.modelData;
                            tabRoot.panel.wallpaperCurrentIndex = wallpaperCell.sourceIndex;
                        }
                        onExited: if (tabRoot.hoveredWallpaperPath === wallpaperCell.modelData)
                            tabRoot.hoveredWallpaperPath = ""
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

        // Active wallpaper name from hover or keyboard navigation
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            width: 220
            text: tabRoot.wallpaperDisplayName(tabRoot.activeWallpaperPath())
            color: Colors.fgSecondary
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.DemiBold
        }

        // Page controls
        Controls.Pagination {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            currentPage: tabRoot.panel.wallpaperPage
            pageCount: tabRoot.panel.wallpaperPageCount()
            maxPageButtons: 3
            wrap: true

            onPageRequested: page => tabRoot.panel.setWallpaperPage(page)
        }

        // Page position label
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            width: 110
            text: "Page " + (tabRoot.panel.wallpaperPage + 1) + " of " + Math.max(1, tabRoot.panel.wallpaperPageCount())
            color: Colors.fgSecondary
            horizontalAlignment: Text.AlignRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.DemiBold
        }
    }
}
