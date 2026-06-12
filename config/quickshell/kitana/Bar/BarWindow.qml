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

    IdleInhibitor {
        window: root
        enabled: Services.CaffeineService.enabled
    }

    System.SystemPanel {
        id: systemPanel
        panelScreen: root.panelScreen
    }

    StartMenu {
        id: startMenu
        panelScreen: root.panelScreen
        systemPanel: systemPanel
        settingsPanel: root.settingsPanel
        shortcutsPanel: root.shortcutsPanel
    }

    Notifications.NotificationPopups {
        panelScreen: root.panelScreen
    }

    OSD.OsdPopup {
        panelScreen: root.panelScreen
    }

    Item {
        anchors.fill: parent
        visible: root.barVisible

        Sections.Left {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            panelScreen: root.panelScreen
            startMenu: startMenu
        }

        Sections.Center {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            dashboardPanel: root.dashboardPanel
        }

        Sections.Right {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            panelWindow: root
            screenshotPanel: root.screenshotPanel
            systemPanel: systemPanel
        }
    }
}
