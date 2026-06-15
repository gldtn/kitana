// Kitana managed Quickshell module

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../.."
import "../../Components/Controls" as Controls
import "../../Services" as Services
import "../../custom" as Custom

Rectangle {
    id: root

    Custom.Settings { id: settings }

    readonly property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"
    readonly property string helper: kitanaDir + "/bin/kitana-hyprland-workspace-layout-toggle"
    readonly property var activeWorkspace: Hyprland.focusedWorkspace || Hyprland.workspaces.values.find(workspace => workspace.active)
    readonly property var workspaceIpc: activeWorkspace && activeWorkspace.lastIpcObject ? activeWorkspace.lastIpcObject : ({})
    readonly property string currentLayout: normalizeLayout(workspaceIpc.tiledLayout || "dwindle")
    readonly property string displayMode: Services.UiPreferences.layoutPillDisplayMode

    implicitHeight: settings.pillHeight
    implicitWidth: content.implicitWidth + 18
    width: implicitWidth
    height: implicitHeight

    radius: height / settings.radiusDivisor
    color: Colors.barBackground
    border.color: Colors.barBorder
    border.width: settings.borderWidth

    function normalizeLayout(layout: string): string {
        return layout === "scrolling" ? "scrolling" : "dwindle";
    }

    function compactLabel(layout: string): string {
        return layout === "scrolling" ? "SCR" : "DWL";
    }

    function fullLabel(layout: string): string {
        return layout === "scrolling" ? "Scrolling" : "Dwindle";
    }

    function visibleLabel(layout: string): string {
        if (displayMode === "full")
            return fullLabel(layout);
        if (displayMode === "icons")
            return "";
        return compactLabel(layout);
    }

    function refreshWorkspaces(): void {
        Hyprland.refreshWorkspaces();
    }

    Process {
        id: layoutToggle

        stdout: StdioCollector {
            onStreamFinished: root.refreshWorkspaces()
        }

        onRunningChanged: if (!running) refreshDelay.restart()
    }

    Timer {
        id: refreshDelay
        interval: 120
        repeat: false
        onTriggered: root.refreshWorkspaces()
    }

    Row {
        id: content

        anchors.centerIn: parent
        spacing: displayMode === "icons" ? 0 : 6

        Controls.Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: Icons.workspaceLayoutName(root.currentLayout)
            tone: "accent"
            sizeRole: "bar"
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.visibleLabel(root.currentLayout).length > 0
            text: root.visibleLabel(root.currentLayout)
            color: Colors.barForeground
            font.family: Typography.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (!layoutToggle.running) layoutToggle.exec([root.helper])
    }
}
