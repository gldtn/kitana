// Kitana managed Quickshell bar window

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../custom" as Custom
import "../Notifications" as Notifications
import "../OSD" as OSD
import "../Services" as Services
import "../System" as System
import "./Sections" as Sections

// qmllint disable uncreatable-type
PanelWindow {
    id: root
    // qmllint enable uncreatable-type

    Custom.Settings { id: settings }

    property var panelScreen: null
    property bool barVisible: true
    property var screenshotPanel: null
    property var settingsPanel: null
    property var shortcutsPanel: null
    screen: panelScreen
    implicitHeight: root.barVisible ? Services.UiPreferences.panelHeight : 1
    exclusiveZone: root.barVisible ? Services.UiPreferences.exclusiveZone : 0
    WlrLayershell.namespace: "qs-panel"

    anchors {
        top: true
        left: true
        right: true
    }

    // qmllint disable unqualified unresolved-type
    margins.top: Services.UiPreferences.topMargin
    margins.left: settings.sideMargin
    margins.right: settings.sideMargin
    // qmllint enable unqualified unresolved-type

    color: "transparent"

    // Caffeine idle inhibitor binding
    IdleInhibitor {
        window: root
        enabled: Services.CaffeineService.enabled
    }

    // Right-side control panel
    System.ControlPanel {
        id: controlPanel
        panelScreen: root.panelScreen
    }

    // Left-side start menu panel
    StartMenu {
        id: startMenu
        panelScreen: root.panelScreen
        controlPanel: controlPanel
        settingsPanel: root.settingsPanel
        shortcutsPanel: root.shortcutsPanel
    }

    // Top-right notification popups
    Notifications.NotificationPopups {
        panelScreen: root.panelScreen
    }

    // Bottom-center OSD popup
    OSD.OsdPopup {
        panelScreen: root.panelScreen
    }

    // Bar section layout
    Item {
        id: barContent

        anchors.fill: parent
        visible: root.barVisible

        // Start, workspace, and layout controls
        Sections.Left {
            id: leftSection

            x: 0
            y: (parent.height - height) / 2
            embedded: false
            panelScreen: root.panelScreen
            startMenu: startMenu
        }

        // Screenshot, tray, control, and power controls
        Sections.Right {
            id: rightSection

            x: parent.width - width
            y: (parent.height - height) / 2
            embedded: false
            panelWindow: root
            screenshotPanel: root.screenshotPanel
            controlPanel: controlPanel
        }
    }
}
