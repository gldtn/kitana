// Kitana managed Quickshell module

import QtQuick
import Quickshell.Io
import "../.."
import "../../Components/Controls" as Controls
import "../../Services" as Services
import "../../custom" as Custom

Item {
    id: root

    Custom.Settings {
        id: settings
    }

    property bool embedded: false

    implicitHeight: Services.UiPreferences.pillHeight
    implicitWidth: Services.UiPreferences.pillHeight
    width: implicitWidth
    height: implicitHeight

    // Session button pill background
    Rectangle {
        anchors.fill: parent
        visible: !root.embedded || sessionMouse.containsMouse
        radius: Services.UiPreferences.pillRadius
        color: Colors.bgSecondary
        border.color: Colors.borderFaint
        border.width: root.embedded ? 0 : settings.borderWidth
    }

    // Session panel IPC runner
    Process {
        id: sessionMenu
    }

    // Power icon
    Controls.Icon {
        anchors.centerIn: parent
        name: "power.power"
        tone: sessionMouse.containsMouse ? "primary" : "subtle"
        sizeRole: "bar"
    }

    // Session panel click target
    MouseArea {
        id: sessionMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: sessionMenu.exec(["quickshell", "ipc", "-c", "kitana", "call", "kitana-session", "toggle"])
    }
}
