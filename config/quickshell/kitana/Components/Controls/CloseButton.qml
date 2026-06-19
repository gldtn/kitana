// Kitana managed Quickshell control

import QtQuick
import QtQuick.Layouts
import "../.."

// Reusable close/dismiss affordance
Rectangle {
    id: root

    property string variant: "subtle"
    property string iconName: "ui.close"
    property int buttonSize: 22
    property int iconSize: 13
    property color normalColor: "transparent"
    property color hoverColor: defaultHoverColor(variant)
    property string normalTone: defaultNormalTone(variant)
    property string hoverTone: defaultHoverTone(variant)
    readonly property bool hovered: closeMouse.containsMouse

    signal clicked

    implicitWidth: buttonSize
    implicitHeight: buttonSize
    Layout.preferredWidth: buttonSize
    Layout.preferredHeight: buttonSize
    radius: Math.round(Math.min(width, height) / 2)
    opacity: enabled ? 1 : 0.45
    color: hovered ? hoverColor : normalColor

    function defaultHoverColor(value: string): color {
        if (value === "dark")
            return Colors.scrimTertiary;
        if (value === "light")
            return Colors.subtleSecondary;
        return Colors.scrimSecondary;
    }

    function defaultNormalTone(value: string): string {
        if (value === "light")
            return "secondary";
        if (value === "dark")
            return "muted";
        return "muted";
    }

    function defaultHoverTone(value: string): string {
        if (value === "light")
            return "primary";
        if (value === "dark")
            return "primary";
        return "primary";
    }

    Behavior on color {
        ColorAnimation {
            duration: 110
            easing.type: Easing.OutCubic
        }
    }

    Icon {
        anchors.centerIn: parent
        name: root.iconName
        tone: root.hovered ? root.hoverTone : root.normalTone
        size: root.iconSize
    }

    MouseArea {
        id: closeMouse

        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
