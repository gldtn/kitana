// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings {
        id: settings
    }

    property string iconName: Icons.defaultIcon
    property bool prominent: false
    property bool selected: false

    signal clicked

    Layout.preferredWidth: prominent ? 46 : 38
    Layout.preferredHeight: prominent ? 46 : 38
    radius: prominent ? 14 : 14
    color: !enabled ? Colors.subtlePrimary : prominent ? (mediaButtonMouse.containsMouse ? Colors.bgAccent : Colors.alpha(Colors.bgAccent, 0.3)) : selected ? (mediaButtonMouse.containsMouse ? Colors.bgAccent : Colors.alpha(Colors.bgAccent, 0.3)) : mediaButtonMouse.containsMouse ? Colors.bgTertiary : Colors.subtleSecondary
    border.color: !enabled ? Colors.borderFaint : (prominent || selected ? Colors.borderAccent : Colors.borderFaint)
    border.width: 0.8

    // Media control icon
    Controls.Icon {
        anchors.fill: parent
        name: root.iconName
        tone: !root.enabled ? "disabled" : (root.prominent ? "onAccent" : (root.selected ? "accent" : "primary"))
        size: root.prominent ? settings.iconPixelSize + 4 : settings.iconPixelSize - 1
    }

    // Media control click target
    MouseArea {
        id: mediaButtonMouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
