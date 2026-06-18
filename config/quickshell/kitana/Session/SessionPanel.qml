// Kitana managed Quickshell session panel

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
    property string confirmAction: ""
    property string confirmTitle: ""
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
        confirmAction = "";
        confirmTitle = "";
        panelVisible = true;
        closeArea.forceActiveFocus();
    }

    function close(): void {
        panelVisible = false;
        confirmAction = "";
        confirmTitle = "";
    }

    function toggle(): void {
        panelVisible ? close() : open();
    }

    function ask(action: string, title: string): void {
        confirmAction = action;
        confirmTitle = title;
        closeArea.forceActiveFocus();
    }

    function lockSession(): void {
        close();
        sessionAction.exec([kitanaDir + "/bin/kitana-lock"]);
    }

    function runConfirmedAction(): void {
        const action = confirmAction;
        close();

        if (action === "logout")
            sessionAction.exec(["hyprctl", "dispatch", "exit"]);
        else if (action === "restart")
            sessionAction.exec(["systemctl", "reboot"]);
        else if (action === "shutdown")
            sessionAction.exec(["systemctl", "poweroff"]);
    }

    function handleKey(event: var): void {
        if (event.key === Qt.Key_Escape) {
            if (confirmAction.length > 0) {
                confirmAction = "";
                confirmTitle = "";
            } else {
                close();
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (confirmAction.length > 0) {
                runConfirmedAction();
                event.accepted = true;
            }
        } else if (event.key === Qt.Key_L) {
            lockSession();
            event.accepted = true;
        } else if (event.key === Qt.Key_O) {
            ask("logout", "Log out?");
            event.accepted = true;
        } else if (event.key === Qt.Key_R) {
            ask("restart", "Restart?");
            event.accepted = true;
        } else if (event.key === Qt.Key_S) {
            ask("shutdown", "Shut down?");
            event.accepted = true;
        }
    }

    IpcHandler {
        target: "kitana-session"

        function open(): void { root.open(); }
        function close(): void { root.close(); }
        function toggle(): void { root.toggle(); }
    }

    MouseArea {
        id: closeArea

        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.close()
        Keys.onPressed: event => root.handleKey(event)
        onClicked: root.close()
    }

    Controls.BlurredBackdrop {
        id: backdrop

        anchors.fill: parent
    }

    Rectangle {
        id: card

        width: Math.min(560, parent.width - 96)
        height: 208
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
                    name: "power.power"
                    tone: "accent"
                    size: settings.iconPixelSize + 5
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        Layout.fillWidth: true
                        text: "Session"
                        color: Colors.foreground
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize + 4
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Choose a session action"
                        color: Colors.foregroundMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                SessionAction {
                    iconName: "power.lock"
                    shortcut: "L"
                    title: "Lock"
                    subtitle: "Lock session"
                    onClicked: root.lockSession()
                }

                SessionAction {
                    iconName: "power.logout"
                    shortcut: "O"
                    title: "Log out"
                    subtitle: "End session"
                    onClicked: root.ask("logout", "Log out?")
                }

                SessionAction {
                    iconName: "power.reboot"
                    shortcut: "R"
                    title: "Restart"
                    subtitle: "Reboot system"
                    onClicked: root.ask("restart", "Restart?")
                }

                SessionAction {
                    iconName: "power.shutdown"
                    shortcut: "S"
                    title: "Shut down"
                    subtitle: "Power off"
                    onClicked: root.ask("shutdown", "Shut down?")
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            visible: root.confirmAction.length > 0
            radius: parent.radius
            color: Colors.scrim

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.confirmAction = "";
                    root.confirmTitle = "";
                }
            }

            Rectangle {
                width: Math.min(320, parent.width - 48)
                height: 136
                anchors.centerIn: parent
                radius: 16
                color: Colors.panelBackground
                border.color: Colors.panelBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        Layout.fillWidth: true
                        text: root.confirmTitle
                        color: Colors.foreground
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize + 4
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Press Enter to confirm or Escape to cancel"
                        color: Colors.foregroundMuted
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ConfirmButton {
                            label: "Cancel"
                            accent: false
                            onClicked: {
                                root.confirmAction = "";
                                root.confirmTitle = "";
                            }
                        }

                        ConfirmButton {
                            label: "Confirm"
                            accent: true
                            onClicked: root.runConfirmedAction()
                        }
                    }
                }
            }
        }
    }

    Process { id: sessionAction }

    component SessionAction: Rectangle {
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

        MouseArea {
            id: actionMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: action.clicked()
        }
    }

    component ConfirmButton: Rectangle {
        id: button

        property string label: ""
        property bool accent: false
        signal clicked

        Layout.fillWidth: true
        Layout.preferredHeight: 34
        radius: 10
        color: accent ? Colors.controlActiveBackground : (buttonMouse.containsMouse ? Colors.controlHoverBackground : Colors.cardBackground)
        border.color: accent ? Colors.controlActiveBorder : Colors.panelBorder
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: button.label
            color: Colors.foreground
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.Bold
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
