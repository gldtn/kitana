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

    Row {
        id: leftRow

        anchors.centerIn: parent
        spacing: 6

        Items.Start {
            embedded: root.embedded
            startMenu: root.startMenu
        }

        Items.Workspaces {
            embedded: root.embedded
            panelScreen: root.panelScreen
        }

        Items.Layout {
            embedded: root.embedded
        }
    }
}
