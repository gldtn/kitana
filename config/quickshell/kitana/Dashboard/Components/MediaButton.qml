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
    property int cornerRadius: prominent ? 10 : 8
    property string iconTone: ""

    signal clicked

    Layout.preferredWidth: prominent ? 46 : 38
    Layout.preferredHeight: prominent ? 46 : 38
    radius: cornerRadius
    color: !enabled ? Colors.subtlePrimary : Colors.subtleSecondary
    border.color: !enabled ? Colors.borderFaint : (selected ? Colors.borderAccent : Colors.borderFaint)
    border.width: 0.8

    // Media control icon
    Controls.Icon {
        anchors.fill: parent
        name: root.iconName
        tone: !root.enabled ? "disabled" : (root.iconTone.length > 0 ? root.iconTone : (root.prominent ? (mediaButtonMouse.containsMouse ? "accent" : "secondary") : (root.selected ? "accent" : "primary")))
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
