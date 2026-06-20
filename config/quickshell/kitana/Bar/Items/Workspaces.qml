// Kitana managed Quickshell module

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../.."
import "../../Services" as Services
import "../../custom" as Custom

Item {
    id: root

    Custom.Settings {
        id: settings
    }

    required property var panelScreen
    readonly property var defaultWorkspaceSet: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    readonly property int activeWorkspaceId: {
        const activeWorkspace = Hyprland.workspaces.values.find(workspace => workspace.active);
        return activeWorkspace ? activeWorkspace.id : -1;
    }
    readonly property var workspaceStates: {
        const states = ({});
        for (const workspace of Hyprland.workspaces.values) {
            states[workspace.id] = {
                active: workspace.active,
                occupied: workspace.toplevels.values.length > 0,
            };
        }
        return states;
    }
    property var workspaceSets: [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]]
    property bool embedded: false

    implicitHeight: Services.UiPreferences.pillHeight
    implicitWidth: workspaceRow.implicitWidth + settings.workspaceSpacing * 2
    width: implicitWidth
    height: implicitHeight

    // Workspace switcher pill background
    Rectangle {
        anchors.fill: parent
        visible: !root.embedded
        radius: Services.UiPreferences.pillRadius
        color: Colors.barItemBg
        border.color: Colors.barItemBorder
        border.width: settings.borderWidth
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
        const configured = Quickshell.screens.length === 1 ? defaultWorkspaceSet : workspaceSets[Math.min(index, workspaceSets.length - 1)];

        if (Quickshell.screens.length === 1 && activeWorkspaceId > 0 && configured.indexOf(activeWorkspaceId) === -1) {
            return [activeWorkspaceId].concat(configured);
        }

        return configured;
    }

    // Periodic Hyprland workspace refresh
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: Hyprland.refreshWorkspaces()
    }

    // Workspace switch command runner
    Process {
        id: workspaceSwitch
    }

    // Workspace pill row
    Row {
        id: workspaceRow

        anchors.centerIn: parent
        spacing: settings.workspaceSpacing

        // One workspace pill per configured workspace
        Repeater {
            model: root.workspacesFor(root.panelScreen)

            // Clickable workspace indicator
            Rectangle {
                id: workspacePill

                required property int modelData
                readonly property int workspaceId: modelData
                readonly property var workspaceState: root.workspaceStates[workspaceId] || null
                readonly property bool active: workspaceState ? workspaceState.active : false
                readonly property bool occupied: workspaceState ? workspaceState.occupied : false

                width: active ? settings.workspaceActiveWidth : settings.workspaceInactiveWidth
                height: settings.workspacePillHeight
                radius: height / settings.radiusDivisor
                color: active ? Colors.bgAccent : (occupied ? Colors.bgTertiary : Colors.subtleSecondary)

                // Workspace number label
                Text {
                    anchors.centerIn: parent
                    text: workspacePill.workspaceId
                    color: workspacePill.active ? Colors.fgOnPrimary : (workspacePill.occupied ? Colors.fgPrimary : Colors.fgTertiary)
                    font.family: Typography.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.DemiBold
                }

                // Workspace focus click target
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: workspaceSwitch.exec(["sh", "-c", "monitor=$1; workspace=$2; [ -n \"$monitor\" ] && hyprctl dispatch focusmonitor \"$monitor\" >/dev/null 2>&1 || true; hyprctl dispatch \"hl.dsp.focus({ workspace = $workspace })\" >/dev/null 2>&1 || hyprctl dispatch workspace \"$workspace\" >/dev/null 2>&1", "kitana-workspace", root.screenName(root.panelScreen), String(workspacePill.workspaceId)])
                }
            }
        }
    }
}
