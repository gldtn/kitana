// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

RowLayout {
    id: root

    Custom.Settings { id: settings }

    property string iconName: Icons.defaultIcon
    property string label: ""
    property string value: ""

    Layout.fillWidth: true
    spacing: 7

    Controls.Icon {
        Layout.preferredWidth: 18
        Layout.alignment: Qt.AlignVCenter
        name: root.iconName
        tone: "accent"
        sizeRole: "bar"
    }

    Text {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        text: root.label
        color: Colors.foregroundMuted
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        text: root.value
        color: Colors.foreground
        verticalAlignment: Text.AlignVCenter
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize
        font.weight: Font.DemiBold
    }
}
