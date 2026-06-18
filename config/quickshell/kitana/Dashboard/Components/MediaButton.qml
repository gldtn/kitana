// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property string iconName: Icons.defaultIcon
    property bool prominent: false

    signal clicked

    Layout.preferredWidth: prominent ? 48 : 40
    Layout.preferredHeight: prominent ? 40 : 36
    radius: 12
    color: prominent ? Colors.controlActiveBackground : (mediaButtonMouse.containsMouse ? Colors.controlHoverBackground : Colors.cardBackground)
    border.color: prominent ? Colors.controlActiveBorder : Colors.panelBorder
    border.width: 1

    // Media control icon
    Controls.Icon {
        anchors.centerIn: parent
        name: root.iconName
        tone: root.prominent ? "accent" : "primary"
        size: root.prominent ? settings.iconPixelSize + 2 : settings.iconPixelSize - 1
    }

    // Media control click target
    MouseArea {
        id: mediaButtonMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
