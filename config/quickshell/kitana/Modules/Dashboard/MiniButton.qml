// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string text: ""
    property int widthOverride: 32
    property int heightOverride: 28

    signal clicked

    Layout.preferredWidth: widthOverride
    Layout.preferredHeight: heightOverride
    width: widthOverride
    height: heightOverride
    radius: 9
    color: miniMouse.containsMouse ? Colors.surfaceHover : Colors.surface
    border.color: Colors.panelBorder
    border.width: 1

    Text {
        anchors.centerIn: parent
        text: root.text
        color: Colors.foreground
        font.family: settings.fontFamily
        font.pixelSize: settings.textPixelSize
    }

    MouseArea {
        id: miniMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
