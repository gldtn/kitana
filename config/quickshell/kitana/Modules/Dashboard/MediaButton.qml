// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string text: ""
    property bool prominent: false

    signal clicked

    Layout.preferredWidth: prominent ? 48 : 40
    Layout.preferredHeight: prominent ? 40 : 36
    radius: 12
    color: prominent ? Colors.surfaceHighlight : (mediaButtonMouse.containsMouse ? Colors.surfaceHover : Colors.surface)
    border.color: prominent ? Colors.panelBorderStrong : Colors.panelBorder
    border.width: 1

    Text {
        anchors.centerIn: parent
        text: root.text
        color: root.prominent ? Colors.accent : Colors.foreground
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: settings.fontFamily
        font.pixelSize: root.prominent ? settings.iconPixelSize + 2 : settings.iconPixelSize - 1
    }

    MouseArea {
        id: mediaButtonMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
