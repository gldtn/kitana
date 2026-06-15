// Kitana managed Quickshell system component

import QtQuick
import "../.."
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property var panel: null

    readonly property bool confirming: panel && panel.confirmAction.length > 0

    anchors.fill: parent
    radius: parent ? parent.radius : 0
    color: Colors.scrim
    visible: confirming
    z: 20

    Rectangle {
        width: parent.width - 48
        height: 150
        anchors.centerIn: parent
        radius: 16
        color: Colors.cardBackground
        border.color: Colors.panelBorder
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            Text {
                width: parent.width
                text: root.panel ? root.panel.confirmTitle : ""
                color: Colors.foreground
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: 16
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                text: "Confirm this session action."
                color: Colors.foregroundMuted
                horizontalAlignment: Text.AlignHCenter
                font.family: Typography.fontFamily
                font.pixelSize: settings.textPixelSize
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                ConfirmButton { label: "Cancel"; danger: false; onClicked: if (root.panel) root.panel.confirmAction = "" }
                ConfirmButton { label: "Confirm"; danger: true; onClicked: if (root.panel) root.panel.runConfirmedAction() }
            }
        }
    }
}
