// Kitana managed Quickshell bar section

import QtQuick
import "../Items" as Items

Item {
    id: root

    property var panelScreen: null
    property var startMenu: null

    implicitWidth: leftRow.implicitWidth
    implicitHeight: leftRow.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Row {
        id: leftRow

        anchors.centerIn: parent
        spacing: 6

        Items.Start {
            startMenu: root.startMenu
        }

        Items.Workspaces {
            panelScreen: root.panelScreen
        }
    }
}
