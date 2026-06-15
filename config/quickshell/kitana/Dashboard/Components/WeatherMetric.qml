// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Item {
    id: root

    Custom.Settings { id: settings }

    property string iconName: Icons.defaultIcon
    property string label: ""
    property string value: ""
    property int labelPixelSize: settings.textPixelSize - 1
    property int valuePixelSize: settings.textPixelSize
    property int valueWeight: Font.DemiBold
    property int contentWidth: 108
    property int iconWidth: 18
    property bool centerContent: false

    Layout.minimumWidth: 92
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignTop
    implicitWidth: contentWidth
    implicitHeight: Math.max(iconSlot.implicitHeight, textColumn.implicitHeight)

    Item {
        id: content
        width: root.contentWidth
        height: root.implicitHeight
        x: Math.round((parent.width - width) / 2)
        y: root.centerContent ? Math.round((parent.height - height) / 2) : 0

        Controls.Icon {
            id: iconSlot
            width: root.iconWidth
            anchors.left: parent.left
            anchors.verticalCenter: textColumn.verticalCenter
            name: root.iconName
            tone: "accent"
            sizeRole: "bar"
        }

        Column {
            id: textColumn
            anchors.left: parent.left
            anchors.leftMargin: root.iconWidth + 8
            anchors.top: parent.top
            width: root.contentWidth - root.iconWidth - 8
            spacing: 0

            Text {
                width: parent.width
                text: root.label
                color: Colors.foregroundMuted
                horizontalAlignment: Text.AlignLeft
                font.family: Typography.fontFamily
                font.pixelSize: root.labelPixelSize
            }

            Text {
                width: parent.width
                text: root.value
                color: Colors.foreground
                horizontalAlignment: Text.AlignLeft
                font.family: Typography.fontFamily
                font.pixelSize: root.valuePixelSize
                font.weight: root.valueWeight
            }
        }
    }
}
