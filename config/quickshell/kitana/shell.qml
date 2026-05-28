// Kitana managed Quickshell bar

import QtQuick
import QtQuick.Layouts
import Quickshell
import "./custom" as Custom
import "./modules"

ShellRoot {
    Custom.Settings {
        id: settings
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
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

            RowLayout {
                anchors.fill: parent
                spacing: settings.rowSpacing

                WorkspaceGroup {
                    panelScreen: modelData
                }

                Item {
                    Layout.fillWidth: true
                }

                ClockPill {}

                Item {
                    Layout.fillWidth: true
                }

                StatusGroup {}
            }
        }
    }
}
