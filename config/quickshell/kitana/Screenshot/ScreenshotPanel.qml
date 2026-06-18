// Kitana managed Quickshell screenshot panel

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../Components/Controls" as Controls
import "../custom" as Custom

PanelWindow {
    id: root

    Custom.Settings { id: settings }

    property bool panelVisible: false
    property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"

    visible: panelVisible
    focusable: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    BackgroundEffect.blurRegion: Region { item: backdrop }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    function open(): void {
        panelVisible = true;
        closeArea.forceActiveFocus();
    }

    function close(): void {
        panelVisible = false;
    }

    function toggle(): void {
        panelVisible ? close() : open();
    }

    function capture(mode: string, clipboardOnly: bool): void {
        const command = [kitanaDir + "/bin/kitana-screenshot", mode];
        if (clipboardOnly)
            command.push("--clipboard-only");

        close();
        captureProcess.exec(command);
    }

    function handleKey(event: var): void {
        if (event.key === Qt.Key_Escape) {
            close();
            event.accepted = true;
        } else if (event.key === Qt.Key_S) {
            capture("output", false);
            event.accepted = true;
        } else if (event.key === Qt.Key_W) {
            capture("window", false);
            event.accepted = true;
        } else if (event.key === Qt.Key_R) {
            capture("region", false);
            event.accepted = true;
        } else if (event.key === Qt.Key_C) {
            capture("region", true);
            event.accepted = true;
        }
    }

    // Full-screen close and keyboard handler
    MouseArea {
        id: closeArea

        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.close()
        Keys.onPressed: event => root.handleKey(event)
        onClicked: root.close()
    }

    // Blurred screenshot panel backdrop
    Controls.BlurredBackdrop {
        id: backdrop

        anchors.fill: parent
    }

    // Main screenshot action card
    Rectangle {
        id: card

        width: Math.min(500, parent.width - 96)
        height: 188
        anchors.centerIn: parent
        radius: 18
        color: Colors.panelBackground
        border.color: Colors.panelBorder
        border.width: 1

        // Prevent clicks inside card from closing panel
        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        // Screenshot card content stack
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            // Screenshot panel header
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Controls.Icon {
                    name: "screenshot.default"
                    tone: "accent"
                    size: settings.iconPixelSize + 5
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        Layout.fillWidth: true
                        text: "Screenshot"
                        color: Colors.foreground
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize + 4
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Choose what to capture"
                        color: Colors.foregroundMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                    }
                }
            }

            // Screenshot mode buttons row
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                ScreenshotAction {
                    iconName: "display.monitor"
                    shortcut: "S"
                    title: "Screen"
                    subtitle: "Full monitor"
                    onClicked: root.capture("output", false)
                }

                ScreenshotAction {
                    iconName: "screenshot.window"
                    shortcut: "W"
                    title: "Window"
                    subtitle: "Focused pick"
                    onClicked: root.capture("window", false)
                }

                ScreenshotAction {
                    iconName: "screenshot.region"
                    shortcut: "R"
                    title: "Region"
                    subtitle: "Select area"
                    onClicked: root.capture("region", false)
                }

                ScreenshotAction {
                    iconName: "screenshot.clipboard"
                    shortcut: "C"
                    title: "Clipboard"
                    subtitle: "Region only"
                    onClicked: root.capture("region", true)
                }
            }
        }
    }

    // Screenshot command runner
    Process { id: captureProcess }

    // Reusable screenshot action tile
    component ScreenshotAction: Rectangle {
        id: action

        property string iconName: Icons.defaultIcon
        property string shortcut: ""
        property string title: ""
        property string subtitle: ""
        signal clicked

        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 14
        color: actionMouse.containsMouse ? Colors.controlHoverBackground : Colors.cardBackground
        border.color: actionMouse.containsMouse ? Colors.controlActiveBorder : Colors.panelBorder
        border.width: 1

        // Shortcut badge
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 8
            anchors.rightMargin: 8
            width: shortcutLabel.implicitWidth + 10
            height: 18
            radius: 6
            color: Colors.controlBackground
            border.color: Colors.panelBorder
            border.width: 1

            // Shortcut letter label
            Text {
                id: shortcutLabel
                anchors.centerIn: parent
                text: action.shortcut
                color: Colors.foregroundMuted
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 2
                font.weight: Font.Bold
            }
        }

        // Action icon and labels
        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - 16
            spacing: 6

            Controls.Icon {
                Layout.alignment: Qt.AlignHCenter
                name: action.iconName
                tone: "accent"
                size: settings.iconPixelSize + 6
            }

            Text {
                Layout.fillWidth: true
                text: action.title
                color: Colors.foreground
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.Bold
            }

            Text {
                Layout.fillWidth: true
                text: action.subtitle
                color: Colors.foregroundMuted
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 2
            }
        }

        // Screenshot action click target
        MouseArea {
            id: actionMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: action.clicked()
        }
    }
}
