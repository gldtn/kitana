// Kitana managed Quickshell temporary bar item

import QtQuick
import "../.."
import "../../Components/Controls" as Controls
import "../../Services" as Services
import "../../custom" as Custom

Item {
    id: root

    Custom.Settings {
        id: settings
    }

    property var themePreview: null
    property bool embedded: false

    implicitHeight: Services.UiPreferences.pillHeight
    implicitWidth: Services.UiPreferences.pillHeight
    width: implicitWidth
    height: implicitHeight

    // Temporary theme preview button pill background
    Rectangle {
        anchors.fill: parent
        visible: !root.embedded || previewMouse.containsMouse
        radius: Services.UiPreferences.pillRadius
        color: Colors.barItemBg
        border.color: Colors.barItemBorder
        border.width: root.embedded ? 0 : Services.UiPreferences.barBorderWidth
    }

    // Theme preview icon
    Controls.Icon {
        anchors.fill: parent
        name: "theme"
        tone: previewMouse.containsMouse ? "primary" : "subtle"
        sizeRole: "bar"
    }

    // Theme preview click target
    MouseArea {
        id: previewMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.themePreview)
            root.themePreview.toggle()
    }
}
