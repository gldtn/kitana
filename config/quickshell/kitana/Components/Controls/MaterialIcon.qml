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
    font.variableAxes: {
        "FILL": Typography.iconFill,
        "wght": Typography.iconWeight,
        "GRAD": Typography.iconGrade,
        "opsz": Typography.iconOpticalSize
    }
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
