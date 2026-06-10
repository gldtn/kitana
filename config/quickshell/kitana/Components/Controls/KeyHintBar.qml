// Kitana managed Quickshell control

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

Text {
    id: root

    Custom.Settings { id: settings }

    property string hints: ""

    Layout.fillWidth: true
    text: hints
    color: Colors.muted
    horizontalAlignment: Text.AlignHCenter
    font.family: Typography.fontFamily
    font.pixelSize: settings.textPixelSize - 1
}
