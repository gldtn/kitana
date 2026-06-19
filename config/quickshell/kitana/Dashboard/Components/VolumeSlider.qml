// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom
import "../../Services" as Services

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property int value: 0

    Layout.preferredHeight: 34
    radius: 10
    color: Colors.bgTertiary
    border.color: volumeMouse.containsMouse ? Colors.borderAccent : Colors.borderFaint
    border.width: 1
    clip: true

    // Filled volume level track
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * Math.max(0, Math.min(100, root.value)) / 100
        radius: parent.radius
        color: Colors.subtlePrimary
    }

    // Volume value label
    Text {
        anchors.centerIn: parent
        text: "Volume " + root.value + "%"
        color: Colors.fgPrimary
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize
        font.weight: Font.DemiBold
    }

    // Drag target for audio volume
    MouseArea {
        id: volumeMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => Services.SystemStatus.setAudioVolume(mouse.x / width * 100)
        onPositionChanged: mouse => {
            if (pressed)
                Services.SystemStatus.setAudioVolume(mouse.x / width * 100);
        }
    }
}
