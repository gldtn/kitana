// Kitana managed Quickshell system pane

import QtQuick
import "../.."
import "../Components"
import "../../Components/Controls" as Controls
import "../../custom" as Custom
import "../../Services" as Services

Item {
    id: root

    Custom.Settings { id: settings }

    Item {
        anchors.fill: parent

        Column {
            anchors.centerIn: parent
            visible: Services.NotificationService.count === 0
            spacing: 10

            Controls.Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: Services.NotificationService.doNotDisturb ? "notifications.off" : "notifications.on"
                tone: "muted"
                size: 30
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Services.NotificationService.doNotDisturb ? "Notifications silenced" : "No notifications"
                color: Colors.foregroundMuted
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: 18
                font.weight: Font.DemiBold
            }
        }

        ListView {
            id: notificationList

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: footerDivider.top
            anchors.bottomMargin: 12
            visible: Services.NotificationService.count > 0
            clip: true
            spacing: 8
            model: Services.NotificationService.visibleNotifications().slice(0, 20)

            delegate: NotificationRow {
                required property var modelData
                item: modelData.item
                groupCount: modelData.count
                groupExpandable: modelData.expandable
                groupCollapsed: modelData.collapsed
                groupHeader: modelData.header
                onToggleGroup: Services.NotificationService.toggleGroup(modelData.item.appName)
            }
        }

        Rectangle {
            id: footerDivider

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: footer.top
            anchors.bottomMargin: 10
            height: 1
            color: Colors.cardBorder
        }

        Row {
            id: footer

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 30
            spacing: 12

            Text {
                width: parent.width - silentAction.width - clearAction.width - parent.spacing * 2
                anchors.verticalCenter: parent.verticalCenter
                text: Services.NotificationService.count + " notification" + (Services.NotificationService.count === 1 ? "" : "s")
                color: Colors.foreground
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 2
                font.weight: Font.DemiBold
            }

            FooterAction {
                id: silentAction
                iconName: Services.NotificationService.doNotDisturb ? "notifications.off" : "notifications.on"
                text: "Silent"
                active: Services.NotificationService.doNotDisturb
                onClicked: Services.NotificationService.toggleDoNotDisturb()
            }

            FooterAction {
                id: clearAction
                iconName: "notifications.dismiss.all"
                text: "Clear"
                enabled: Services.NotificationService.count > 0
                opacity: enabled ? 1 : 0.45
                onClicked: Services.NotificationService.clear()
            }
        }
    }

    component FooterAction: Item {
        id: action

        property string iconName: Icons.defaultIcon
        property string text: ""
        property bool active: false
        signal clicked

        width: actionRow.implicitWidth
        height: 30

        Row {
            id: actionRow

            anchors.centerIn: parent
            spacing: 6

            Controls.Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: action.iconName
                tone: action.active || actionMouse.containsMouse ? "primary" : "muted"
                size: 14
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: action.text
                color: action.active || actionMouse.containsMouse ? Colors.foreground : Colors.foregroundMuted
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 1
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: actionMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: action.clicked()
        }
    }
}
