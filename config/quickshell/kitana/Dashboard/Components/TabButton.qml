// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../Components/Controls" as Controls
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings {
        id: settings
    }

    property var dashboard: null
    property string iconName: Icons.defaultIcon
    property string label: ""
    property string tab: ""
    property bool compact: false
    readonly property bool selected: dashboard && dashboard.activeTab === tab

    Layout.preferredWidth: compact ? 34 : tabContent.implicitWidth + 22
    Layout.preferredHeight: 34
    radius: 10
    color: selected ? Colors.subtleAccent : (tabMouse.containsMouse ? Colors.bgTertiary : "transparent")
    // border.color: selected ? Colors.borderAccent : "transparent"
    // border.width: 1

    // Tab icon and label row
    Row {
        id: tabContent
        anchors.centerIn: parent
        spacing: 7

        Controls.Icon {
            height: root.height
            name: root.iconName
            tone: root.selected ? "accent" : "primary"
            sizeRole: "bar"
        }

        Text {
            height: root.height
            text: root.label
            visible: !root.compact
            color: Colors.fgPrimary
            verticalAlignment: Text.AlignVCenter
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.DemiBold
        }
    }

    // Tab selection click target
    MouseArea {
        id: tabMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (!root.dashboard)
                return;
            if (root.dashboard.activeTab !== root.tab)
                root.dashboard.resetPickerState();
            root.dashboard.activeTab = root.tab;
            root.dashboard.refreshTab();
        }
    }
}
