// Kitana managed Quickshell bar section

import QtQuick
import "../Items" as Items

Item {
    id: root

    property var panelWindow: null
    property var screenshotPanel: null
    property var systemPanel: null

    implicitWidth: rightRow.implicitWidth
    implicitHeight: rightRow.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Row {
        id: rightRow

        anchors.centerIn: parent
        spacing: 6

        Items.Screenshot {
            screenshotPanel: root.screenshotPanel
        }

        Items.Status {
            id: status
            panelWindow: root.panelWindow
            systemPanel: root.systemPanel
        }

        Items.Session {}
    }
}
