// Kitana managed Quickshell system component

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom
import "../../Services" as Services

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property var item: null
    property int groupCount: 1
    property bool groupExpandable: false
    property bool groupCollapsed: false
    property bool groupHeader: false
    readonly property int verticalPadding: 16
    signal toggleGroup

    width: parent ? parent.width : 0
    height: Math.max(84, contentColumn.implicitHeight + verticalPadding * 2)
    radius: 14
    color: hoverHandler.hovered ? Colors.panelButtonBackgroundHover : Colors.panelCardBackground
    border.color: Colors.panelBorder
    border.width: 1

    HoverHandler { id: hoverHandler }

    Rectangle {
        id: appIcon

        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 42
        height: 42
        radius: 21
        color: Services.NotificationService.toneBackground(root.item)

        Controls.Icon {
            anchors.centerIn: parent
            name: "notifications.on"
            color: Services.NotificationService.toneForeground(root.item)
            size: 20
        }
    }

    ColumnLayout {
        id: contentColumn

        anchors.left: appIcon.right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: root.item ? root.item.appName : "app"
                color: Colors.mutedForeground
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 1
                font.weight: Font.Bold
            }

            Text {
                text: root.item ? Services.NotificationService.timeAgo(root.item.time) : "now"
                color: Colors.mutedForeground
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize - 1
                font.weight: Font.DemiBold
            }

            Rectangle {
                visible: root.groupExpandable && root.groupHeader
                Layout.preferredWidth: countRow.implicitWidth + 14
                Layout.preferredHeight: 22
                radius: 11
                color: countMouse.containsMouse ? Colors.panelButtonBackgroundHover : Colors.panelButtonBackground

                Row {
                    id: countRow

                    anchors.centerIn: parent
                    spacing: 3

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.groupCount
                        color: Colors.primaryForeground
                        font.family: Typography.fontFamily
                        font.pixelSize: settings.textPixelSize - 1
                        font.weight: Font.Bold
                    }

                    Controls.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: root.groupCollapsed ? "ui.chevron.down" : "ui.chevron.up"
                        tone: "primary"
                        size: 12
                    }
                }

                MouseArea {
                    id: countMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleGroup()
                }
            }

            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 22
                radius: 11
                color: dismissMouse.containsMouse ? Colors.panelButtonBackgroundHover : Colors.panelButtonBackground

                Controls.Icon {
                    anchors.centerIn: parent
                    name: "ui.close"
                    tone: dismissMouse.containsMouse ? "primary" : "muted"
                    size: 13
                }

                MouseArea {
                    id: dismissMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.NotificationService.dismiss(root.item)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Colors.panelContainerBackground
        }

        Text {
            Layout.fillWidth: true
            text: root.item ? Services.NotificationService.escapeMarkup(root.item.summary) : "Notification"
            color: Colors.primaryForeground
            elide: Text.ElideRight
            clip: true
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize + 1
            font.weight: Font.Bold
            textFormat: Text.RichText
        }

        Text {
            id: bodyText
            Layout.fillWidth: true
            visible: text.length > 0
            text: root.item ? root.item.bodyMarkup : ""
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
}
