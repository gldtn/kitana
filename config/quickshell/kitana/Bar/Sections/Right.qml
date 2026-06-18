// Kitana managed Quickshell bar section

import QtQuick
import "../Items" as Items

Item {
    id: root

    property var panelWindow: null
    property var screenshotPanel: null
    property var systemPanel: null
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

        // Tray and system status cluster
        Items.Status {
            id: status
            embedded: root.embedded
            panelWindow: root.panelWindow
            systemPanel: root.systemPanel
        }

        // Power/session button
        Items.Session {
            embedded: root.embedded
        }
    }
}
