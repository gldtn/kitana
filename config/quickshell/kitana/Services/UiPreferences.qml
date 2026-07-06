// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell
import "." as Services
import "../custom" as Custom

Singleton {
    id: root

    Custom.Settings {
        id: defaults
    }

    readonly property string layoutPillDisplayMode: Services.QuickshellSettings.layoutPillDisplayMode
    readonly property int panelHeightPreference: Services.QuickshellSettings.panelHeightPreference
    readonly property int pillHeightPreference: Services.QuickshellSettings.pillHeightPreference
    readonly property int topMarginPreference: Services.QuickshellSettings.topMarginPreference
    readonly property int pillRadiusPreference: Services.QuickshellSettings.pillRadiusPreference
    readonly property real barBorderWidthPreference: Services.QuickshellSettings.barBorderWidthPreference
    readonly property real barItemBgOpacityPreference: Services.QuickshellSettings.barItemBgOpacityPreference
    readonly property var layoutPillDisplayModes: ["icons", "compact", "full"]
    readonly property int defaultPanelHeight: defaults.panelHeight > 0 ? defaults.panelHeight : 34
    readonly property int defaultPillHeight: defaults.pillHeight > 0 ? defaults.pillHeight : 32
    readonly property int defaultTopMargin: defaults.topMargin >= 0 ? defaults.topMargin : 4
    readonly property int defaultPillRadius: Math.round(defaultPillHeight / (defaults.radiusDivisor > 0 ? defaults.radiusDivisor : 4))
    readonly property real defaultBarBorderWidth: defaultReal("borderWidth", 1, 0, 2)
    readonly property real defaultBarItemBgOpacity: defaultReal("barItemBgOpacity", 0.9, 0.35, 1)

    readonly property int panelHeight: resolvedInt(panelHeightPreference, defaultPanelHeight, 24, 72)
    readonly property int barHeight: panelHeight
    readonly property int exclusiveZone: panelHeight
    readonly property int pillHeight: Math.min(panelHeight, resolvedInt(pillHeightPreference, defaultPillHeight, 18, 72))
    readonly property int topMargin: resolvedInt(topMarginPreference, defaultTopMargin, 0, 32)
    readonly property int pillRadius: Math.min(Math.round(pillHeight / 2), resolvedInt(pillRadiusPreference, defaultPillRadius, 0, 36))
    readonly property real barBorderWidth: resolvedReal(barBorderWidthPreference, defaultBarBorderWidth, 0, 2)
    readonly property real barItemBgOpacity: resolvedReal(barItemBgOpacityPreference, defaultBarItemBgOpacity, 0.35, 1)
    readonly property int clockHorizontalPadding: defaults.clockHorizontalPadding > 0 ? defaults.clockHorizontalPadding : 26
    readonly property int statusHorizontalPadding: defaults.statusHorizontalPadding > 0 ? defaults.statusHorizontalPadding : 22
    readonly property int workspaceHorizontalPadding: defaults.workspaceHorizontalPadding > 0 ? defaults.workspaceHorizontalPadding : 12

    function defaultReal(name: string, fallback: real, minimum: real, maximum: real): real {
        return resolvedReal(defaults[name], fallback, minimum, maximum);
    }

    function resolvedInt(value: int, fallback: int, minimum: int, maximum: int): int {
        const numeric = Number(value);
        const fallbackNumber = Number(fallback);
        const safeFallback = isNaN(fallbackNumber) ? minimum : fallbackNumber;
        const base = isNaN(numeric) || numeric < minimum ? safeFallback : numeric;
        return Math.max(minimum, Math.min(maximum, Math.round(base)));
    }

    function resolvedReal(value: var, fallback: real, minimum: real, maximum: real): real {
        const numeric = Number(value);
        const fallbackNumber = Number(fallback);
        const safeFallback = isNaN(fallbackNumber) ? minimum : fallbackNumber;
        const base = isNaN(numeric) || numeric < minimum ? safeFallback : numeric;
        return Math.max(minimum, Math.min(maximum, base));
    }

    function roundedReal(value: real): real {
        return Math.round(value * 100) / 100;
    }

    function setPanelHeight(value: int): void {
        const nextHeight = resolvedInt(value, defaultPanelHeight, 24, 72);
        Services.QuickshellSettings.setPanelHeightPreference(nextHeight);
        if (pillHeightPreference > 0 && pillHeightPreference > nextHeight)
            Services.QuickshellSettings.setPillHeightPreference(nextHeight);
    }

    function setPillHeight(value: int): void {
        const nextHeight = resolvedInt(value, defaultPillHeight, 18, panelHeight);
        Services.QuickshellSettings.setPillHeightPreference(nextHeight);
        if (pillRadiusPreference >= 0 && pillRadiusPreference > Math.round(nextHeight / 2))
            Services.QuickshellSettings.setPillRadiusPreference(Math.round(nextHeight / 2));
    }

    function setTopMargin(value: int): void {
        Services.QuickshellSettings.setTopMarginPreference(resolvedInt(value, defaultTopMargin, 0, 32));
    }

    function setPillRadius(value: int): void {
        Services.QuickshellSettings.setPillRadiusPreference(resolvedInt(value, defaultPillRadius, 0, Math.round(pillHeight / 2)));
    }

    function resetBarGeometry(): void {
        Services.QuickshellSettings.resetBarGeometry();
    }

    function setBarBorderWidth(value: real): void {
        Services.QuickshellSettings.setBarBorderWidthPreference(roundedReal(resolvedReal(value, defaultBarBorderWidth, 0, 2)));
    }

    function setBarItemBgOpacity(value: real): void {
        Services.QuickshellSettings.setBarItemBgOpacityPreference(roundedReal(resolvedReal(value, defaultBarItemBgOpacity, 0.35, 1)));
    }

    function resetBarAppearance(): void {
        Services.QuickshellSettings.resetBarAppearance();
    }

    function setLayoutPillDisplayMode(mode: string): void {
        Services.QuickshellSettings.setLayoutPillDisplayMode(mode);
    }
}
