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

    property var screenshotPanel: null
    property bool embedded: false

    implicitHeight: Services.UiPreferences.pillHeight
    implicitWidth: Services.UiPreferences.pillHeight
    width: implicitWidth
    height: implicitHeight

    // Screenshot button pill background
    Rectangle {
        anchors.fill: parent
        visible: !root.embedded || screenshotMouse.containsMouse
        radius: Services.UiPreferences.pillRadius
        color: Colors.barItemBg
        border.color: Colors.barItemBorder
        border.width: root.embedded ? 0 : settings.borderWidth
    }

    // Screenshot icon
    Controls.Icon {
        anchors.fill: parent
        name: "screenshot.default"
        tone: screenshotMouse.containsMouse ? "primary" : "subtle"
        sizeRole: "bar"
    }

    // Screenshot panel click target
    MouseArea {
        id: screenshotMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.screenshotPanel)
            root.screenshotPanel.toggle()
    }
}
