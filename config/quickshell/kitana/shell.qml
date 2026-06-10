// Kitana managed Quickshell bar
//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import "./Bar" as Bar
import "./Dashboard" as Dashboard
import "./Launcher" as Launcher
import "./Shortcuts" as Shortcuts
import "./Wallpaper" as Wallpaper
import "./Services" as Services

ShellRoot {
    id: root

    property bool barVisible: true
    readonly property var sharedDashboardPanel: dashboardPanel
    readonly property var sharedShortcutsPanel: shortcutsPanel

    Wallpaper.WallpaperGrid {}
    Launcher.AppLauncher {}

    Dashboard.DashboardPanel {
        id: dashboardPanel
    }

    Shortcuts.ShortcutsPanel {
        id: shortcutsPanel
    }

    IpcHandler {
        target: "kitana-osd"

        function display(payload: string): void {
            Services.OsdService.showPayload(payload);
        }
    }

    IpcHandler {
        target: "kitana-notifications"

        function dismissLast(): void { Services.NotificationService.dismissLast(); }
        function clear(): void { Services.NotificationService.clear(); }
    }

    IpcHandler {
        target: "kitana-bar"

        function show(): void { root.barVisible = true; }
        function hide(): void { root.barVisible = false; }
        function toggle(): void { root.barVisible = !root.barVisible; }
    }

    Variants {
        model: Quickshell.screens

        Bar.BarWindow {
            required property var modelData
            panelScreen: modelData
            barVisible: root.barVisible
            dashboardPanel: root.sharedDashboardPanel
            shortcutsPanel: root.sharedShortcutsPanel
        }
    }
}
