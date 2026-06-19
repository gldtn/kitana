// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

RowLayout {
    id: root

    Custom.Settings { id: settings }

    property string name: ""
    property string clockDateText: ""
    property string clockTimeText: "--"

    Layout.fillWidth: true
    spacing: 6

    // Clock name and date column
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Text {
            Layout.fillWidth: true
            text: root.name
            color: Colors.fgPrimary
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            text: root.clockDateText
            color: Colors.fgSecondary
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize - 1
        }
    }

    // Clock time value
    Text {
        text: root.clockTimeText
        color: Colors.fgAccent
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize + 1
        font.weight: Font.Bold
    }
}
