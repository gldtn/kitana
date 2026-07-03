// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Row {
    id: root

    Custom.Settings {
        id: settings
    }

    property string iconName: Icons.defaultIcon
    property int value: 0
    property string label: ""
    property bool iconClickable: false

    signal moved(real value)
    signal iconClicked

    width: parent ? parent.width : 0
    height: 28
    spacing: 10

    // Slider row icon
    Controls.Icon {
        id: sliderIcon

        anchors.verticalCenter: parent.verticalCenter
        width: 20
        name: root.iconName
        tone: "primary"
        sizeRole: "bar"

        // Optional icon click target
        MouseArea {
            anchors.fill: parent
            enabled: root.iconClickable
            hoverEnabled: enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.iconClicked()
        }
    }

    // Slider control
    Controls.ValueSlider {
        id: control

        anchors.verticalCenter: parent.verticalCenter
        width: root.width - sliderIcon.width - valueText.width - root.spacing * 2
        height: 22
        value: root.value
        onMoved: root.moved(value)
    }

    // Slider value label
    Text {
        id: valueText

        anchors.verticalCenter: parent.verticalCenter
        width: 34
        text: root.label
        color: Colors.fgPrimary
        horizontalAlignment: Text.AlignRight
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize
        font.weight: Font.DemiBold
    }
}
