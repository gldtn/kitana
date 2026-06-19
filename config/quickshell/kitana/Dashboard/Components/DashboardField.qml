// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

ColumnLayout {
    id: root

    Custom.Settings { id: settings }

    property string label: ""
    property string value: ""
    property bool secret: false

    signal committed(string value)
    signal escaped
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
    Controls.InputField {
        id: fieldInput

        Layout.fillWidth: true
        fieldHeight: 34
        radius: 10
        text: root.value
        echoMode: root.secret ? TextInput.Password : TextInput.Normal
        onEscaped: root.escaped()
        onEditingFinished: root.committed(fieldInput.text)
    }
}
