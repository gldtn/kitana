// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell
import "../custom" as Custom

Singleton {
    id: root

    Custom.Settings {
        id: defaults
    }

    PersistentProperties {
        id: state
        reloadableId: "kitanaUiPreferences"

        property string layoutPillDisplayMode: "compact"
        property int panelHeight: 0
        property int pillHeight: 0
        property int topMargin: -1
        property int pillRadius: -1
    }

    property alias layoutPillDisplayMode: state.layoutPillDisplayMode
    property alias panelHeightPreference: state.panelHeight
    property alias pillHeightPreference: state.pillHeight
    property alias topMarginPreference: state.topMargin
    property alias pillRadiusPreference: state.pillRadius

    readonly property var layoutPillDisplayModes: ["icons", "compact", "full"]
    readonly property int defaultPanelHeight: defaults.panelHeight > 0 ? defaults.panelHeight : 34
    readonly property int defaultPillHeight: defaults.pillHeight > 0 ? defaults.pillHeight : 32
    readonly property int defaultTopMargin: defaults.topMargin >= 0 ? defaults.topMargin : 4
    readonly property int defaultPillRadius: Math.round(defaultPillHeight / (defaults.radiusDivisor > 0 ? defaults.radiusDivisor : 4))

    readonly property int panelHeight: resolvedInt(state.panelHeight, defaultPanelHeight, 24, 72)
    readonly property int barHeight: panelHeight
    readonly property int exclusiveZone: panelHeight
    readonly property int pillHeight: Math.min(panelHeight, resolvedInt(state.pillHeight, defaultPillHeight, 18, 72))
    readonly property int topMargin: resolvedInt(state.topMargin, defaultTopMargin, 0, 32)
    readonly property int pillRadius: Math.min(Math.round(pillHeight / 2), resolvedInt(state.pillRadius, defaultPillRadius, 0, 36))
    readonly property int clockHorizontalPadding: defaults.clockHorizontalPadding > 0 ? defaults.clockHorizontalPadding : 26
    readonly property int statusHorizontalPadding: defaults.statusHorizontalPadding > 0 ? defaults.statusHorizontalPadding : 22
    readonly property int workspaceHorizontalPadding: defaults.workspaceHorizontalPadding > 0 ? defaults.workspaceHorizontalPadding : 12

    function resolvedInt(value: int, fallback: int, minimum: int, maximum: int): int {
        const numeric = Number(value);
        const fallbackNumber = Number(fallback);
        const safeFallback = isNaN(fallbackNumber) ? minimum : fallbackNumber;
        const base = isNaN(numeric) || numeric < minimum ? safeFallback : numeric;
        return Math.max(minimum, Math.min(maximum, Math.round(base)));
    }

    function setPanelHeight(value: int): void {
        state.panelHeight = resolvedInt(value, defaultPanelHeight, 24, 72);
        if (state.pillHeight > 0 && state.pillHeight > state.panelHeight)
            state.pillHeight = state.panelHeight;
    }

    function setPillHeight(value: int): void {
        state.pillHeight = resolvedInt(value, defaultPillHeight, 18, panelHeight);
        if (state.pillRadius >= 0 && state.pillRadius > Math.round(state.pillHeight / 2))
            state.pillRadius = Math.round(state.pillHeight / 2);
    }

    function setTopMargin(value: int): void {
        state.topMargin = resolvedInt(value, defaultTopMargin, 0, 32);
    }

    function setPillRadius(value: int): void {
        state.pillRadius = resolvedInt(value, defaultPillRadius, 0, Math.round(pillHeight / 2));
    }

    function resetBarGeometry(): void {
        state.panelHeight = 0;
        state.pillHeight = 0;
        state.topMargin = -1;
        state.pillRadius = -1;
    }

    function setLayoutPillDisplayMode(mode: string): void {
        if (layoutPillDisplayModes.indexOf(mode) !== -1)
            layoutPillDisplayMode = mode;
    }
}
