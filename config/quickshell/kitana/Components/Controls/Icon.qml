// Kitana managed Quickshell control

import QtQuick
import "../.."
import "../../custom" as Custom

Text {
    id: root

    Custom.Settings { id: settings }

    property string icon: ""
    property int size: settings.iconPixelSize

    text: icon
    font.family: Typography.iconFontFamily
    font.pixelSize: size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
