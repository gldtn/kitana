// Kitana managed Quickshell bar section

import QtQuick
import "../Items" as Items

Item {
    id: root

    property var panelScreen: null
    property var startMenu: null
    property bool embedded: false

    implicitWidth: leftRow.implicitWidth
    implicitHeight: leftRow.implicitHeight
    width: implicitWidth
    height: implicitHeight

    // Left bar controls row
    Row {
        id: leftRow

        anchors.centerIn: parent
        spacing: 6

        // Start menu button
        Items.Start {
            embedded: root.embedded
            startMenu: root.startMenu
        }

        // Workspace switcher pills
        Items.Workspaces {
            embedded: root.embedded
            panelScreen: root.panelScreen
        }

        // Workspace layout toggle
        Items.Layout {
            embedded: root.embedded
        }
    }
}
