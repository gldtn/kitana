// Kitana managed Quickshell control

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

// Keyboard hint text row
Text {
    id: root

    Custom.Settings { id: settings }

    property string hints: ""

    Layout.fillWidth: true
    text: hints
    color: Colors.foregroundMuted
    horizontalAlignment: Text.AlignHCenter
    font.family: Typography.fontFamily
    font.pixelSize: settings.textPixelSize - 1
}
