// Kitana managed Quickshell control

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

// Reusable framed text input with optional leading icon
Rectangle {
    id: root

    Custom.Settings {
        id: settings
    }

    property alias text: input.text
    property alias echoMode: input.echoMode
    property alias inputFocus: input.focus
    property string placeholderText: ""
    property string iconName: ""
    property int fieldHeight: 36
    property int iconSize: settings.iconPixelSize
    property int horizontalPadding: 12
    property int textPixelSize: settings.textPixelSize
    property color backgroundColor: Colors.inputBg
    property color foregroundColor: Colors.inputFg
    property color placeholderColor: Colors.inputPlaceholderFg
    property color idleBorderColor: Colors.inputBorder
    property color focusBorderColor: Colors.inputBorderFocus
    property color selectionColor: Colors.inputSelection
    property color selectedTextColor: Colors.inputSelectedFg
    readonly property bool inputActiveFocus: input.activeFocus

    signal accepted
    signal escaped
    signal editingFinished
    signal keyPressed(var event)

    function forceActiveFocus(reason: var): void {
        if (reason !== undefined)
            input.forceActiveFocus(reason);
        else
            input.forceActiveFocus();
    }

    Layout.preferredHeight: fieldHeight
    implicitHeight: fieldHeight
    radius: 10
    color: backgroundColor
    border.color: input.activeFocus ? focusBorderColor : idleBorderColor
    border.width: 1

    Behavior on border.color {
        ColorAnimation {
            duration: 110
            easing.type: Easing.OutCubic
        }
    }

    // Input content row
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        spacing: root.iconName.length > 0 ? 8 : 0

        Icon {
            visible: root.iconName.length > 0
            name: root.iconName.length > 0 ? root.iconName : Icons.defaultIcon
            tone: "muted"
            size: root.iconSize
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                anchors.fill: parent
                visible: root.placeholderText.length > 0 && input.text.length === 0
                text: root.placeholderText
                color: root.placeholderColor
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: root.textPixelSize
            }

            TextInput {
                id: input

                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                color: root.foregroundColor
                selectionColor: root.selectionColor
                selectedTextColor: root.selectedTextColor
                font.family: Typography.fontFamily
                font.pixelSize: root.textPixelSize
                clip: true
                activeFocusOnTab: root.activeFocusOnTab
                onEditingFinished: root.editingFinished()
                Keys.onEscapePressed: root.escaped()
                Keys.onReturnPressed: root.accepted()
                Keys.onPressed: event => root.keyPressed(event)
            }
        }
    }
}
