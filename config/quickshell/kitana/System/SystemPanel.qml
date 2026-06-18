// Kitana managed Quickshell module

import QtQuick
import Quickshell
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
    property bool panelVisible: false
    property real revealProgress: 0
    property var panelScreen: null
    property string section: "notifications"

    function open(targetSection): void {
        const wasVisible = panelVisible;
        section = targetSection || "notifications";
        Services.SystemStatus.refresh();
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

    function toggle(targetSection): void {
        if (panelVisible && section === targetSection)
            close();
        else
            open(targetSection);
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

    // Sliding system panel card
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

        // Prevent clicks inside card from closing panel
        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        // System panel content stack
        Column {
            id: content

            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Panel title and section icons
            System.PanelHeader { id: panelHeader; panel: root.panelSelf }

            // Quick settings tiles
            System.QuickSettingsGrid { id: quickGrid; panel: root.panelSelf }

            // Active detail pane container
            Rectangle {
                width: parent.width
                height: Math.max(0, content.height - panelHeader.height - quickGrid.height - sliders.height - content.spacing * 3)
                radius: 14
                color: Colors.containerBackground
                border.color: Colors.containerBorder
                border.width: 0.6
                clip: true

                // Active detail pane loader
                Loader {
                    anchors.fill: parent
                    anchors.margins: 14
                    sourceComponent: root.section === "bluetooth" ? bluetoothDetails : (root.section === "network" ? networkDetails : (root.section === "audio" ? audioDetails : notificationsView))
                }
            }

            // Audio, microphone, and brightness sliders
            System.ControlSliders { id: sliders; height: implicitHeight }
        }

    }

    // System panel reveal animation
    NumberAnimation {
        id: revealAnimation
        target: root
        property: "revealProgress"
        to: 1
        duration: 140
        easing.type: Easing.OutCubic
    }

    // Notifications detail pane
    Component { id: notificationsView; Panes.NotificationsPane {} }

    // Bluetooth detail pane
    Component { id: bluetoothDetails; Panes.BluetoothPane {} }

    // Network detail pane
    Component { id: networkDetails; Panes.NetworkPane {} }

    // Audio detail pane
    Component { id: audioDetails; Panes.AudioPane {} }
}
