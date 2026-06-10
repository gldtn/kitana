// Kitana managed Quickshell dashboard component

import QtQuick
import QtQuick.Layouts
import "../.."
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    property var dashboard: null
    property string icon: ""
    property string label: ""
    property string tab: ""
    property bool compact: false
    readonly property bool selected: dashboard && dashboard.activeTab === tab

    Layout.preferredWidth: compact ? 34 : tabContent.implicitWidth + 22
    Layout.preferredHeight: 34
    radius: 10
    color: selected ? Colors.surfaceHighlight : (tabMouse.containsMouse ? Colors.surfaceHover : "transparent")
    border.color: selected ? Colors.panelBorderStrong : "transparent"
    border.width: 1

    Row {
        id: tabContent
        anchors.centerIn: parent
        spacing: 7

        Text {
            height: root.height
            text: root.icon
            color: root.selected ? Colors.accent : Colors.foreground
            verticalAlignment: Text.AlignVCenter
            font.family: settings.fontFamily
            font.pixelSize: settings.iconPixelSize
        }

        Text {
            height: root.height
            text: root.label
            visible: !root.compact
            color: Colors.foreground
            verticalAlignment: Text.AlignVCenter
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.DemiBold
        }
    }

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
