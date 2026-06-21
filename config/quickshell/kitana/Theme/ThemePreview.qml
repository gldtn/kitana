// Kitana managed Quickshell theme preview

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import ".."
import "../Components/Controls" as Controls
import "../System/Components" as System
import "../custom" as Custom

FloatingWindow {
    id: root

    Custom.Settings {
        id: settings
    }

    property bool panelVisible: false
    readonly property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"
    property int floatingAttempts: 0
    readonly property var foregroundRoles: ["fgPrimary", "fgSecondary", "fgTertiary", "fgOnPrimary", "fgAccent"]
    readonly property var backgroundRoles: ["bgPrimary", "bgSecondary", "bgTertiary", "bgOnPrimary", "bgAccent"]
    readonly property var borderRoles: ["borderDark", "borderLight", "borderFaint", "borderHeavy", "borderAccent"]
    readonly property var feedbackRoles: ["info", "success", "warning", "error", "subtleAccent", "subtlePrimary", "subtleSecondary", "subtleTertiary"]
    readonly property var overlayRoles: ["scrimPrimary", "scrimSecondary", "scrimTertiary"]
    readonly property var compositionRoles: ["inputBg", "inputFg", "inputPlaceholderFg", "inputBorder", "inputBorderFocus", "inputSelection", "inputSelectedFg", "barItemBg", "barItemBorder", "barItemFg"]
    readonly property var iconRoles: ["iconPrimary", "iconSecondary", "iconMuted", "iconSubtle", "iconAccent", "iconOnAccent", "iconInverse", "iconBrand", "iconDisabled", "iconDanger"]

    title: qsTr("Kitana Theme Preview")
    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    visible: panelVisible
    color: "transparent"
    implicitWidth: 701
    implicitHeight: 1360
    onClosed: panelVisible = false

    function open(): void {
        panelVisible = true;
        scheduleFloating();
    }

    function close(): void {
        panelVisible = false;
    }

    function toggle(): void {
        panelVisible ? close() : open();
    }

    function scheduleFloating(): void {
        floatingAttempts = 0;
        floatTimer.restart();
    }

    function ensureFloating(): void {
        Hyprland.refreshToplevels();
        const active = Hyprland.activeToplevel;
        if (active && active.title === root.title) {
            Hyprland.dispatch("hl.dsp.window.float({ action = \"float\" })");
            return;
        }

        if (floatingAttempts < 5) {
            floatingAttempts += 1;
            floatTimer.restart();
        }
    }

    function refreshCurrentTheme(): void {
        const theme = Colors.theme && Colors.theme.slug ? Colors.theme.slug : Colors.name.toLowerCase().replace(/\s+/g, "-");
        themeRefreshProcess.exec([kitanaDir + "/bin/kitana-theme-quickshell", theme]);
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

    Timer {
        id: floatTimer

        interval: 80
        repeat: false
        onTriggered: root.ensureFloating()
    }

    // Current theme refresh command runner
    Process {
        id: themeRefreshProcess
    }

    component SectionTitle: Text {
        width: parent ? parent.width : 0
        color: Colors.fgPrimary
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize + 1
        font.weight: Font.Bold
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

    component HeaderButton: Rectangle {
        id: buttonRoot

        property string label: ""

        signal clicked

        width: buttonLabel.implicitWidth + 22
        height: 28
        radius: 9
        color: buttonMouse.containsMouse ? Colors.bgTertiary : Colors.bgSecondary
        border.color: buttonMouse.containsMouse ? Colors.borderAccent : Colors.borderFaint
        border.width: 1

        Text {
            id: buttonLabel

            anchors.centerIn: parent
            text: buttonRoot.label
            color: Colors.fgPrimary
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize - 1
            font.weight: Font.DemiBold
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: buttonRoot.clicked()
        }
    }

    component ControlSurfaceSample: Rectangle {
        id: surfaceRoot

        property string label: ""
        property color surfaceColor: Colors.bgSecondary

        height: 118
        radius: 14
        color: surfaceColor
        border.color: Colors.borderFaint
        border.width: 1

        // Badge and dismiss states on one surface color
        Column {
            anchors.centerIn: parent
            width: parent.width - 18
            spacing: 8

            Text {
                width: parent.width
                text: surfaceRoot.label
                color: Colors.fgPrimary
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 1
                font.weight: Font.DemiBold
            }

            Controls.ShortcutBadge {
                width: implicitWidth
                height: implicitHeight
                anchors.horizontalCenter: parent.horizontalCenter
                text: "PRINT"
            }

            Row {
                width: inactiveDismiss.width + hoverDismiss.width + spacing
                height: Math.max(inactiveDismiss.height, hoverDismiss.height)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Column {
                    id: inactiveDismiss

                    width: 50
                    spacing: 4

                    Text {
                        width: parent.width
                        text: qsTr("Inactive")
                        color: Colors.fgSecondary
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 4
                    }

                    Controls.CloseButton {
                        width: implicitWidth
                        height: implicitHeight
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                Column {
                    id: hoverDismiss

                    width: 42
                    spacing: 4

                    Text {
                        width: parent.width
                        text: qsTr("Hover")
                        color: Colors.fgSecondary
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 4
                    }

                    Controls.CloseButton {
                        width: implicitWidth
                        height: implicitHeight
                        anchors.horizontalCenter: parent.horizontalCenter
                        normalColor: Colors.scrimSecondary
                        hoverColor: Colors.scrimSecondary
                        normalTone: "primary"
                        hoverTone: "primary"
                    }
                }
            }
        }
    }

    // Draggable app-style theme preview surface
    Rectangle {
        id: card

        width: root.width
        height: root.height
        radius: 18
        color: Colors.bgPrimary
        border.color: Colors.borderFaint
        border.width: 1

        Column {
            id: cardContent

            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Drag handle and current theme metadata
            Row {
                id: previewHeader

                width: parent.width
                height: Math.max(titleColumn.implicitHeight, closeButton.height)
                spacing: 10

                Item {
                    id: titleArea

                    width: parent.width - refreshButton.width - closeButton.width - parent.spacing * 2
                    height: titleColumn.implicitHeight

                    Column {
                        id: titleColumn

                        anchors.fill: parent
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

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        cursorShape: Qt.SizeAllCursor
                        onPressed: root.startSystemMove()
                    }
                }

                HeaderButton {
                    id: refreshButton

                    anchors.verticalCenter: parent.verticalCenter
                    label: themeRefreshProcess.running ? qsTr("Refreshing") : qsTr("Refresh")
                    onClicked: root.refreshCurrentTheme()
                }

                Controls.CloseButton {
                    id: closeButton

                    width: implicitWidth
                    height: implicitHeight
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: root.close()
                }
            }

            // Scrollable preview content
            Flickable {
                id: scroll

                width: parent.width
                height: Math.max(0, parent.height - previewHeader.height - parent.spacing)
                contentWidth: width
                contentHeight: content.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Column {
                    id: content

                    width: scroll.width
                    spacing: 14

                    // Representative shell surfaces and controls
                    Column {
                        width: parent.width
                        spacing: 10

                        SectionTitle {
                            text: qsTr("Samples")
                        }

                        Row {
                            width: parent.width
                            height: 42
                            spacing: 10

                            Rectangle {
                                width: (parent.width - parent.spacing) / 2
                                height: parent.height
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
                                        width: implicitWidth
                                        height: implicitHeight
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "SUPER"
                                    }
                                }
                            }

                            Controls.InputField {
                                width: (parent.width - parent.spacing) / 2
                                height: parent.height
                                fieldHeight: parent.height
                                iconName: "search"
                                text: qsTr("sample query")
                                placeholderText: qsTr("Search theme roles")
                            }
                        }

                        Row {
                            width: parent.width
                            height: 118
                            spacing: 10

                            ControlSurfaceSample {
                                width: (parent.width - parent.spacing * 2) / 3
                                height: parent.height
                                label: "bgPrimary"
                                surfaceColor: Colors.bgPrimary
                            }

                            ControlSurfaceSample {
                                width: (parent.width - parent.spacing * 2) / 3
                                height: parent.height
                                label: "bgSecondary"
                                surfaceColor: Colors.bgSecondary
                            }

                            ControlSurfaceSample {
                                width: (parent.width - parent.spacing * 2) / 3
                                height: parent.height
                                label: "bgTertiary"
                                surfaceColor: Colors.bgTertiary
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

                        // Active detail pane container
                        Rectangle {
                            width: parent.width
                            height: 128
                            radius: 14
                            color: Colors.bgSecondary
                            border.color: Colors.borderFaint
                            border.width: 0.6
                            clip: true

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 14
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
                                        id: notificationIcon

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
                                        width: parent.width - notificationIcon.width - dismissStates.width - parent.spacing * 2
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

                                    Row {
                                        id: dismissStates

                                        anchors.verticalCenter: parent.verticalCenter
                                        width: inactiveDismiss.width + activeDismiss.width + spacing
                                        height: Math.max(inactiveDismiss.height, activeDismiss.height)
                                        spacing: 8

                                        Column {
                                            id: inactiveDismiss

                                            width: 52
                                            spacing: 4

                                            Text {
                                                width: parent.width
                                                text: qsTr("Inactive")
                                                color: Colors.fgSecondary
                                                horizontalAlignment: Text.AlignHCenter
                                                font.family: Typography.fontFamily
                                                font.pixelSize: settings.textPixelSize - 4
                                            }

                                            Controls.CloseButton {
                                                width: implicitWidth
                                                height: implicitHeight
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Column {
                                            id: activeDismiss

                                            width: 44
                                            spacing: 4

                                            Text {
                                                width: parent.width
                                                text: qsTr("Hover")
                                                color: Colors.fgSecondary
                                                horizontalAlignment: Text.AlignHCenter
                                                font.family: Typography.fontFamily
                                                font.pixelSize: settings.textPixelSize - 4
                                            }

                                            Controls.CloseButton {
                                                width: implicitWidth
                                                height: implicitHeight
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                normalColor: Colors.scrimSecondary
                                                hoverColor: Colors.scrimSecondary
                                                normalTone: "primary"
                                                hoverTone: "primary"
                                            }
                                        }
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
            }
        }
    }
}
}
