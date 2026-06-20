// Kitana managed Quickshell dashboard island

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../Bar/Sections" as BarSections
import "../Services" as Services

// qmllint disable uncreatable-type
PanelWindow {
    id: root
    // qmllint enable uncreatable-type

    property var panelScreen: null
    property var dashboardPanel: null
    property bool barVisible: true
    readonly property string screenName: panelScreen && panelScreen.name ? panelScreen.name : ""
    readonly property string focusedScreenName: dashboardPanel && dashboardPanel.focusedScreen ? dashboardPanel.focusedScreen.name : ""
    readonly property string dashboardScreenName: dashboardPanel && dashboardPanel.panelScreen ? dashboardPanel.panelScreen.name : ""
    readonly property bool focusedScreen: focusedScreenName.length > 0 && focusedScreenName === screenName
    readonly property bool lastDashboardScreen: dashboardScreenName.length > 0 && dashboardScreenName === screenName
    readonly property bool fallbackScreen: focusedScreenName.length === 0 && dashboardPanel && dashboardPanel.fallbackScreen === panelScreen
    readonly property bool activeScreen: dashboardPanel !== null && (focusedScreen || (!dashboardPanel.expandedSurface && lastDashboardScreen) || fallbackScreen)
    readonly property bool hiddenByDashboard: dashboardPanel !== null && dashboardPanel.expandedSurface && dashboardScreenName === screenName
    readonly property var hyprlandMonitor: panelScreen ? Hyprland.monitorFor(panelScreen) : null
    readonly property var activeWorkspace: hyprlandMonitor !== null ? hyprlandMonitor.activeWorkspace : null
    readonly property bool hiddenByFullscreen: activeWorkspace !== null && activeWorkspace.hasFullscreen && hasTrueFullscreen(activeWorkspace)
    readonly property bool latchedHover: activeScreen && dashboardPanel !== null && dashboardPanel.compactHoverLatched && lastDashboardScreen
    readonly property int islandWidth: Math.round(islandContent.implicitWidth)
    readonly property int islandHeight: Math.round(islandContent.implicitHeight)
    readonly property int islandX: Math.max(0, Math.round(((panelScreen ? panelScreen.width : 1920) - islandWidth) / 2))
    readonly property int islandY: Math.max(0, Math.round(Services.UiPreferences.topMargin + (Services.UiPreferences.panelHeight - islandHeight) / 2))

    function toggleDashboard(): void {
        if (dashboardPanel && activeScreen) {
            dashboardPanel.setCompactHoverLatched(true);
            dashboardPanel.toggle("datetime", panelScreen, islandX, islandY, islandWidth, islandHeight);
        }
    }

    function syncHoverState(hovered: bool): void {
        if (dashboardPanel && activeScreen && !hiddenByDashboard)
            dashboardPanel.setCompactHoverLatched(hovered);
    }

    function hasTrueFullscreen(workspace): bool {
        const toplevels = workspace && workspace.toplevels ? workspace.toplevels.values : [];

        for (const toplevel of toplevels) {
            const ipc = toplevel && toplevel.lastIpcObject ? toplevel.lastIpcObject : null;
            if (ipc === null)
                continue;

            // Hyprland mode 1 is maximized; mode 2 is true fullscreen.
            const mode = typeof ipc.fullscreen !== "undefined" ? Number(ipc.fullscreen) : Number(ipc.fullscreenClient);
            if (mode === 2)
                return true;
        }

        return false;
    }

    Connections {
        target: Hyprland

        function onRawEvent(event): void {
            if (event.name === "fullscreen" || event.name === "fullscreenmode")
                Hyprland.refreshToplevels();
        }
    }

    screen: panelScreen
    visible: barVisible && !hiddenByFullscreen
    focusable: false
    implicitWidth: islandWidth
    implicitHeight: islandHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-panel"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
    }

    // qmllint disable unqualified unresolved-type
    margins.top: islandY
    margins.left: islandX
    // qmllint enable unqualified unresolved-type

    // Per-monitor collapsed island content
    BarSections.Center {
        id: islandContent

        anchors.fill: parent
        embedded: false
        interactive: root.activeScreen
        hovered: islandMouse.containsMouse || root.latchedHover
        hideWhenDashboardActive: false
        dashboardPanel: root.dashboardPanel
        panelScreen: root.panelScreen
        sourceX: root.islandX
        sourceY: root.islandY
        opacity: root.hiddenByDashboard ? 0 : 1
        visible: opacity > 0
    }

    // The surface stays mapped so clicks work without moving the pointer after close.
    MouseArea {
        id: islandMouse

        anchors.fill: parent
        enabled: root.activeScreen
        hoverEnabled: true
        cursorShape: root.activeScreen ? Qt.PointingHandCursor : Qt.ArrowCursor
        onContainsMouseChanged: root.syncHoverState(containsMouse)
        onClicked: root.toggleDashboard()
    }
}
