// Kitana managed Quickshell bar section

import QtQuick
import "../Items" as Items

Item {
    id: root

    property var dashboardPanel: null

    implicitWidth: dateTime.implicitWidth
    implicitHeight: dateTime.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Items.DateTime {
        id: dateTime
        dashboardPanel: root.dashboardPanel
    }
}
