// Kitana managed Quickshell module

import QtQuick
import QtQuick.Layouts
import ".."
import "../custom" as Custom

Rectangle {
    Custom.Settings {
        id: settings
    }

    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
    Layout.preferredHeight: settings.pillHeight
    Layout.preferredWidth: clockText.implicitWidth + settings.clockHorizontalPadding

    radius: height / settings.radiusDivisor
    color: Colors.panel
    border.color: Colors.panelBorder
    border.width: settings.borderWidth

    Text {
        id: clockText

        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "ddd MMM d  h:mm AP")
        color: Colors.foreground
        font.family: settings.fontFamily
        font.pixelSize: settings.clockPixelSize
        font.weight: Font.DemiBold

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd MMM d  h:mm AP")
        }
    }
}
