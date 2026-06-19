// Kitana managed Quickshell bar section

import QtQuick
import "../Items" as Items

Item {
    id: root

    property var panelWindow: null
    property var screenshotPanel: null
    property var controlPanel: null
    property bool embedded: false

    implicitWidth: rightRow.implicitWidth
    implicitHeight: rightRow.implicitHeight
    width: implicitWidth
    height: implicitHeight

    // Right bar controls row
    Row {
        id: rightRow

        anchors.centerIn: parent
        spacing: 6

        // Screenshot launcher button
        Items.Screenshot {
            embedded: root.embedded
            screenshotPanel: root.screenshotPanel
        }

        // Tray and control cluster
        Items.ControlCluster {
            id: controlCluster
            embedded: root.embedded
            panelWindow: root.panelWindow
            controlPanel: root.controlPanel
        }

        // Power/session button
        Items.Session {
            embedded: root.embedded
        }
    }
}
