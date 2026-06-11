// Kitana managed Quickshell bar
//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import "./Bar" as Bar
import "./Dashboard" as Dashboard
import "./Launcher" as Launcher
import "./Screenshot" as Screenshot
import "./Shortcuts" as Shortcuts
import "./Wallpaper" as Wallpaper
import "./Services" as Services

ShellRoot {
    id: root

    property bool barVisible: true
    readonly property var sharedDashboardPanel: dashboardPanel
    readonly property var sharedScreenshotPanel: screenshotPanel
    readonly property var sharedShortcutsPanel: shortcutsPanel

    Wallpaper.WallpaperGrid {}
    Launcher.AppLauncher {}

    Dashboard.DashboardPanel {
        id: dashboardPanel
    }

    Screenshot.ScreenshotPanel {
        id: screenshotPanel
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

    IpcHandler {
        target: "kitana-shell"

        function reload(): void { Quickshell.reload(false); }
        function hardReload(): void { Quickshell.reload(true); }
    }

    IpcHandler {
        target: "kitana-screenshot"

        function open(): void { screenshotPanel.open(); }
        function close(): void { screenshotPanel.close(); }
        function toggle(): void { screenshotPanel.toggle(); }
    }

    Variants {
        model: Quickshell.screens

        Bar.BarWindow {
            required property var modelData
            panelScreen: modelData
            barVisible: root.barVisible
            dashboardPanel: root.sharedDashboardPanel
            screenshotPanel: root.sharedScreenshotPanel
            shortcutsPanel: root.sharedShortcutsPanel
        }
    }
}
