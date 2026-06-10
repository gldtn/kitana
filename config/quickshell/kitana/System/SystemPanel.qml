// Kitana managed Quickshell module

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../custom" as Custom
import "../Services" as Services
import "./Components" as System
import "./Panes" as Panes

PanelWindow {
    id: root

    Custom.Settings { id: settings }

    readonly property var panelSelf: root
    property var panelScreen: null
    property string section: "notifications"
    property string confirmAction: ""
    property string confirmTitle: ""

    function open(targetSection): void {
        section = targetSection || "notifications";
        Services.SystemStatus.refresh();
        visible = true;
        closeArea.forceActiveFocus();
    }

    function close(): void {
        visible = false;
    }

    function toggle(targetSection): void {
        if (visible && section === targetSection)
            close();
        else
            open(targetSection);
    }

    function ask(action, title): void {
        confirmAction = action;
        confirmTitle = title;
    }

    function lockSession(): void {
        sessionAction.exec(["sh", "-c", "${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-lock"]);
    }

    function runConfirmedAction(): void {
        if (confirmAction === "logout")
            sessionAction.exec(["hyprctl", "dispatch", "exit"]);
        else if (confirmAction === "restart")
            sessionAction.exec(["systemctl", "reboot"]);
        else if (confirmAction === "shutdown")
            sessionAction.exec(["systemctl", "poweroff"]);

        confirmAction = "";
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
        id: card

        width: 390
        height: Math.min(parent.height - settings.panelHeight - 28, 720)
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: settings.panelHeight + settings.topMargin + 10
        anchors.rightMargin: settings.sideMargin
        radius: 18
        color: Colors.panelBackground
        border.color: Colors.panelBorder
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        Column {
            id: content

            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            System.PanelHeader { id: panelHeader; panel: panelSelf }
            System.QuickSettingsGrid { id: quickGrid; panel: panelSelf }

            Rectangle {
                width: parent.width
                height: Math.max(220, card.height - panelHeader.height - quickGrid.height - sliders.height - 86)
                radius: 14
                color: Colors.panelContainerBackground
                border.color: Colors.panelContainerBorder
                border.width: 1
                clip: true

                Loader {
                    anchors.fill: parent
                    anchors.margins: 14
                    sourceComponent: root.section === "bluetooth" ? bluetoothDetails : (root.section === "network" ? networkDetails : (root.section === "audio" ? audioDetails : (root.section === "settings" ? settingsDetails : (root.section === "sessions" ? sessionsDetails : notificationsView))))
                }
            }

            System.ControlSliders { id: sliders }
        }

        System.ConfirmOverlay { panel: panelSelf }
    }

    Process { id: sessionAction }

    Component { id: notificationsView; Panes.NotificationsPane {} }
    Component { id: bluetoothDetails; Panes.BluetoothPane {} }
    Component { id: networkDetails; Panes.NetworkPane {} }
    Component { id: audioDetails; Panes.AudioPane {} }
    Component { id: settingsDetails; Panes.SettingsPane { panel: panelSelf } }
    Component { id: sessionsDetails; Panes.SessionPane { panel: panelSelf } }
}
