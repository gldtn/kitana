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

    // Field label
    Text {
        Layout.fillWidth: true
        text: root.label
        color: Colors.fgSecondary
        elide: Text.ElideRight
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize - 1
    }

    // Text input frame
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 34
        radius: 10
        color: Colors.bgTertiary
        border.color: fieldInput.activeFocus ? Colors.borderAccent : Colors.borderFaint
        border.width: 1

        // Editable field value
        TextInput {
            id: fieldInput
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            verticalAlignment: TextInput.AlignVCenter
            text: root.value
            echoMode: root.secret ? TextInput.Password : TextInput.Normal
            color: Colors.fgPrimary
            selectionColor: Colors.subtlePrimary
            selectedTextColor: Colors.fgPrimary
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            onEditingFinished: root.committed(text)
        }
    }
}
