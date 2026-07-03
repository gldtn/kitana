// Kitana managed Quickshell control

import QtQuick
import QtQuick.Controls.Basic as QtControls
import "../.."

// Shared value slider used by panel controls and dashboard cards.
QtControls.Slider {
    id: root

    property color trackColor: Colors.subtleSecondary
    property color fillColor: Colors.fgAccent
    property color handleColor: fillColor
    property int trackHeight: 6
    property int handleSize: 16

    from: 0
    to: 100
    implicitHeight: 22

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: root.trackHeight
        radius: height / 2
        color: root.trackColor

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: root.enabled ? root.fillColor : Colors.borderFaint
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.handleSize
        height: root.handleSize
        radius: width / 2
        color: root.enabled ? root.handleColor : Colors.borderFaint
        border.width: 0
    }
}
