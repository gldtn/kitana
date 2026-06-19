// Kitana managed Quickshell bar item

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

    property var startMenu: null
    property bool embedded: false

    implicitHeight: Services.UiPreferences.pillHeight
    implicitWidth: Services.UiPreferences.pillHeight
    width: implicitWidth
    height: implicitHeight

    // Start button pill background
    Rectangle {
        anchors.fill: parent
        visible: !root.embedded || startMouse.containsMouse
        radius: Services.UiPreferences.pillRadius
        color: Colors.bgSecondary
        border.color: Colors.borderFaint
        border.width: root.embedded ? 0 : settings.borderWidth
    }

    // Arch start icon
    Controls.Icon {
        anchors.fill: parent
        name: "brand.arch"
        tone: startMouse.containsMouse ? "brand" : "subtle"
        sizeRole: "bar"
    }

    // Start menu click target
    MouseArea {
        id: startMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.startMenu)
            root.startMenu.toggle()
    }
}
