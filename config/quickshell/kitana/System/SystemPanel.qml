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
    // Mirrors Hyprland general.gaps_out.
    readonly property int outerGap: 6
    property real revealProgress: 0
    property var panelScreen: null
    property string section: "notifications"

    function open(targetSection): void {
        const wasVisible = visible;
        section = targetSection || "notifications";
        Services.SystemStatus.refresh();
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

    function toggle(targetSection): void {
        if (visible && section === targetSection)
            close();
        else
            open(targetSection);
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
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: settings.panelHeight + settings.topMargin + root.outerGap
        anchors.rightMargin: root.outerGap
        anchors.bottomMargin: root.outerGap
        opacity: root.revealProgress
        radius: 18
        color: Colors.panelBackground
        border.color: Colors.panelBorder
        border.width: 1

        transform: Translate {
            x: (1 - root.revealProgress) * 14
        }

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
                height: Math.max(0, content.height - panelHeader.height - quickGrid.height - sliders.height - content.spacing * 3)
                radius: 14
                color: Colors.containerBackground
                border.color: Colors.containerBorder
                border.width: 0.6
                clip: true

                Loader {
                    anchors.fill: parent
                    anchors.margins: 14
                    sourceComponent: root.section === "bluetooth" ? bluetoothDetails : (root.section === "network" ? networkDetails : (root.section === "audio" ? audioDetails : notificationsView))
                }
            }

            System.ControlSliders { id: sliders; height: implicitHeight }
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

    Component { id: notificationsView; Panes.NotificationsPane {} }
    Component { id: bluetoothDetails; Panes.BluetoothPane {} }
    Component { id: networkDetails; Panes.NetworkPane {} }
    Component { id: audioDetails; Panes.AudioPane {} }
}
