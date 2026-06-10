// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string name: ""
    property string icon: Icons.audioOutput
    property string subtitle: "Output device"
    property bool active: false

    signal clicked

    Layout.fillWidth: true
    Layout.preferredHeight: 46
    radius: 12
    color: active ? Colors.surfaceHighlight : (mediaDeviceMouse.containsMouse ? Colors.surfaceHover : Colors.surface)
    border.color: active ? Colors.panelBorderStrong : Colors.panelBorder
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Controls.Icon {
            icon: root.active ? Icons.check : root.icon
            color: Colors.accent
            size: settings.iconPixelSize
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.name
                color: Colors.foreground
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: root.active ? "Current output" : root.subtitle
                color: Colors.muted
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 1
            }
        }
    }

    MouseArea {
        id: mediaDeviceMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
