// Kitana managed Quickshell dashboard component

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Item {
    id: root

    Custom.Settings {
        id: settings
    }

    property var dashboard: null
    property bool open: false
    property real scrimRadius: 0

    readonly property bool themePicker: dashboard !== null && dashboard.activeTab === "themes"
    readonly property var shortcutRows: [
        {
            key: "Arrows / HJKL",
            description: themePicker ? qsTr("Move through theme cards") : qsTr("Move within the current wallpaper page")
        },
        {
            key: "PageUp / [ / P",
            description: qsTr("Previous page")
        },
        {
            key: "PageDown / ] / N",
            description: qsTr("Next page")
        },
        {
            key: "/",
            description: themePicker ? qsTr("Search themes") : qsTr("Search wallpapers")
        },
        {
            key: "Enter / Space",
            description: themePicker ? qsTr("Apply selected theme") : qsTr("Apply selected wallpaper")
        },
        {
            key: "Esc",
            description: qsTr("Close search, help, or dashboard")
        },
        {
            key: "?",
            description: qsTr("Toggle this help")
        },
        {
            key: "1-5 / .",
            description: qsTr("Switch dashboard tabs")
        }
    ]

    signal dismissed

    Controls.PopupBackdrop {
        anchors.fill: parent
        open: root.open
        scrimRadius: root.scrimRadius
        onDismissed: root.dismissed()

        // Keyboard help dialog card
        Rectangle {
            id: helpCard

            width: Math.min(480, parent.width - 72)
            height: Math.min(parent.height - 64, helpContent.implicitHeight + 32)
            anchors.centerIn: parent
            radius: 16
            color: Colors.bgPrimary
            border.color: Colors.borderFaint
            border.width: 0.6
            border.pixelAligned: false
            antialiasing: true

            MouseArea {
                anchors.fill: parent
                onPressed: mouse => mouse.accepted = true
            }

            // Help title, shortcut rows, and dismiss affordance
            ColumnLayout {
                id: helpContent

                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Controls.Icon {
                        name: "input.keyboard"
                        tone: "accent"
                        size: settings.iconPixelSize + 2
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Picker Shortcuts")
                            color: Colors.fgPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize + 4
                            font.weight: Font.Bold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.themePicker ? qsTr("Theme picker navigation and actions") : qsTr("Wallpaper picker navigation and actions")
                            color: Colors.fgSecondary
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize - 1
                        }
                    }

                    Controls.CloseButton {
                        Layout.alignment: Qt.AlignTop
                        onClicked: root.dismissed()
                    }
                }

                // Shortcut list rows
                Column {
                    id: shortcutList

                    Layout.fillWidth: true
                    spacing: 3

                    Repeater {
                        model: root.shortcutRows

                        Rectangle {
                            id: shortcutRow

                            required property int index
                            required property var modelData

                            width: shortcutList.width
                            height: 34
                            radius: 9
                            color: index % 2 === 0 ? Colors.alpha(Colors.bgTertiary, 0.28) : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10

                                Controls.ShortcutBadge {
                                    Layout.preferredWidth: 118
                                    text: shortcutRow.modelData.key
                                    size: "xs"
                                    colorVariant: "secondary"
                                    hasBorder: true
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: shortcutRow.modelData.description
                                    color: Colors.fgSecondary
                                    elide: Text.ElideRight
                                    font.family: Typography.fontFamily
                                    font.pixelSize: settings.textPixelSize
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
