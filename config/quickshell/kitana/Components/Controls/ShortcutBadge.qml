// Kitana managed Quickshell control

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

// Reusable keyboard shortcut badge
Rectangle {
    id: root

    Custom.Settings {
        id: settings
    }

    property string text: ""
    property int badgeHeight: 18
    property int horizontalPadding: 10
    property int textPixelSize: settings.textPixelSize - 2
    property color backgroundColor: Colors.scrimSecondary
    property color borderColor: Colors.borderLight
    property string tone: "subtle"

    implicitWidth: shortcutLabel.implicitWidth + horizontalPadding
    implicitHeight: badgeHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: 6
    color: backgroundColor
    border.color: borderColor
    border.width: 0.8

    Text {
        id: shortcutLabel

        anchors.centerIn: parent
        text: root.text
        color: Icons.toneColor(root.tone)
        font.family: Typography.fontFamily
        font.pixelSize: root.textPixelSize
        font.weight: Font.DemiBold
    }
}
