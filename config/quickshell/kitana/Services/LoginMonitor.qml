// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"
    readonly property string helper: kitanaDir + "/bin/kitana-sddm-monitor"

    property var monitors: []
    property string selector: ""
    property string deployedSelector: ""
    property bool cacheWritable: false
    property string statusText: "Loading monitors..."

    readonly property bool refreshing: refreshProcess.running
    readonly property bool saving: saveProcess.running

    function refresh(): void {
        if (refreshProcess.running)
            return;

        statusText = "Loading monitors...";
        refreshProcess.exec([helper, "--json"]);
    }

    function setSelector(value: string): void {
        if (saveProcess.running)
            return;

        const selected = value || "";
        statusText = selected.length > 0 ? "Saving login monitor..." : "Clearing login monitor...";
        saveProcess.exec(selected.length > 0 ? [helper, "--set", selected] : [helper, "--clear"]);
    }

    function selectorMatches(monitor: var): bool {
        if (!monitor)
            return false;

        const selected = selector || "";
        if (selected.length === 0)
            return false;

        return selected === (monitor.selector || "") || selected === (monitor.name || "") || selected === (monitor.description ? "desc:" + monitor.description : "");
    }

    function monitorSubtitle(monitor: var): string {
        if (!monitor)
            return "Hyprland output";

        const description = monitor.description || monitor.selector || "Hyprland output";
        return selectorMatches(monitor) ? "Selected for SDDM login" : description;
    }

    function parseMonitorJson(text: string): void {
        try {
            const data = JSON.parse(text.trim() || "{}");
            monitors = data.monitors || [];
            selector = data.selector || "";
            deployedSelector = data.deployedSelector || "";
            cacheWritable = !!data.cacheWritable;
            statusText = monitors.length > 0 ? (cacheWritable ? "" : "Run kitana-refresh --sddm once to deploy login monitor changes") : "No Hyprland monitors detected";
        } catch (error) {
            monitors = [];
            statusText = "Could not read monitor list";
        }
    }

    // Detected monitor list command runner
    Process {
        id: refreshProcess

        stdout: StdioCollector {
            onStreamFinished: root.parseMonitorJson(text)
        }
    }

    // Login monitor preference writer
    Process {
        id: saveProcess

        onRunningChanged: if (!running) root.refresh()
    }

    Component.onCompleted: refresh()
}
