// Kitana managed Quickshell dashboard tab

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../.."
import "../Components"
import "../../custom" as Custom

ColumnLayout {
    id: tabRoot

    Custom.Settings { id: settings }

    property var dashboard: null
    readonly property var panel: dashboard

    spacing: 8

    PickerTopInset {}
    PickerHelp { dashboard: tabRoot.panel }

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

        Repeater {
            model: tabRoot.panel.themePageItems()

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

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 14
                    radius: 12
                    color: themeCard.modelData.previewSurface
                    border.color: themeCard.modelData.previewBorder
                    border.width: 1

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.top: parent.top
                        anchors.topMargin: 14
                        spacing: 8

                        Repeater {
                            model: [themeCard.modelData.previewAccent, themeCard.modelData.previewWarning, themeCard.modelData.previewDanger, themeCard.modelData.previewMuted]

                            Rectangle {
                                required property color modelData

                                width: 18
                                height: 18
                                radius: 9
                                color: modelData
                            }
                        }
                    }

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

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 30

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            MiniButton { iconName: "ui.chevron.left"; onClicked: tabRoot.panel.shiftThemePage(-1) }

            Text {
                height: 28
                text: (tabRoot.panel.themePage + 1) + " / " + tabRoot.panel.themePageCount()
                verticalAlignment: Text.AlignVCenter
                color: Colors.foregroundMuted
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }

            MiniButton { iconName: "ui.chevron.right"; onClicked: tabRoot.panel.shiftThemePage(1) }
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            width: 90
            text: tabRoot.panel.filteredThemes().length + " themes"
            color: Colors.foregroundMuted
            horizontalAlignment: Text.AlignRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.DemiBold
        }
    }
}
