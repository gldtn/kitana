// Kitana managed Quickshell theme preview

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../Components/Controls" as Controls
import "../Services" as Services
import "../System/Components" as System
import "../custom" as Custom

// qmllint disable uncreatable-type
PanelWindow {
    id: root
    // qmllint enable uncreatable-type

    Custom.Settings {
        id: settings
    }

    property bool panelVisible: false
    readonly property int availableWidth: root.screen ? root.screen.width : 1280
    readonly property int availableHeight: root.screen ? root.screen.height : 900
    readonly property var foregroundRoles: ["fgPrimary", "fgSecondary", "fgTertiary", "fgOnPrimary", "fgAccent"]
    readonly property var backgroundRoles: ["bgPrimary", "bgSecondary", "bgTertiary", "bgOnPrimary", "bgAccent"]
    readonly property var borderRoles: ["borderDark", "borderLight", "borderFaint", "borderHeavy", "borderAccent"]
    readonly property var feedbackRoles: ["info", "success", "warning", "error", "subtleAccent", "subtlePrimary", "subtleSecondary", "subtleTertiary"]
    readonly property var overlayRoles: ["scrimPrimary", "scrimSecondary", "scrimTertiary"]
    readonly property var compositionRoles: ["inputBg", "inputFg", "inputPlaceholderFg", "inputBorder", "inputBorderFocus", "inputSelection", "inputSelectedFg", "barItemBg", "barItemBorder", "barItemFg"]
    readonly property var iconRoles: ["iconPrimary", "iconSecondary", "iconMuted", "iconSubtle", "iconAccent", "iconOnAccent", "iconInverse", "iconBrand", "iconDisabled", "iconDanger"]

    function open(): void {
        panelVisible = true;
    }

    function close(): void {
        panelVisible = false;
    }

    function toggle(): void {
        panelVisible = !panelVisible;
    }

    function roleColor(role: string): color {
        switch (role) {
        case "fgPrimary": return Colors.fgPrimary;
        case "fgSecondary": return Colors.fgSecondary;
        case "fgTertiary": return Colors.fgTertiary;
        case "fgOnPrimary": return Colors.fgOnPrimary;
        case "fgAccent": return Colors.fgAccent;
        case "bgPrimary": return Colors.bgPrimary;
        case "bgSecondary": return Colors.bgSecondary;
        case "bgTertiary": return Colors.bgTertiary;
        case "bgOnPrimary": return Colors.bgOnPrimary;
        case "bgAccent": return Colors.bgAccent;
        case "borderDark": return Colors.borderDark;
        case "borderLight": return Colors.borderLight;
        case "borderFaint": return Colors.borderFaint;
        case "borderHeavy": return Colors.borderHeavy;
        case "borderAccent": return Colors.borderAccent;
        case "info": return Colors.info;
        case "success": return Colors.success;
        case "warning": return Colors.warning;
        case "error": return Colors.error;
        case "scrimPrimary": return Colors.scrimPrimary;
        case "scrimSecondary": return Colors.scrimSecondary;
        case "scrimTertiary": return Colors.scrimTertiary;
        case "subtleAccent": return Colors.subtleAccent;
        case "subtlePrimary": return Colors.subtlePrimary;
        case "subtleSecondary": return Colors.subtleSecondary;
        case "subtleTertiary": return Colors.subtleTertiary;
        case "inputBg": return Colors.inputBg;
        case "inputFg": return Colors.inputFg;
        case "inputPlaceholderFg": return Colors.inputPlaceholderFg;
        case "inputBorder": return Colors.inputBorder;
        case "inputBorderFocus": return Colors.inputBorderFocus;
        case "inputSelection": return Colors.inputSelection;
        case "inputSelectedFg": return Colors.inputSelectedFg;
        case "barItemBg": return Colors.barItemBg;
        case "barItemBorder": return Colors.barItemBorder;
        case "barItemFg": return Colors.barItemFg;
        case "iconPrimary": return Colors.iconPrimary;
        case "iconSecondary": return Colors.iconSecondary;
        case "iconMuted": return Colors.iconMuted;
        case "iconSubtle": return Colors.iconSubtle;
        case "iconAccent": return Colors.iconAccent;
        case "iconOnAccent": return Colors.iconOnAccent;
        case "iconInverse": return Colors.iconInverse;
        case "iconBrand": return Colors.iconBrand;
        case "iconDisabled": return Colors.iconDisabled;
        case "iconDanger": return Colors.iconDanger;
        }

        return "#ff00ff";
    }

    function colorText(value: var): string {
        const text = String(value);
        return text.startsWith("#ff") && text.length === 9 ? "#" + text.slice(3) : text;
    }

    // Theme preview IPC command bridge
    IpcHandler {
        target: "kitana-theme-preview"

        function open(): void { root.open(); }
        function close(): void { root.close(); }
        function toggle(): void { root.toggle(); }
    }

    component SectionTitle: Text {
        width: parent ? parent.width : 0
        color: Colors.fgPrimary
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize + 1
        font.weight: Font.Bold
    }

    component MutedText: Text {
        width: parent ? parent.width : 0
        color: Colors.fgSecondary
        wrapMode: Text.WordWrap
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize - 1
    }

    component ColorSwatch: Rectangle {
        id: swatchRoot

        property string roleName: ""
        readonly property color previewColor: root.roleColor(roleName)

        width: 126
        height: 58
        radius: 12
        color: Colors.bgSecondary
        border.color: Colors.borderFaint
        border.width: 1

        // Color chip and role label
        Row {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 40
                radius: 9
                color: swatchRoot.previewColor
                border.color: Colors.borderFaint
                border.width: 1
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 36
                spacing: 2

                Text {
                    width: parent.width
                    text: swatchRoot.roleName
                    color: Colors.fgPrimary
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 2
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width
                    text: root.colorText(swatchRoot.previewColor)
                    color: Colors.fgSecondary
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 3
                }
            }
        }
    }

    component RoleGroup: Column {
        id: groupRoot

        property string title: ""
        property var roles: []

        width: parent ? parent.width : 0
        spacing: 8

        SectionTitle {
            text: groupRoot.title
        }

        // Responsive swatch grid for one role family
        Flow {
            width: parent.width
            spacing: 8

            Repeater {
                model: groupRoot.roles

                ColorSwatch {
                    required property var modelData

                    roleName: String(modelData)
                }
            }
        }
    }

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    visible: panelVisible
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Math.max(340, Math.min(760, availableWidth - 32))
    implicitHeight: Math.max(420, Math.min(780, availableHeight - 96))

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-theme-preview"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        right: true
    }

    // qmllint disable unqualified unresolved-type
    margins.top: Services.UiPreferences.panelHeight + Services.UiPreferences.topMargin + 12
    margins.right: settings.sideMargin
    // qmllint enable unqualified unresolved-type

    // Floating theme preview card
    Rectangle {
        id: card

        width: root.implicitWidth
        height: root.implicitHeight
        radius: 20
        color: Colors.bgPrimary
        border.color: Colors.borderFaint
        border.width: 1

        // Scrollable preview content
        Flickable {
            id: scroll

            anchors.fill: parent
            anchors.margins: 16
            contentWidth: width
            contentHeight: content.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            Column {
                id: content

                width: scroll.width
                spacing: 14

                // Preview title and current theme metadata
                Row {
                    width: parent.width
                    height: Math.max(titleColumn.implicitHeight, closeButton.height)
                    spacing: 10

                    Column {
                        id: titleColumn

                        width: parent.width - closeButton.width - parent.spacing
                        spacing: 2

                        Text {
                            width: parent.width
                            text: qsTr("Theme Preview")
                            color: Colors.fgPrimary
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize + 5
                            font.weight: Font.Bold
                        }

                        Text {
                            width: parent.width
                            text: qsTr("%1 - %2 - live current.json").arg(Colors.name).arg(Colors.mode)
                            color: Colors.fgSecondary
                            elide: Text.ElideRight
                            font.family: Typography.fontFamily
                            font.pixelSize: settings.textPixelSize - 1
                        }
                    }

                    Controls.CloseButton {
                        id: closeButton

                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: root.close()
                    }
                }

                // Representative shell surfaces and controls
                Column {
                    width: parent.width
                    spacing: 10

                    SectionTitle {
                        text: qsTr("Samples")
                    }

                    Rectangle {
                        width: parent.width
                        height: 42
                        radius: 16
                        color: Colors.barItemBg
                        border.color: Colors.barItemBorder
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            Controls.Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "theme"
                                tone: "primary"
                                sizeRole: "bar"
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 116
                                text: qsTr("Bar item")
                                color: Colors.barItemFg
                                elide: Text.ElideRight
                                font.family: Typography.fontFamily
                                font.pixelSize: settings.textPixelSize
                                font.weight: Font.DemiBold
                            }

                            Controls.ShortcutBadge {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "SUPER"
                            }
                        }
                    }

                    Controls.InputField {
                        width: parent.width
                        iconName: "search"
                        text: qsTr("sample query")
                        placeholderText: qsTr("Search theme roles")
                    }

                    Row {
                        width: parent.width
                        height: 48
                        spacing: 8

                        Controls.PanelRow {
                            width: (parent.width - parent.spacing) / 2
                            title: qsTr("Panel Row")
                            subtitle: qsTr("Highlighted state")
                            iconName: "settings"
                            highlighted: true
                        }

                        Controls.PanelRow {
                            width: (parent.width - parent.spacing) / 2
                            title: qsTr("Panel Row")
                            subtitle: qsTr("Default state")
                            iconName: "dashboard"
                            highlighted: false
                        }
                    }

                    Row {
                        width: parent.width
                        height: 64
                        spacing: 10

                        System.QuickTile {
                            width: (parent.width - parent.spacing) / 2
                            iconName: "network.wifi.high"
                            title: qsTr("Active Tile")
                            subtitle: qsTr("Accent icon")
                            active: true
                        }

                        System.QuickTile {
                            width: (parent.width - parent.spacing) / 2
                            iconName: "bluetooth.on"
                            title: qsTr("Idle Tile")
                            subtitle: qsTr("Subtle icon")
                            active: false
                        }
                    }

                    System.SliderRow {
                        width: parent.width
                        iconName: "brightness"
                        value: 68
                        label: "68%"
                    }

                    Rectangle {
                        width: parent.width
                        height: 86
                        radius: 16
                        color: Colors.bgTertiary
                        border.color: Colors.borderLight
                        border.width: 1

                        // Notification-style card sample
                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 42
                                height: 42
                                radius: 21
                                color: Colors.subtleAccent

                                Controls.Icon {
                                    anchors.centerIn: parent
                                    name: "notifications.on"
                                    tone: "accent"
                                    size: 20
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 54
                                spacing: 4

                                Text {
                                    width: parent.width
                                    text: qsTr("Notification sample")
                                    color: Colors.fgPrimary
                                    elide: Text.ElideRight
                                    font.family: Typography.fontFamily
                                    font.pixelSize: settings.textPixelSize + 1
                                    font.weight: Font.Bold
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: Colors.borderHeavy
                                }

                                Text {
                                    width: parent.width
                                    text: qsTr("Foreground, border, and tertiary surface contrast.")
                                    color: Colors.fgSecondary
                                    elide: Text.ElideRight
                                    font.family: Typography.fontFamily
                                    font.pixelSize: settings.textPixelSize - 1
                                }
                            }
                        }
                    }
                }

                RoleGroup {
                    title: qsTr("Foreground")
                    roles: root.foregroundRoles
                }

                RoleGroup {
                    title: qsTr("Background")
                    roles: root.backgroundRoles
                }

                RoleGroup {
                    title: qsTr("Border")
                    roles: root.borderRoles
                }

                RoleGroup {
                    title: qsTr("Feedback And Subtle")
                    roles: root.feedbackRoles
                }

                RoleGroup {
                    title: qsTr("Overlay")
                    roles: root.overlayRoles
                }

                RoleGroup {
                    title: qsTr("QML Composition")
                    roles: root.compositionRoles
                }

                RoleGroup {
                    title: qsTr("Icon Tones")
                    roles: root.iconRoles
                }

                MutedText {
                    text: qsTr("Run kitana-theme-quickshell <theme> while this window is open; it updates when Theme/current.json changes.")
                }
            }
        }
    }
}
