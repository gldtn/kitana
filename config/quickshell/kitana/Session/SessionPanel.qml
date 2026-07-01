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

// qmllint disable uncreatable-type
PanelWindow {
    id: root
    // qmllint enable uncreatable-type

    Custom.Settings {
        id: settings
    }

    property bool panelVisible: false
    property string confirmAction: ""
    property string confirmSelection: "confirm"
    property string confirmTitle: ""
    property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"

    visible: panelVisible
    focusable: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-blurred-panel"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    function open(): void {
        confirmAction = "";
        confirmSelection = "confirm";
        confirmTitle = "";
        panelVisible = true;
        closeArea.forceActiveFocus();
    }

    function close(): void {
        panelVisible = false;
        confirmAction = "";
        confirmSelection = "confirm";
        confirmTitle = "";
    }

    function toggle(): void {
        panelVisible ? close() : open();
    }

    function ask(action: string, title: string): void {
        confirmAction = action;
        confirmSelection = "confirm";
        confirmTitle = title;
        closeArea.forceActiveFocus();
    }

    function cancelConfirmation(): void {
        confirmAction = "";
        confirmSelection = "confirm";
        confirmTitle = "";
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
        if (confirmAction.length > 0) {
            handleConfirmKey(event);
            return;
        }

        if (event.key === Qt.Key_Escape) {
            close();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            event.accepted = true;
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

    function handleConfirmKey(event: var): void {
        if (event.key === Qt.Key_Escape) {
            cancelConfirmation();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H || event.key === Qt.Key_Backtab) {
            confirmSelection = "cancel";
            event.accepted = true;
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L || event.key === Qt.Key_Tab) {
            confirmSelection = "confirm";
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            if (confirmSelection === "cancel")
                cancelConfirmation();
            else
                runConfirmedAction();
            event.accepted = true;
        }
    }

    // Session panel IPC command bridge
    IpcHandler {
        target: "kitana-session"

        function open(): void {
            root.open();
        }
        function close(): void {
            root.close();
        }
        function toggle(): void {
            root.toggle();
        }
    }

    // Full-screen close and keyboard handler
    MouseArea {
        id: closeArea

        anchors.fill: parent
        focus: true
        Keys.onPressed: event => root.handleKey(event)
        onClicked: root.close()
    }

    // Blurred session panel backdrop
    Controls.BlurredBackdrop {
        id: backdrop

        anchors.fill: parent
    }

    // Main session action card
    Rectangle {
        id: card

        width: Math.min(560, parent.width - 96)
        height: 208
        anchors.centerIn: parent
        radius: 18
        color: Colors.bgPrimary
        border.color: Colors.borderFaint
        border.width: 1

        // Prevent clicks inside card from closing panel
        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        // Session card content stack
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            // Session panel header
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
                        color: Colors.fgPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize + 4
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Choose a session action"
                        color: Colors.fgSecondary
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                    }
                }

                Controls.CloseButton {
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: root.close()
                }
            }

            // Session action buttons row
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Controls.ActionTile {
                    iconName: "power.lock"
                    shortcut: "L"
                    title: "Lock"
                    subtitle: "Lock session"
                    onClicked: root.lockSession()
                }

                Controls.ActionTile {
                    iconName: "power.logout"
                    shortcut: "O"
                    title: "Log out"
                    subtitle: "End session"
                    onClicked: root.ask("logout", "Log out?")
                }

                Controls.ActionTile {
                    iconName: "power.reboot"
                    shortcut: "R"
                    title: "Restart"
                    subtitle: "Reboot system"
                    onClicked: root.ask("restart", "Restart?")
                }

                Controls.ActionTile {
                    iconName: "power.shutdown"
                    shortcut: "S"
                    title: "Shut down"
                    subtitle: "Power off"
                    onClicked: root.ask("shutdown", "Shut down?")
                }
            }
        }

        // Destructive action confirmation backdrop
        Rectangle {
            anchors.fill: parent
            visible: root.confirmAction.length > 0
            radius: parent.radius
            color: Colors.alpha(Colors.bgPrimary, 0.7)

            // Confirmation cancel click target
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.cancelConfirmation();
                }
            }

            // Confirmation dialog card
            Rectangle {
                width: Math.min(320, parent.width - 48)
                height: 136
                anchors.centerIn: parent
                radius: 16
                color: Colors.bgPrimary
                border.color: Colors.borderFaint
                border.width: 0.6

                // Confirmation text and actions
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        Layout.fillWidth: true
                        text: root.confirmTitle
                        color: Colors.fgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize + 4
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Use arrows or H/L to choose, Enter to select"
                        color: Colors.fgSecondary
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                    }

                    // Confirmation action buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ConfirmButton {
                            label: "Cancel"
                            targetSelection: "cancel"
                            active: root.confirmSelection === "cancel"
                            onClicked: {
                                root.cancelConfirmation();
                            }
                        }

                        ConfirmButton {
                            label: "Confirm"
                            targetSelection: "confirm"
                            active: root.confirmSelection === "confirm"
                            onClicked: root.runConfirmedAction()
                        }
                    }
                }
            }
        }
    }

    // Session command runner
    Process {
        id: sessionAction
    }

    // Reusable confirmation button
    component ConfirmButton: Rectangle {
        id: button

        property string label: ""
        property string targetSelection: ""
        property bool active: false
        signal clicked

        Layout.fillWidth: true
        Layout.preferredHeight: 34
        radius: 10
        color: button.active || buttonMouse.containsMouse ? Colors.subtleAccent : Colors.bgTertiary
        border.color: button.active ? Colors.mixColor(Colors.bgPrimary, Colors.subtleAccent, .2) : "transparent"
        border.width: 0.6

        // Confirmation button label
        Text {
            anchors.centerIn: parent
            text: button.label
            color: button.active || buttonMouse.containsMouse ? Colors.fgPrimary : Colors.fgTertiary
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.Bold
        }

        // Confirmation button click target
        MouseArea {
            id: buttonMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.confirmSelection = button.targetSelection
            onClicked: button.clicked()
        }
    }
}
