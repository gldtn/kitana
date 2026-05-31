// Kitana managed Quickshell module

import QtQuick
import QtQuick.Layouts
import ".."
import "../custom" as Custom

Rectangle {
    id: root

    Custom.Settings {
        id: settings
    }

    property var dashboardPanel: null

    implicitHeight: settings.pillHeight
    implicitWidth: clockText.implicitWidth + settings.clockHorizontalPadding
    width: implicitWidth
    height: implicitHeight

    radius: height / settings.radiusDivisor
    color: Colors.panelBackground
    border.color: Colors.panelBorder
    border.width: settings.borderWidth

    Text {
        id: clockText

        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "ddd MMM d    h:mm AP")
        color: Colors.foreground
        font.family: settings.fontFamily
        font.pixelSize: settings.clockPixelSize
        font.weight: Font.DemiBold

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd MMM d    h:mm AP")
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.dashboardPanel) root.dashboardPanel.toggle("datetime")
    }
}
