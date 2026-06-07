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
    visible: Services.OsdService.visible
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        bottom: true
        left: true
        right: true
    }

    margins {
        bottom: 76
        left: settings.sideMargin
        right: settings.sideMargin
    }

    implicitWidth: 280
    implicitHeight: 92

    Rectangle {
        id: card

        width: root.implicitWidth
        height: root.implicitHeight
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 18
        color: Colors.panelBackground
        border.color: Colors.panelBorder
        border.width: 1
        opacity: Services.OsdService.visible ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        Row {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            Text {
                width: 34
                anchors.verticalCenter: parent.verticalCenter
                text: Services.OsdService.icon
                color: Services.OsdService.muted ? Colors.muted : Colors.foreground
                horizontalAlignment: Text.AlignHCenter
                font.family: settings.fontFamily
                font.pixelSize: 24
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 48
                spacing: 9

                Row {
                    width: parent.width
                    spacing: 8

                    Text {
                        width: parent.width - valueText.width - parent.spacing
                        text: Services.OsdService.title
                        color: Colors.foreground
                        elide: Text.ElideRight
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize + 1
                        font.weight: Font.Bold
                    }

                    Text {
                        id: valueText

                        text: Services.OsdService.muted ? "muted" : Services.OsdService.value + "%"
                        color: Services.OsdService.muted ? Colors.muted : Colors.accent
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize + 1
                        font.weight: Font.Bold
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 8
                    radius: 4
                    color: Colors.panelButtonBackground

                    Rectangle {
                        width: parent.width * Services.OsdService.value / 100
                        height: parent.height
                        radius: parent.radius
                        color: Services.OsdService.muted ? Colors.muted : Colors.accent

                        Behavior on width {
                            NumberAnimation { duration: 90; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }
        }
    }
}
