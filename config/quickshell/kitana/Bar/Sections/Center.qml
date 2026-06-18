// Kitana managed Quickshell bar section

import QtQuick
import "../Items" as Items

Item {
    id: root

    property var dashboardPanel: null
    property bool embedded: false

    implicitWidth: dateTime.implicitWidth
    implicitHeight: dateTime.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Items.DateTime {
        id: dateTime
        embedded: root.embedded
        dashboardPanel: root.dashboardPanel
    }
}
