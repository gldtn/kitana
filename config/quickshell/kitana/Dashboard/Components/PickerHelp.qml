// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var dashboard: null

    readonly property bool searchActive: dashboard && dashboard.pickerSearchActive
    Layout.fillWidth: true
    Layout.preferredHeight: searchActive ? 36 : 24

    // Centered picker footer
    PickerFooter {
        width: Math.min(parent.width, 590)
        height: parent.height
        anchors.centerIn: parent
        dashboard: root.dashboard
    }
}
