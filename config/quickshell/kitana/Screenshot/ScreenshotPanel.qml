// Kitana managed Quickshell screenshot panel

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

    property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"

    visible: false
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
        visible = true;
        closeArea.forceActiveFocus();
    }

    function close(): void {
        visible = false;
    }

    function toggle(): void {
        visible ? close() : open();
    }

    function capture(mode: string, clipboardOnly: bool): void {
        const command = [kitanaDir + "/bin/kitana-screenshot", mode];
        if (clipboardOnly)
            command.push("--clipboard-only");

        close();
        captureProcess.exec(command);
    }

    MouseArea {
        id: closeArea

        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.close()
        onClicked: root.close()
    }

    Controls.BlurredBackdrop {
        id: backdrop

        anchors.fill: parent
    }

    Rectangle {
        id: card

        width: Math.min(500, parent.width - 96)
        height: 188
        anchors.centerIn: parent
        radius: 18
        color: Colors.panelBackground
        border.color: Colors.panelBorder
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Controls.Icon {
                    icon: Icons.screenshot
                    color: Colors.accentForeground
                    size: settings.iconPixelSize + 5
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        Layout.fillWidth: true
                        text: "Screenshot"
                        color: Colors.primaryForeground
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize + 4
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Choose what to capture"
                        color: Colors.mutedForeground
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                ScreenshotAction {
                    icon: Icons.monitor
                    title: "Screen"
                    subtitle: "Full monitor"
                    onClicked: root.capture("output", false)
                }

                ScreenshotAction {
                    icon: Icons.screenshotWindow
                    title: "Window"
                    subtitle: "Focused pick"
                    onClicked: root.capture("window", false)
                }

                ScreenshotAction {
                    icon: Icons.screenshotRegion
                    title: "Region"
                    subtitle: "Select area"
                    onClicked: root.capture("region", false)
                }

                ScreenshotAction {
                    icon: Icons.screenshotClipboard
                    title: "Clipboard"
                    subtitle: "Region only"
                    onClicked: root.capture("region", true)
                }
            }
        }
    }

    Process { id: captureProcess }

    component ScreenshotAction: Rectangle {
        id: action

        property string icon: ""
        property string title: ""
        property string subtitle: ""
        signal clicked

        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 14
        color: actionMouse.containsMouse ? Colors.panelButtonBackgroundHover : Colors.panelCardBackground
        border.color: actionMouse.containsMouse ? Colors.panelButtonBorderActive : Colors.panelBorder
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - 16
            spacing: 6

            Controls.Icon {
                Layout.alignment: Qt.AlignHCenter
                icon: action.icon
                color: Colors.accentForeground
                size: settings.iconPixelSize + 6
            }

            Text {
                Layout.fillWidth: true
                text: action.title
                color: Colors.primaryForeground
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.Bold
            }

            Text {
                Layout.fillWidth: true
                text: action.subtitle
                color: Colors.mutedForeground
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 2
            }
        }

        MouseArea {
            id: actionMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: action.clicked()
        }
    }
}
