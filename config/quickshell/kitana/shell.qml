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
    Custom.Settings {
        id: settings
    }

    WallpaperGrid {}

    IpcHandler {
        target: "kitana-notifications"

        function dismissLast(): void { Services.NotificationService.dismissLast(); }
        function clear(): void { Services.NotificationService.clear(); }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelWindow

            required property var modelData

            screen: modelData
            implicitHeight: settings.panelHeight
            exclusiveZone: settings.exclusiveZone

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

            DashboardPanel {
                id: dashboardPanel

                panelScreen: modelData
            }

            RowLayout {
                anchors.fill: parent
                spacing: settings.rowSpacing

                WorkspaceGroup {
                    panelScreen: modelData
                }

                Item {
                    Layout.fillWidth: true
                }

                ClockPill {
                    dashboardPanel: dashboardPanel
                }

                Item {
                    Layout.fillWidth: true
                }

                StatusGroup {
                    panelWindow: panelWindow
                    systemPanel: systemPanel
                }
            }
        }
    }
}
