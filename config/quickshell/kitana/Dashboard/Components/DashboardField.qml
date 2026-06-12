// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

ColumnLayout {
    id: root

    Custom.Settings { id: settings }

    property string label: ""
    property string value: ""
    property bool secret: false

    signal committed(string value)
    spacing: 5

    Text {
        Layout.fillWidth: true
        text: root.label
        color: Colors.mutedForeground
        elide: Text.ElideRight
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize - 1
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 34
        radius: 10
        color: Colors.panelCardBackground
        border.color: fieldInput.activeFocus ? Colors.panelButtonBorderActive : Colors.panelBorder
        border.width: 1

        TextInput {
            id: fieldInput
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            verticalAlignment: TextInput.AlignVCenter
            text: root.value
            echoMode: root.secret ? TextInput.Password : TextInput.Normal
            color: Colors.primaryForeground
            selectionColor: Colors.panelButtonBackgroundActive
            selectedTextColor: Colors.primaryForeground
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            onEditingFinished: root.committed(text)
        }
    }
}
