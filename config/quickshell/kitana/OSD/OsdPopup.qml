// Kitana managed Quickshell module

import QtQuick
import QtQuick.Layouts
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

    implicitWidth: 330
    implicitHeight: 70

    Rectangle {
        id: card

        width: root.implicitWidth
        height: root.implicitHeight
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 20
        color: Colors.popupBackground
        border.color: Colors.popupBorder
        border.width: 1
        opacity: Services.OsdService.visible ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 22
            anchors.rightMargin: 22
            anchors.topMargin: 16
            anchors.bottomMargin: 16
            spacing: 16

            Item {
                readonly property real iconVisualOffset: {
                    if (Services.OsdService.kind !== "volume")
                        return 0;
                    return 2;
                }

                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                Layout.alignment: Qt.AlignVCenter

                Controls.Icon {
                    anchors.left: parent.left
                    anchors.leftMargin: parent.iconVisualOffset
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: parent.height
                    name: Services.OsdService.iconName
                    tone: Services.OsdService.muted ? "muted" : "primary"
                    size: 25
                    horizontalAlignment: Text.AlignLeft
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 7
                Layout.alignment: Qt.AlignVCenter
                radius: 4
                color: Colors.popupSurface

                Rectangle {
                    width: parent.width * Services.OsdService.value / 100
                    height: parent.height
                    radius: parent.radius
                    color: Services.OsdService.muted ? Colors.popupForegroundMuted : Colors.accent

                    Behavior on width {
                        NumberAnimation { duration: 90; easing.type: Easing.OutCubic }
                    }
                }
            }

            Text {
                Layout.preferredWidth: 42
                Layout.alignment: Qt.AlignVCenter
                text: Services.OsdService.muted ? "--" : Services.OsdService.value
                color: Services.OsdService.muted ? Colors.popupForegroundMuted : Colors.popupForeground
                horizontalAlignment: Text.AlignRight
                font.family: Typography.fontFamily
                font.pixelSize: 24
                font.weight: Font.DemiBold
            }
        }
    }
}
