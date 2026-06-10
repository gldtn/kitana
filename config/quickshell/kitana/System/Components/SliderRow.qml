// Kitana managed Quickshell system component

import QtQuick
import QtQuick.Controls
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Row {
    id: root

    Custom.Settings { id: settings }

    property string icon: ""
    property int value: 0
    property string label: ""
    property bool iconClickable: false

    signal moved(real value)
    signal iconClicked

    width: parent ? parent.width : 0
    height: 28
    spacing: 10

    Controls.Icon {
        id: sliderIcon

        anchors.verticalCenter: parent.verticalCenter
        width: 20
        icon: root.icon
        color: Colors.foreground
        size: 15

        MouseArea {
            anchors.fill: parent
            enabled: root.iconClickable
            hoverEnabled: enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.iconClicked()
        }
    }

    Slider {
        id: control

        anchors.verticalCenter: parent.verticalCenter
        width: root.width - sliderIcon.width - valueText.width - root.spacing * 2
        height: 22
        from: 0
        to: 100
        value: root.value
        onMoved: root.moved(value)

        background: Rectangle {
            x: control.leftPadding
            y: control.topPadding + control.availableHeight / 2 - height / 2
            width: control.availableWidth
            height: 6
            radius: 3
            color: Colors.surfaceAlt

            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                radius: parent.radius
                color: Colors.accent
            }
        }

        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: control.topPadding + control.availableHeight / 2 - height / 2
            width: 16
            height: 16
            radius: 8
            color: Colors.accent
            border.color: Colors.panelBorderStrong
            border.width: 1
        }
    }

    Text {
        id: valueText

        anchors.verticalCenter: parent.verticalCenter
        width: 34
        text: root.label
        color: Colors.foreground
        horizontalAlignment: Text.AlignRight
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize
        font.weight: Font.DemiBold
    }
}
