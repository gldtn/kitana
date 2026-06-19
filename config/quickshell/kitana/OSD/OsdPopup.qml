// Kitana managed Quickshell module

import QtQuick
import QtQuick.Layouts
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
    visible: Services.OsdService.visible
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-panel"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        bottom: true
        left: true
        right: true
    }

    // qmllint disable unqualified unresolved-type
    margins.bottom: 76
    margins.left: settings.sideMargin
    margins.right: settings.sideMargin
    // qmllint enable unqualified unresolved-type

    implicitWidth: 330
    implicitHeight: 70

    // OSD popup card
    Rectangle {
        id: card

        width: root.implicitWidth
        height: root.implicitHeight
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 20
        color: Colors.bgSecondary
        border.color: Colors.borderFaint
        border.width: 1
        opacity: Services.OsdService.visible ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        // OSD icon, meter, and value row
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 22
            anchors.rightMargin: 22
            anchors.topMargin: 16
            anchors.bottomMargin: 16
            spacing: 16

            // OSD icon slot
            Item {
                readonly property real iconVisualOffset: {
                    if (Services.OsdService.kind !== "volume")
                        return 0;
                    return 2;
                }

                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                Layout.alignment: Qt.AlignVCenter

                // OSD status icon
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

            // OSD value track
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 7
                Layout.alignment: Qt.AlignVCenter
                radius: 4
                color: Colors.bgTertiary

                // OSD filled value bar
                Rectangle {
                    width: parent.width * Services.OsdService.value / 100
                    height: parent.height
                    radius: parent.radius
                    color: Services.OsdService.muted ? Colors.fgSecondary : Colors.fgAccent

                    Behavior on width {
                        NumberAnimation { duration: 90; easing.type: Easing.OutCubic }
                    }
                }
            }

            // OSD numeric value label
            Text {
                Layout.preferredWidth: 42
                Layout.alignment: Qt.AlignVCenter
                text: Services.OsdService.muted ? "--" : Services.OsdService.value
                color: Services.OsdService.muted ? Colors.fgSecondary : Colors.fgPrimary
                horizontalAlignment: Text.AlignRight
                font.family: Typography.fontFamily
                font.pixelSize: 24
                font.weight: Font.DemiBold
            }
        }
    }
}
