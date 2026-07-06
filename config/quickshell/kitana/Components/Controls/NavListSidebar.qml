// Kitana managed Quickshell control

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

// Flux-inspired vertical nav list for settings and panel sidebars.
Item {
    id: root

    Custom.Settings {
        id: settings
    }

    property string title: ""
    property string currentValue: ""
    property var model: []
    property int sidebarWidth: 218

    signal activated(string value)

    function optionField(option: var, field: string, fallback: var): var {
        if (option && typeof option === "object" && option[field] !== undefined && option[field] !== null)
            return option[field];
        return fallback;
    }

    function sectionItems(section: var): var {
        const items = optionField(section, "items", []);
        if (items && typeof items.length === "number")
            return items;
        return [];
    }

    implicitWidth: sidebarWidth
    implicitHeight: sidebarLayout.implicitHeight

    // Sidebar title and grouped navigation list.
    ColumnLayout {
        id: sidebarLayout

        anchors.fill: parent
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            spacing: 9

            Icon {
                Layout.alignment: Qt.AlignVCenter
                name: "settings"
                tone: "accent"
                size: settings.iconPixelSize + 2
            }

            Text {
                Layout.fillWidth: true
                text: root.title
                color: Colors.fgPrimary
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 4
                font.weight: Font.Black
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Colors.borderFaint
        }

        Flickable {
            id: navFlickable

            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: navColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            Column {
                id: navColumn

                width: navFlickable.width
                spacing: 12

                Repeater {
                    model: root.model

                    Column {
                        id: sectionRoot

                        required property var modelData

                        width: navColumn.width
                        spacing: 4

                        Text {
                            visible: root.optionField(sectionRoot.modelData, "heading", "").length > 0
                            width: parent.width
                            leftPadding: 8
                            rightPadding: 8
                            text: root.optionField(sectionRoot.modelData, "heading", "")
                            color: Colors.fgSecondary
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize - 2
                            font.weight: Font.Black
                            font.letterSpacing: 1.2
                        }

                        Repeater {
                            model: root.sectionItems(sectionRoot.modelData)

                            Rectangle {
                                id: itemRoot

                                required property var modelData

                                readonly property string itemValue: String(root.optionField(modelData, "value", ""))
                                readonly property string itemLabel: String(root.optionField(modelData, "label", itemValue))
                                readonly property string itemIcon: String(root.optionField(modelData, "iconName", Icons.defaultIcon))
                                readonly property bool itemEnabled: root.optionField(modelData, "enabled", true)
                                readonly property bool selected: root.currentValue === itemValue
                                readonly property bool hovered: navMouse.containsMouse && itemEnabled

                                width: parent.width
                                height: 36
                                radius: 10
                                opacity: itemEnabled ? 1 : 0.45
                                color: selected ? Colors.subtleAccent : (hovered ? Colors.bgTertiary : "transparent")
                                border.color: selected ? Colors.borderAccent : "transparent"
                                border.width: selected ? 1 : 0
                                border.pixelAligned: false
                                antialiasing: true

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 9

                                    Icon {
                                        Layout.alignment: Qt.AlignVCenter
                                        name: itemRoot.itemIcon
                                        tone: itemRoot.selected ? "accent" : (itemRoot.hovered ? "primary" : "secondary")
                                        size: settings.iconPixelSize
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: itemRoot.itemLabel
                                        color: itemRoot.selected || itemRoot.hovered ? Colors.fgPrimary : Colors.fgSecondary
                                        elide: Text.ElideRight
                                        font.family: Typography.fontFamily
                                        font.pixelSize: settings.textPixelSize
                                        font.weight: itemRoot.selected ? Font.Black : Font.DemiBold
                                    }

                                    Badge {
                                        visible: String(root.optionField(itemRoot.modelData, "badge", "")).length > 0
                                        text: String(root.optionField(itemRoot.modelData, "badge", ""))
                                        size: "xs"
                                        colorVariant: itemRoot.selected ? "accent" : "subtle"
                                    }
                                }

                                MouseArea {
                                    id: navMouse

                                    anchors.fill: parent
                                    enabled: itemRoot.itemEnabled
                                    hoverEnabled: true
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: if (root.currentValue !== itemRoot.itemValue)
                                        root.activated(itemRoot.itemValue)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
