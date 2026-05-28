// Kitana managed Quickshell module

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import ".."
import "../custom" as Custom

Rectangle {
    id: root

    Custom.Settings {
        id: settings
    }

    required property var panelScreen
    property var workspaceSets: [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]]

    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
    Layout.preferredHeight: settings.pillHeight
    Layout.preferredWidth: workspaceRow.implicitWidth + settings.workspaceHorizontalPadding

    radius: height / settings.radiusDivisor
    color: Colors.background
    border.color: Colors.surfaceAlt
    border.width: settings.borderWidth

    function range(start, end) {
        const workspaces = [];
        for (let workspace = start; workspace <= end; workspace++)
            workspaces.push(workspace);
        return workspaces;
    }

    function screenIndex(screen) {
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i] === screen)
                return i;
        }
        return 0;
    }

    function screenName(screen) {
        return screen && screen.name ? screen.name : "";
    }

    function workspacesFor(screen) {
        const index = screenIndex(screen);
        const configured = Quickshell.screens.length === 1 ? range(1, 10) : workspaceSets[Math.min(index, workspaceSets.length - 1)];
        const activeWorkspace = Hyprland.workspaces.values.find(workspace => workspace.active);

        if (Quickshell.screens.length === 1 && activeWorkspace && activeWorkspace.id > 0 && configured.indexOf(activeWorkspace.id) === -1) {
            return [activeWorkspace.id].concat(configured);
        }

        return configured;
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: Hyprland.refreshWorkspaces()
    }

    Process {
        id: workspaceSwitch
    }

    Row {
        id: workspaceRow

        anchors.centerIn: parent
        spacing: settings.workspaceSpacing

        Repeater {
            model: root.workspacesFor(root.panelScreen)

            Rectangle {
                id: workspacePill

                property int workspaceId: modelData
                property bool active: Hyprland.workspaces.values.some(workspace => workspace.id === workspaceId && workspace.active)
                property bool occupied: Hyprland.workspaces.values.some(workspace => workspace.id === workspaceId && workspace.toplevels.values.length > 0)

                width: active ? settings.workspaceActiveWidth : settings.workspaceInactiveWidth
                height: settings.workspacePillHeight
                radius: height / settings.radiusDivisor
                color: active ? Colors.accent : (occupied ? Colors.surfaceAlt : Colors.surface)

                Text {
                    anchors.centerIn: parent
                    text: workspacePill.workspaceId
                    color: workspacePill.active ? Colors.accentText : Colors.foreground
                    font.family: settings.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: workspaceSwitch.exec(["sh", "-c", "monitor=$1; workspace=$2; [ -n \"$monitor\" ] && hyprctl dispatch focusmonitor \"$monitor\" >/dev/null 2>&1 || true; hyprctl dispatch \"hl.dsp.focus({ workspace = $workspace })\" >/dev/null 2>&1 || hyprctl dispatch workspace \"$workspace\" >/dev/null 2>&1", "kitana-workspace", root.screenName(root.panelScreen), String(workspacePill.workspaceId)])
                }
            }
        }
    }
}
