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
import "./Screenshot" as Screenshot
import "./Session" as Session
import "./Settings" as Settings
import "./Shortcuts" as Shortcuts
import "./Theme" as Theme
import "./Wallpaper" as Wallpaper
import "./Services" as Services

ShellRoot {
    id: root

    property bool barVisible: true
    readonly property var sharedScreenshotPanel: screenshotPanel
    readonly property var sharedSettingsPanel: settingsPanel
    readonly property var sharedShortcutsPanel: shortcutsPanel

    // Global wallpaper picker panel
    Wallpaper.WallpaperGrid {}

    // Global application launcher panel
    Launcher.AppLauncher {}

    // Shared dashboard panel opened from the clock
    Dashboard.DashboardPanel {
        id: dashboardPanel

        fallbackScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    }

    // Shared screenshot panel opened from bar and IPC
    Screenshot.ScreenshotPanel {
        id: screenshotPanel
    }

    // Global power/session action panel
    Session.SessionPanel {}

    // Shared Kitana settings panel
    Settings.SettingsPanel {
        id: settingsPanel
    }

    // Shared Hyprland shortcuts panel
    Shortcuts.ShortcutsPanel {
        id: shortcutsPanel
    }

    // Toggleable live theme preview for palette tuning
    Theme.ThemePreview {}

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

    // Per-monitor dashboard islands
    Variants {
        model: Quickshell.screens

        // Collapsed dashboard island for one output
        Dashboard.IslandWindow {
            required property var modelData
            panelScreen: modelData
            barVisible: root.barVisible
            dashboardPanel: dashboardPanel
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
        }
    }
}
