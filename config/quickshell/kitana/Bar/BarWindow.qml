// Kitana managed Quickshell bar window

import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../custom" as Custom
import "../Notifications" as Notifications
import "../OSD" as OSD
import "../Services" as Services
import "../System" as System
import "./Sections" as Sections

PanelWindow {
    id: root

    Custom.Settings { id: settings }

    property var panelScreen: null
    property bool barVisible: true
    property var dashboardPanel: null
    property var screenshotPanel: null
    property var settingsPanel: null
    property var shortcutsPanel: null
    readonly property int sectionGap: settings.rowSpacing

    screen: panelScreen
    implicitHeight: root.barVisible ? settings.panelHeight : 1
    exclusiveZone: root.barVisible ? settings.exclusiveZone : 0

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: settings.topMargin
        left: settings.sideMargin
        right: settings.sideMargin
    }

    color: "transparent"

    // Caffeine idle inhibitor binding
    IdleInhibitor {
        window: root
        enabled: Services.CaffeineService.enabled
    }

    // Right-side quick system panel
    System.SystemPanel {
        id: systemPanel
        panelScreen: root.panelScreen
    }

    // Left-side start menu panel
    StartMenu {
        id: startMenu
        panelScreen: root.panelScreen
        systemPanel: systemPanel
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

    // Bar section layout and compact collision handling
    Item {
        id: barContent

        readonly property real normalCenterX: (width - centerSection.width) / 2
        readonly property bool compactMode: normalCenterX < leftSection.width + root.sectionGap
            || normalCenterX + centerSection.width + root.sectionGap > width - rightSection.width
        readonly property real compactContentWidth: leftSection.width + centerSection.width + rightSection.width + root.sectionGap * 2
        readonly property real compactPillWidth: Math.min(width, compactContentWidth + root.sectionGap * 2)
        readonly property real compactPillX: Math.max(0, (width - compactPillWidth) / 2)
        readonly property real compactContentX: compactPillX + Math.max(0, (compactPillWidth - compactContentWidth) / 2)
        readonly property real compactCenterX: compactContentX + leftSection.width + root.sectionGap
        readonly property real compactRightX: compactCenterX + centerSection.width + root.sectionGap

        anchors.fill: parent
        visible: root.barVisible

        // Single pill background used when sections collide
        Rectangle {
            id: compactPill

            visible: barContent.compactMode
            x: barContent.compactPillX
            y: (parent.height - height) / 2
            width: barContent.compactPillWidth
            height: settings.pillHeight
            radius: height / settings.radiusDivisor
            color: Colors.barBackground
            border.color: Colors.barBorder
            border.width: settings.borderWidth
        }

        // Start, workspace, and layout controls
        Sections.Left {
            id: leftSection

            x: barContent.compactMode ? barContent.compactContentX : 0
            y: (parent.height - height) / 2
            embedded: barContent.compactMode
            panelScreen: root.panelScreen
            startMenu: startMenu

            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }

        // Clock and dashboard entry point
        Sections.Center {
            id: centerSection

            x: barContent.compactMode ? barContent.compactCenterX : barContent.normalCenterX
            y: (parent.height - height) / 2
            embedded: barContent.compactMode
            dashboardPanel: root.dashboardPanel

            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }

        // Screenshot, tray, status, and power controls
        Sections.Right {
            id: rightSection

            x: barContent.compactMode ? barContent.compactRightX : parent.width - width
            y: (parent.height - height) / 2
            embedded: barContent.compactMode
            panelWindow: root
            screenshotPanel: root.screenshotPanel
            systemPanel: systemPanel

            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }
    }
}
