// Kitana managed Quickshell module

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../Components/Controls" as Controls
import "../custom" as Custom
import "../Services" as Services

// qmllint disable uncreatable-type
PanelWindow {
    id: root
    // qmllint enable uncreatable-type

    Custom.Settings { id: settings }

    property var panelScreen: null

    screen: panelScreen
    visible: Services.NotificationService.popups.length > 0 && !Services.NotificationService.doNotDisturb
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-panel"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        right: true
    }

    // qmllint disable unqualified unresolved-type
    margins.top: Services.UiPreferences.panelHeight + Services.UiPreferences.topMargin + 10
    margins.right: settings.sideMargin
    // qmllint enable unqualified unresolved-type

    implicitWidth: 360
    implicitHeight: popupColumn.implicitHeight

    // Stack of active notification popups
    Column {
        id: popupColumn

        width: root.implicitWidth
        spacing: 8

        // Popup notification repeater
        Repeater {
            model: Services.NotificationService.popups

            // One notification popup card
            Rectangle {
                id: notificationPopup

                required property var modelData
                readonly property int verticalPadding: 16

                width: popupColumn.width
                height: Math.max(84, contentColumn.implicitHeight + verticalPadding * 2)
                radius: 20
                color: Colors.bgSecondary
                border.color: Colors.borderFaint
                border.width: 1

                // Notification tone icon badge
                Rectangle {
                    id: notificationIcon

                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: 42
                    height: 42
                    radius: 21
                    color: Services.NotificationService.toneBackground(notificationPopup.modelData)

                    // Notification icon glyph
                    Controls.Icon {
                        anchors.centerIn: parent
                        name: "notifications.on"
                        color: Services.NotificationService.toneForeground(notificationPopup.modelData)
                        size: 20
                    }
                }

                // Notification title, app, and body text
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
                        text: notificationPopup.modelData.summary
                        color: Colors.fgPrimary
                        elide: Text.ElideRight
                        clip: true
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        text: notificationPopup.modelData.appName
                        color: Colors.fgSecondary
                        elide: Text.ElideRight
                        clip: true
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                    }

                    Text {
                        id: bodyText
                        width: parent.width
                        visible: text.length > 0
                        text: notificationPopup.modelData.bodyMarkup
                        color: Colors.fgSecondary
                        elide: Text.ElideRight
                        wrapMode: Text.WrapAnywhere
                        maximumLineCount: 2
                        clip: true
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                        textFormat: Text.RichText
                        onLinkActivated: link => Quickshell.execDetached(["xdg-open", link])

                        // Link hover cursor handler
                        HoverHandler {
                            cursorShape: bodyText.hoveredLink.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                }

                // Notification dismiss button
                Controls.CloseButton {
                    id: closeButton

                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    buttonSize: 32
                    iconSize: 14
                    width: 32
                    height: 32
                    onClicked: Services.NotificationService.dismiss(notificationPopup.modelData)
                }
            }
        }
    }
}
