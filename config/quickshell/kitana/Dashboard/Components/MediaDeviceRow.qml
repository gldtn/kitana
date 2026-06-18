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
    property string iconName: "audio.output"
    property string subtitle: "Output device"
    property bool active: false

    signal clicked

    Layout.fillWidth: true
    Layout.preferredHeight: 46
    radius: 12
    color: active ? Colors.controlActiveBackground : (mediaDeviceMouse.containsMouse ? Colors.controlHoverBackground : Colors.cardBackground)
    border.color: active ? Colors.controlActiveBorder : Colors.panelBorder
    border.width: 1

    // Audio device icon and labels
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Controls.Icon {
            name: root.active ? "ui.check" : root.iconName
            tone: "accent"
            sizeRole: "bar"
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
                color: Colors.foregroundMuted
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 1
            }
        }
    }

    // Audio device selection target
    MouseArea {
        id: mediaDeviceMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
