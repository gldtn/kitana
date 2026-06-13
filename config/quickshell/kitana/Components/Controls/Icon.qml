// Kitana managed Quickshell control

import QtQuick
import "../.."
import "../../custom" as Custom

Text {
    id: root

    Custom.Settings { id: settings }

    property string name: Icons.defaultIcon
    property string tone: "primary"
    property string sizeRole: "button"
    property int size: 0

    text: Icons.glyph(name)
    color: Icons.toneColor(tone)
    font.family: Typography.iconFontFamily
    font.pixelSize: size > 0 ? size : Icons.size(sizeRole)
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
