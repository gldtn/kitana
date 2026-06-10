// Kitana managed Quickshell bar section

import QtQuick
import "../Items" as Items

Item {
    id: root

    property var panelWindow: null
    property var systemPanel: null

    implicitWidth: status.implicitWidth
    implicitHeight: status.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Items.Status {
        id: status
        panelWindow: root.panelWindow
        systemPanel: root.systemPanel
    }
}
