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

    Column {
        anchors.centerIn: parent
        visible: Services.NotificationService.count === 0
        spacing: 10

        Controls.Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: Icons.notifications
            color: Colors.muted
            size: 30
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "0 Notifications"
            color: Colors.muted
            horizontalAlignment: Text.AlignHCenter
            font.family: Typography.fontFamily
            font.pixelSize: 20
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10
        visible: Services.NotificationService.count > 0

        Row {
            width: parent.width
            height: 24

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - clearNotifications.width
                text: Services.NotificationService.count + " Notifications"
                color: Colors.foreground
                font.family: Typography.fontFamily
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            Controls.Icon {
                id: clearNotifications
                anchors.verticalCenter: parent.verticalCenter
                icon: Icons.close
                color: Colors.foreground
                size: 15

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.NotificationService.clear()
                }
            }
        }

        Repeater {
            model: Services.NotificationService.notifications.slice(0, 5)

            NotificationRow {
                required property var modelData
                item: modelData
            }
        }
    }
}
