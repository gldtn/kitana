// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string text: ""
    property bool iconText: false
    property int widthOverride: 32
    property int heightOverride: 28

    signal clicked

    Layout.preferredWidth: widthOverride
    Layout.preferredHeight: heightOverride
    width: widthOverride
    height: heightOverride
    radius: 9
    color: miniMouse.containsMouse ? Colors.panelButtonBackgroundHover : Colors.panelCardBackground
    border.color: Colors.panelBorder
    border.width: 1

    Text {
        anchors.centerIn: parent
        text: root.text
        color: Colors.primaryForeground
        font.family: root.iconText ? Typography.iconFontFamily : Typography.fontFamily
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
