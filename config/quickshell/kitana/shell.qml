// Kitana managed Quickshell bar
//@ pragma UseQApplication

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "./Bar" as Bar
import "./Dashboard" as Dashboard
import "./Launcher" as Launcher
import "./Polkit" as Polkit
import "./Screenshot" as Screenshot
import "./Session" as Session
import "./Settings" as Settings
import "./Shortcuts" as Shortcuts
import "./System" as System
import "./Theme" as Theme
import "./Services" as Services

ShellRoot {
    id: root

    property bool barVisible: true
    readonly property var sharedScreenshotPanel: screenshotPanel
    readonly property var sharedSettingsPanel: settingsPanel
    readonly property var sharedShortcutsPanel: shortcutsPanel
    readonly property var focusedScreen: screenForMonitor(Hyprland.focusedMonitor)
    readonly property var sharedThemePreview: themePreview

    function screenForMonitor(monitor: var): var {
        if (!monitor || !monitor.name)
            return null;
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === monitor.name)
                return Quickshell.screens[i];
        }
        return null;
    }

    function dashboardPanelForScreen(screen: var): var {
        if (!screen || !screen.name)
            return null;
        for (let i = 0; i < dashboardPanels.instances.length; i++) {
            const panel = dashboardPanels.instances[i];
            if (panel && panel.panelScreen && panel.panelScreen.name === screen.name)
                return panel;
        }
        return null;
    }

    function focusedDashboardPanel(): var {
        return dashboardPanelForScreen(root.focusedScreen) || (dashboardPanels.instances.length > 0 ? dashboardPanels.instances[0] : null);
    }

    function closeDashboardPanels(exceptPanel: var): void {
        for (let i = 0; i < dashboardPanels.instances.length; i++) {
            const panel = dashboardPanels.instances[i];
            if (panel && panel !== exceptPanel)
                panel.close();
        }
    }

    // Global application launcher panel
    Launcher.AppLauncher {}

    // Shared screenshot panel opened from bar and IPC
    Screenshot.ScreenshotPanel {
        id: screenshotPanel
    }

    // Shared control panel opened from global shortcuts and IPC
    System.ControlPanel {
        id: controlPanel

        panelScreen: root.focusedScreen || (Quickshell.screens.length > 0 ? Quickshell.screens[0] : null)
    }

    // Global power/session action panel
    Session.SessionPanel {}

    // Shared Kitana settings panel
    Settings.SettingsPanel {
        id: settingsPanel
    }

    // Opt-in native Polkit authentication prompt
    LazyLoader {
        active: Services.PolkitService.enabled

        Polkit.PolkitPanel {
            panelScreen: root.focusedScreen || (Quickshell.screens.length > 0 ? Quickshell.screens[0] : null)
        }
    }

    // Shared Hyprland shortcuts panel
    Shortcuts.ShortcutsPanel {
        id: shortcutsPanel
    }

    // Toggleable live theme preview for palette tuning
    Theme.ThemePreview {
        id: themePreview
    }

    // OSD command bridge
    IpcHandler {
        target: "kitana-osd"

        function display(payload: string): void {
            Services.OsdService.showPayload(payload);
        }
    }

    // Notification command bridge
    IpcHandler {
        target: "kitana-notifications"

        function dismissLast(): void {
            Services.NotificationService.dismissLast();
        }
        function clear(): void {
            Services.NotificationService.clear();
        }
    }

    // Bar visibility command bridge
    IpcHandler {
        target: "kitana-bar"

        function show(): void {
            root.barVisible = true;
        }
        function hide(): void {
            root.barVisible = false;
        }
        function toggle(): void {
            root.barVisible = !root.barVisible;
        }
    }

    // Shell lifecycle command bridge
    IpcHandler {
        target: "kitana-shell"

        function refreshWorkspaces(): void {
            Hyprland.refreshWorkspaces();
        }
        function reload(): void {
            Quickshell.reload(false);
        }
        function hardReload(): void {
            Quickshell.reload(true);
        }
    }

    // Screenshot panel command bridge
    IpcHandler {
        target: "kitana-screenshot"

        function open(): void {
            screenshotPanel.open();
        }
        function close(): void {
            screenshotPanel.close();
        }
        function toggle(): void {
            screenshotPanel.toggle();
        }
    }

    // Control panel command bridge
    IpcHandler {
        target: "kitana-control-panel"

        function open(section: string): void {
            controlPanel.open(section || "notifications");
        }
        function close(): void {
            controlPanel.close();
        }
        function toggle(section: string): void {
            controlPanel.toggle(section || "notifications");
        }
    }

    // Dashboard command bridge routed to the focused monitor.
    IpcHandler {
        target: "kitana-dashboard"

        function open(tab: string): void {
            const panel = root.focusedDashboardPanel();
            if (panel)
                panel.open(tab || "datetime");
        }
        function close(): void {
            root.closeDashboardPanels(null);
        }
        function toggle(tab: string): void {
            const panel = root.focusedDashboardPanel();
            if (panel)
                panel.toggle(tab || "datetime");
        }
    }

    // Per-monitor dashboard islands and expandable cards
    Variants {
        id: dashboardPanels

        model: Quickshell.screens

        // One masked surface owns both collapsed and expanded states for one output.
        Dashboard.DashboardPanel {
            required property var modelData

            panelScreen: modelData
            barVisible: root.barVisible
            fallbackScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
            onOpeningRequested: panel => root.closeDashboardPanels(panel)
        }
    }

    // Per-monitor bar windows
    Variants {
        model: Quickshell.screens

        // Bar instance for one output
        Bar.BarWindow {
            required property var modelData
            panelScreen: modelData
            barVisible: root.barVisible
            screenshotPanel: root.sharedScreenshotPanel
            settingsPanel: root.sharedSettingsPanel
            shortcutsPanel: root.sharedShortcutsPanel
            themePreview: root.sharedThemePreview
        }
    }
}
