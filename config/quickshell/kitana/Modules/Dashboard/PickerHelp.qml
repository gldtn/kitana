// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var dashboard: null

    readonly property bool searchActive: dashboard && dashboard.pickerSearchActive
    readonly property bool helpVisible: dashboard && dashboard.pickerHelpVisible

    Layout.fillWidth: true
    Layout.preferredHeight: searchActive ? 36 : (helpVisible ? 52 : 24)

    PickerFooter {
        width: Math.min(parent.width, 590)
        anchors.horizontalCenter: parent.horizontalCenter
        dashboard: root.dashboard
    }
}
