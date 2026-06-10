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

    Text {
        width: root.width
        text: root.title
        color: Colors.foreground
        font.family: settings.fontFamily
        font.pixelSize: 14
        font.weight: Font.Bold
    }

    Loader {
        width: root.width
        sourceComponent: root.headerComponent
    }

    Text {
        width: root.width
        visible: root.modelData.length === 0 && !root.headerComponent
        text: root.emptyText
        color: Colors.muted
        horizontalAlignment: Text.AlignHCenter
        font.family: settings.fontFamily
        font.pixelSize: settings.textPixelSize
    }

    Repeater {
        model: root.modelData
        delegate: root.delegateComponent
    }
}
