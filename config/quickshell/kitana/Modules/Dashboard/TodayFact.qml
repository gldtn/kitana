// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

RowLayout {
    id: root

    Custom.Settings { id: settings }

    property string icon: ""
    property string label: ""
    property string value: ""

    Layout.fillWidth: true
    spacing: 7

    Text {
        Layout.preferredWidth: 18
        Layout.alignment: Qt.AlignVCenter
        text: root.icon
        color: Colors.accent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: settings.fontFamily
        font.pixelSize: settings.iconPixelSize - 1
    }

    Text {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        text: root.label
        color: Colors.muted
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        font.family: settings.fontFamily
        font.pixelSize: settings.textPixelSize
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        text: root.value
        color: Colors.foreground
        verticalAlignment: Text.AlignVCenter
        font.family: settings.fontFamily
        font.pixelSize: settings.textPixelSize
        font.weight: Font.DemiBold
    }
}
