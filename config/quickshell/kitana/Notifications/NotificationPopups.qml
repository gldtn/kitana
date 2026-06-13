// Kitana managed Quickshell module

import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../Components/Controls" as Controls
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
                readonly property int verticalPadding: 16

                width: popupColumn.width
                height: Math.max(84, contentColumn.implicitHeight + verticalPadding * 2)
                radius: 20
                color: Colors.withAlpha(Colors.base0, "cc")
                border.color: Colors.panelBorder
                border.width: 1

                Rectangle {
                    id: notificationIcon

                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: 42
                    height: 42
                    radius: 21
                    color: Services.NotificationService.toneBackground(modelData)

                    Controls.Icon {
                        anchors.centerIn: parent
                        name: "notifications.on"
                        color: Services.NotificationService.toneForeground(modelData)
                        size: 20
                    }
                }

                Column {
                    id: contentColumn

                    anchors.left: notificationIcon.right
                    anchors.right: closeButton.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    anchors.rightMargin: 4
                    spacing: 3

                    Text {
                        width: parent.width
                        text: modelData.summary
                        color: Colors.primaryForeground
                        elide: Text.ElideRight
                        clip: true
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        text: modelData.appName
                        color: Colors.mutedForeground
                        elide: Text.ElideRight
                        clip: true
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                    }

                    Text {
                        id: bodyText
                        width: parent.width
                        visible: text.length > 0
                        text: modelData.bodyMarkup
                        color: Colors.mutedForeground
                        elide: Text.ElideRight
                        wrapMode: Text.WrapAnywhere
                        maximumLineCount: 2
                        clip: true
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                        textFormat: Text.RichText
                        onLinkActivated: link => Quickshell.execDetached(["xdg-open", link])

                        HoverHandler {
                            cursorShape: bodyText.hoveredLink.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                }

                Item {
                    id: closeButton

                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    width: 32
                    height: 32

                    Controls.Icon {
                        anchors.centerIn: parent
                        name: "ui.close"
                        tone: closeMouse.containsMouse ? "primary" : "muted"
                        size: 14
                    }

                    MouseArea {
                        id: closeMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.NotificationService.dismiss(modelData)
                    }
                }
            }
        }
    }
}
