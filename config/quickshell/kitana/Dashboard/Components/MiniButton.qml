// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string text: ""
    property string iconName: ""
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
        visible: root.iconName.length === 0
        anchors.centerIn: parent
        text: root.text
        color: Colors.primaryForeground
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize
    }

    Controls.Icon {
        visible: root.iconName.length > 0
        anchors.centerIn: parent
        name: root.iconName.length > 0 ? root.iconName : Icons.defaultIcon
        tone: "primary"
        sizeRole: "button"
    }

    MouseArea {
        id: miniMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
