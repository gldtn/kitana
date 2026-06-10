// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom
import "../../Services" as Services

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property var item: null

    width: parent ? parent.width : 0
    height: Math.max(58, bodyText.visible ? 76 : 58)
    radius: 11
    color: mouse.containsMouse ? Colors.surfaceHover : Colors.surface

    Column {
        anchors.left: parent.left
        anchors.right: dismissButton.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10
        anchors.rightMargin: 8
        spacing: 3

        Text {
            width: parent.width
            text: root.item ? root.item.summary : "Notification"
            color: Colors.foreground
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.Bold
        }

        Text {
            width: parent.width
            text: root.item ? root.item.appName : "app"
            color: Colors.muted
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize - 1
        }

        Text {
            id: bodyText
            width: parent.width
            visible: text.length > 0
            text: root.item ? root.item.body : ""
            color: Colors.muted
            elide: Text.ElideRight
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize - 1
            textFormat: Text.PlainText
        }
    }

    Controls.MaterialIcon {
        id: dismissButton
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        icon: Icons.close
        color: Colors.foreground
        size: 14

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Services.NotificationService.dismiss(root.item)
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Services.NotificationService.dismiss(root.item)
    }
}
