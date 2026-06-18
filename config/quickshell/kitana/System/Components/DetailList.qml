// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../custom" as Custom

Column {
    id: root

    Custom.Settings { id: settings }

    property string title: ""
    property string emptyText: ""
    property var modelData: []
    property Component delegateComponent
    property Component headerComponent: null

    width: parent ? parent.width : 0
    spacing: 10

    // Detail list heading
    Text {
        width: root.width
        text: root.title
        color: Colors.foreground
        font.family: Typography.fontFamily
        font.pixelSize: 14
        font.weight: Font.Bold
    }

    // Optional detail list header
    Loader {
        width: root.width
        sourceComponent: root.headerComponent
    }

    // Empty detail list message
    Text {
        width: root.width
        visible: root.modelData.length === 0 && !root.headerComponent
        text: root.emptyText
        color: Colors.foregroundMuted
        horizontalAlignment: Text.AlignHCenter
        font.family: Typography.fontFamily
        font.pixelSize: settings.textPixelSize
    }

    // Detail list row repeater
    Repeater {
        model: root.modelData
        delegate: root.delegateComponent
    }
}
