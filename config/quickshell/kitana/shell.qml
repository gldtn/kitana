// Kitana managed Quickshell bar
//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "./custom" as Custom
import "./Modules"
import "./Services" as Services

ShellRoot {
    id: root

    property bool barVisible: true
    readonly property var sharedDashboardPanel: dashboardPanel

    Custom.Settings {
        id: settings
    }

    WallpaperGrid {}
    AppLauncher {}

    DashboardPanel {
        id: dashboardPanel
    }

    IpcHandler {
        target: "kitana-osd"

        function display(payload: string): void {
            Services.OsdService.showPayload(payload);
        }
    }

    IpcHandler {
        target: "kitana-notifications"

        function dismissLast(): void { Services.NotificationService.dismissLast(); }
        function clear(): void { Services.NotificationService.clear(); }
    }

    IpcHandler {
        target: "kitana-bar"

        function show(): void { root.barVisible = true; }
        function hide(): void { root.barVisible = false; }
        function toggle(): void { root.barVisible = !root.barVisible; }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelWindow

            required property var modelData

            screen: modelData
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

            SystemPanel {
                id: systemPanel

                panelScreen: modelData
            }

            NotificationPopups {
                panelScreen: modelData
            }

            OsdPopup {
                panelScreen: modelData
            }

            Item {
                anchors.fill: parent
                visible: root.barVisible

                WorkspaceGroup {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    panelScreen: modelData
                }

                ClockPill {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    dashboardPanel: root.sharedDashboardPanel
                }

                StatusGroup {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    panelWindow: panelWindow
                    systemPanel: systemPanel
                }
            }
        }
    }
}
