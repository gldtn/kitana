// Kitana managed Quickshell start menu

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
    property var shortcutsPanel: null
    property real revealProgress: 0

    function open(): void {
        const wasVisible = visible;
        visible = true;
        if (!wasVisible) {
            revealProgress = 0;
            revealAnimation.restart();
        }
        closeArea.forceActiveFocus();
    }

    function close(): void {
        visible = false;
        revealProgress = 0;
    }

    function toggle(): void {
        visible ? close() : open();
    }

    function openLauncher(): void {
        close();
        Quickshell.execDetached(["quickshell", "ipc", "-c", "kitana", "call", "kitana-launcher", "open"]);
    }

    function openSettings(): void {
        close();
        if (systemPanel)
            systemPanel.open("settings");
    }

    function openShortcuts(): void {
        close();
        if (shortcutsPanel)
            shortcutsPanel.open();
    }

    component MenuAction: Rectangle {
        id: actionRoot

        property string icon: ""
        property string title: ""
        property string subtitle: ""

        signal clicked

        Layout.fillWidth: true
        Layout.preferredHeight: 48
        radius: 12
        color: actionMouse.containsMouse ? Colors.surfaceHover : Colors.surface
        border.color: Colors.panelBorder
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10

            Controls.Icon {
                icon: actionRoot.icon
                color: Colors.accent
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
                    color: Colors.muted
                    elide: Text.ElideRight
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize - 1
                }
            }
        }

        MouseArea {
            id: actionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: actionRoot.clicked()
        }
    }

    screen: panelScreen
    visible: false
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

    MouseArea {
        id: closeArea
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.close()
        onClicked: root.close()
    }

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

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        ColumnLayout {
            id: menuColumn

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: Icons.arch
                    color: Colors.accent
                    font.family: Typography.iconFontFamily
                    font.pixelSize: 18
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
                        color: Colors.muted
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.panelBorder
            }

            MenuAction {
                icon: Icons.appSearch
                title: "App launcher"
                subtitle: "Search applications and commands"
                onClicked: root.openLauncher()
            }

            MenuAction {
                icon: Icons.settings
                title: "Settings"
                subtitle: "Open Kitana system settings"
                onClicked: root.openSettings()
            }

            MenuAction {
                icon: Icons.keyboard
                title: "Shortcuts"
                subtitle: "Search active Hyprland keybinds"
                onClicked: root.openShortcuts()
            }
        }
    }

    NumberAnimation {
        id: revealAnimation
        target: root
        property: "revealProgress"
        to: 1
        duration: 140
        easing.type: Easing.OutCubic
    }
}
