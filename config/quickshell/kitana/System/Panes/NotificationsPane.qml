// Kitana managed Quickshell system pane

pragma ComponentBehavior: Bound

import QtQuick
import "../.."
import "../Components"
import "../../Components/Controls" as Controls
import "../../custom" as Custom
import "../../Services" as Services

Item {
    id: root

    Custom.Settings {
        id: settings
    }

    // Notification list and footer container
    Item {
        anchors.fill: parent

        // Empty notifications message
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
                color: Colors.fgSecondary
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: 18
                font.weight: Font.DemiBold
            }
        }

        // Notification rows list
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
            model: Services.NotificationService.visibleNotificationGroups().slice(0, 20)

            // One notification group delegate
            delegate: Item {
                id: groupDelegate

                required property var modelData
                readonly property bool expandedGroup: modelData.items.length > 1 && !modelData.collapsed

                width: notificationList.width
                height: expandedGroup ? groupCard.height : singleRow.height

                NotificationRow {
                    id: singleRow

                    visible: !groupDelegate.expandedGroup
                    item: groupDelegate.modelData.item
                    groupCount: groupDelegate.modelData.count
                    groupExpandable: groupDelegate.modelData.expandable
                    groupCollapsed: groupDelegate.modelData.collapsed
                    groupHeader: true
                    onToggleGroup: Services.NotificationService.toggleGroup(groupDelegate.modelData.appName)
                }

                // Expanded app notification group
                Rectangle {
                    id: groupCard

                    visible: groupDelegate.expandedGroup
                    width: parent.width
                    height: visible ? groupColumn.implicitHeight : 0
                    radius: 14
                    color: Colors.bgSecondary
                    border.color: Colors.borderLight
                    border.width: 0

                    // Grouped notification rows
                    Column {
                        id: groupColumn

                        width: parent.width
                        spacing: 3

                        Repeater {
                            model: groupDelegate.modelData.items

                            // One row inside an expanded notification group
                            delegate: Column {
                                id: groupedRow

                                required property int index
                                required property var modelData

                                width: groupColumn.width

                                NotificationRow {
                                    embedded: true
                                    embeddedIndex: groupedRow.index
                                    embeddedCount: groupDelegate.modelData.items.length
                                    item: groupedRow.modelData
                                    groupCount: groupDelegate.modelData.count
                                    groupExpandable: groupDelegate.modelData.expandable
                                    groupCollapsed: false
                                    groupHeader: groupedRow.index === 0
                                    onToggleGroup: Services.NotificationService.toggleGroup(groupDelegate.modelData.appName)
                                }
                            }
                        }
                    }
                }
            }
        }

        // Footer divider
        Rectangle {
            id: footerDivider

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: footer.top
            anchors.bottomMargin: 10
            height: 1
            color: Colors.borderFaint
        }

        // Notification footer actions
        Row {
            id: footer

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 30
            spacing: 12

            // Notification count label
            Text {
                width: parent.width - silentAction.width - clearAction.width - parent.spacing * 2
                anchors.verticalCenter: parent.verticalCenter
                text: Services.NotificationService.count + " notification" + (Services.NotificationService.count === 1 ? "" : "s")
                color: Colors.fgPrimary
                elide: Text.ElideRight
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 2
                font.weight: Font.DemiBold
            }

            // Do not disturb footer action
            FooterAction {
                id: silentAction
                iconName: Services.NotificationService.doNotDisturb ? "notifications.off" : "notifications.on"
                text: "Silent"
                active: Services.NotificationService.doNotDisturb
                onClicked: Services.NotificationService.toggleDoNotDisturb()
            }

            // Clear notifications footer action
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

    // Reusable footer action button
    component FooterAction: Item {
        id: action

        property string iconName: Icons.defaultIcon
        property string text: ""
        property bool active: false
        signal clicked

        width: actionRow.implicitWidth
        height: 30

        // Footer action icon and label
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
                color: action.active || actionMouse.containsMouse ? Colors.fgPrimary : Colors.fgSecondary
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize + 1
                font.weight: Font.DemiBold
            }
        }

        // Footer action click target
        MouseArea {
            id: actionMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: action.clicked()
        }
    }
}
