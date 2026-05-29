// Kitana managed Quickshell module

import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../custom" as Custom
import "../Services" as Services

PanelWindow {
    id: root

    Custom.Settings { id: settings }

    property var panelScreen: null

    screen: panelScreen
    visible: Services.NotificationService.popups.length > 0 && !Services.NotificationService.doNotDisturb
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        right: true
    }

    margins {
        top: settings.panelHeight + settings.topMargin + 10
        right: settings.sideMargin
    }

    implicitWidth: 360
    implicitHeight: popupColumn.implicitHeight

    Column {
        id: popupColumn

        width: root.implicitWidth
        spacing: 8

        Repeater {
            model: Services.NotificationService.popups

            Rectangle {
                required property var modelData

                width: popupColumn.width
                height: Math.max(72, bodyText.visible ? 90 : 72)
                radius: 14
                color: Colors.panelStrong
                border.color: Colors.panelBorder
                border.width: 1

                Column {
                    anchors.left: parent.left
                    anchors.right: closeButton.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 12
                    anchors.rightMargin: 8
                    spacing: 3

                    Text {
                        width: parent.width
                        text: modelData.summary
                        color: Colors.foreground
                        elide: Text.ElideRight
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        text: modelData.appName
                        color: Colors.muted
                        elide: Text.ElideRight
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                    }

                    Text {
                        id: bodyText
                        width: parent.width
                        visible: text.length > 0
                        text: modelData.body
                        color: Colors.muted
                        elide: Text.ElideRight
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                        textFormat: Text.PlainText
                    }
                }

                Text {
                    id: closeButton
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    text: "󰅖"
                    color: Colors.foreground
                    font.family: settings.fontFamily
                    font.pixelSize: 14

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.NotificationService.dismiss(modelData)
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.NotificationService.dismiss(modelData)
                }
            }
        }
    }
}
