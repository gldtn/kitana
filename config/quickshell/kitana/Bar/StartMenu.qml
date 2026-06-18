// Kitana managed Quickshell start menu

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."
import "../Components/Controls" as Controls
import "../custom" as Custom

PanelWindow {
    id: root

    Custom.Settings { id: settings }

    property var panelScreen: null
    property var systemPanel: null
    property var settingsPanel: null
    property var shortcutsPanel: null
    property bool panelVisible: false
    property real revealProgress: 0

    function open(): void {
        const wasVisible = panelVisible;
        panelVisible = true;
        if (!wasVisible) {
            revealProgress = 0;
            revealAnimation.restart();
        }
        closeArea.forceActiveFocus();
    }

    function close(): void {
        panelVisible = false;
        revealProgress = 0;
    }

    function toggle(): void {
        panelVisible ? close() : open();
    }

    function openLauncher(): void {
        close();
        Quickshell.execDetached(["quickshell", "ipc", "-c", "kitana", "call", "kitana-launcher", "open"]);
    }

    function openSettings(): void {
        close();
        if (settingsPanel)
            settingsPanel.open("bar");
    }

    function openShortcuts(): void {
        close();
        if (shortcutsPanel)
            shortcutsPanel.open();
    }

    // Reusable start menu action row
    component MenuAction: Rectangle {
        id: actionRoot

        property string iconName: Icons.defaultIcon
        property string title: ""
        property string subtitle: ""

        signal clicked

        Layout.fillWidth: true
        Layout.preferredHeight: 48
        radius: 12
        color: actionMouse.containsMouse ? Colors.controlHoverBackground : Colors.cardBackground
        border.color: Colors.panelBorder
        border.width: 1

        // Action icon and labels
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10

            Controls.Icon {
                name: actionRoot.iconName
                tone: "accent"
                size: settings.iconPixelSize + 1
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: actionRoot.title
                    color: Colors.foreground
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.Bold
                }

                Text {
                    Layout.fillWidth: true
                    text: actionRoot.subtitle
                    color: Colors.foregroundMuted
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 1
                }
            }
        }

        // Action click target
        MouseArea {
            id: actionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: actionRoot.clicked()
        }
    }

    screen: panelScreen
    visible: panelVisible
    focusable: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    // Full-screen close catcher
    MouseArea {
        id: closeArea
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.close()
        onClicked: root.close()
    }

    // Sliding start menu card
    Rectangle {
        width: 320
        height: menuColumn.implicitHeight + 28
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: settings.panelHeight + settings.topMargin + 10
        anchors.leftMargin: settings.sideMargin
        opacity: root.revealProgress
        radius: 18
        color: Colors.panelBackground
        border.color: Colors.panelBorder
        border.width: 1

        transform: Translate {
            x: (1 - root.revealProgress) * -14
        }

        // Prevent clicks inside card from closing panel
        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        // Start menu content stack
        ColumnLayout {
            id: menuColumn

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 10

            // Menu title header
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Controls.Icon {
                    name: "brand.arch"
                    tone: "brand"
                    sizeRole: "tile"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        Layout.fillWidth: true
                        text: "Kitana"
                        color: Colors.foreground
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize + 2
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "System menu"
                        color: Colors.foregroundMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                    }
                }
            }

            // Header divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.panelBorder
            }

            // App launcher entry
            MenuAction {
                iconName: "launcher.apps"
                title: "App launcher"
                subtitle: "Search applications and commands"
                onClicked: root.openLauncher()
            }

            // Settings panel entry
            MenuAction {
                iconName: "settings"
                title: "Settings"
                subtitle: "Open Kitana system settings"
                onClicked: root.openSettings()
            }

            // Shortcuts panel entry
            MenuAction {
                iconName: "input.keyboard"
                title: "Shortcuts"
                subtitle: "Search active Hyprland keybinds"
                onClicked: root.openShortcuts()
            }
        }
    }

    // Card reveal animation
    NumberAnimation {
        id: revealAnimation
        target: root
        property: "revealProgress"
        to: 1
        duration: 140
        easing.type: Easing.OutCubic
    }
}
