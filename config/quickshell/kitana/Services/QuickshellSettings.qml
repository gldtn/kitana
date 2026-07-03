// Kitana managed Quickshell settings service

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string layoutPillDisplayMode: "compact"
    property int panelHeightPreference: 0
    property int pillHeightPreference: 0
    property int topMarginPreference: -1
    property int pillRadiusPreference: -1
    property string weatherLocation: "Attleboro, MA"
    property string weatherUnits: "F"
    property bool weatherHideLocation: false
    property bool themePreviewAutoOpen: false
    property var worldClocks: defaultWorldClocks()

    readonly property string stateDir: (Quickshell.env("HOME") || "") + "/.local/state/kitana"
    readonly property string settingsPath: stateDir + "/quickshell-settings.json"
    readonly property var layoutPillDisplayModes: ["icons", "compact", "full"]

    function defaultWorldClocks(): var {
        return [
            {
                label: "Eastern",
                timezone: "America/New_York"
            },
            {
                label: "Brasilia",
                timezone: "America/Sao_Paulo"
            }
        ];
    }

    function validLayoutPillDisplayMode(mode: string): bool {
        return layoutPillDisplayModes.indexOf(mode) !== -1;
    }

    function validWeatherUnits(units: string): bool {
        return units === "F" || units === "C";
    }

    function numberOr(value: var, fallback: int): int {
        const numeric = Number(value);
        return isNaN(numeric) ? fallback : Math.round(numeric);
    }

    function stringOr(value: var, fallback: string): string {
        if (value === undefined || value === null)
            return fallback;
        return String(value);
    }

    function normalizedWorldClock(value: var, fallback: var): var {
        const clock = value && typeof value === "object" ? value : ({});
        return {
            label: stringOr(clock.label, fallback.label),
            timezone: stringOr(clock.timezone, fallback.timezone)
        };
    }

    function normalizeWorldClocks(value: var): var {
        const defaults = defaultWorldClocks();
        const clocks = Array.isArray(value) ? value : [];
        return [
            normalizedWorldClock(clocks[0], defaults[0]),
            normalizedWorldClock(clocks[1], defaults[1])
        ];
    }

    function settingsObject(): var {
        return {
            preferences: {
                layoutPillDisplayMode: layoutPillDisplayMode
            },
            bar: {
                panelHeight: panelHeightPreference,
                pillHeight: pillHeightPreference,
                topMargin: topMarginPreference,
                pillRadius: pillRadiusPreference
            },
            themePreview: {
                autoOpen: themePreviewAutoOpen
            },
            dashboard: {
                weather: {
                    location: weatherLocation,
                    units: weatherUnits,
                    hideLocation: weatherHideLocation
                },
                worldClocks: normalizeWorldClocks(worldClocks)
            }
        };
    }

    function load(): void {
        try {
            const text = settingsFile.text().trim();
            if (text.length === 0)
                return;

            const settings = JSON.parse(text);
            const preferences = settings.preferences || ({});
            const layoutMode = stringOr(preferences.layoutPillDisplayMode, layoutPillDisplayMode);
            if (validLayoutPillDisplayMode(layoutMode))
                layoutPillDisplayMode = layoutMode;

            const bar = settings.bar || ({});
            panelHeightPreference = numberOr(bar.panelHeight, panelHeightPreference);
            pillHeightPreference = numberOr(bar.pillHeight, pillHeightPreference);
            topMarginPreference = numberOr(bar.topMargin, topMarginPreference);
            pillRadiusPreference = numberOr(bar.pillRadius, pillRadiusPreference);

            const themePreview = settings.themePreview || ({});
            themePreviewAutoOpen = !!themePreview.autoOpen;

            const dashboard = settings.dashboard || ({});
            const weather = dashboard.weather || ({});
            weatherLocation = stringOr(weather.location, weatherLocation);
            const units = stringOr(weather.units, weatherUnits);
            weatherUnits = validWeatherUnits(units) ? units : weatherUnits;
            weatherHideLocation = !!weather.hideLocation;
            worldClocks = normalizeWorldClocks(dashboard.worldClocks);
        } catch (error) {
        }
    }

    function save(): void {
        try {
            settingsFile.setText(JSON.stringify(settingsObject(), null, 2));
        } catch (error) {
        }
    }

    function setLayoutPillDisplayMode(mode: string): void {
        if (!validLayoutPillDisplayMode(mode) || layoutPillDisplayMode === mode)
            return;
        layoutPillDisplayMode = mode;
        save();
    }

    function setThemePreviewAutoOpen(value: bool): void {
        if (themePreviewAutoOpen === value)
            return;
        themePreviewAutoOpen = value;
        save();
    }

    function setPanelHeightPreference(value: int): void {
        panelHeightPreference = value;
        save();
    }

    function setPillHeightPreference(value: int): void {
        pillHeightPreference = value;
        save();
    }

    function setTopMarginPreference(value: int): void {
        topMarginPreference = value;
        save();
    }

    function setPillRadiusPreference(value: int): void {
        pillRadiusPreference = value;
        save();
    }

    function resetBarGeometry(): void {
        panelHeightPreference = 0;
        pillHeightPreference = 0;
        topMarginPreference = -1;
        pillRadiusPreference = -1;
        save();
    }

    function setWeatherLocation(value: string): void {
        weatherLocation = value;
        save();
    }

    function setWeatherUnits(value: string): void {
        if (!validWeatherUnits(value) || weatherUnits === value)
            return;
        weatherUnits = value;
        save();
    }

    function setWeatherHideLocation(value: bool): void {
        weatherHideLocation = value;
        save();
    }

    function worldClockLabel(index: int): string {
        return normalizeWorldClocks(worldClocks)[index].label;
    }

    function worldClockTimezone(index: int): string {
        return normalizeWorldClocks(worldClocks)[index].timezone;
    }

    function setWorldClockLabel(index: int, value: string): void {
        if (index < 0 || index >= 2)
            return;
        const clocks = normalizeWorldClocks(worldClocks);
        clocks[index] = {
            label: value,
            timezone: clocks[index].timezone
        };
        worldClocks = clocks;
        save();
    }

    function setWorldClockTimezone(index: int, value: string): void {
        if (index < 0 || index >= 2)
            return;
        const clocks = normalizeWorldClocks(worldClocks);
        clocks[index] = {
            label: clocks[index].label,
            timezone: value
        };
        worldClocks = clocks;
        save();
    }

    Component.onCompleted: settingsDirProcess.exec(["mkdir", "-p", root.stateDir])

    FileView {
        id: settingsFile

        path: root.settingsPath
        printErrors: false
        onLoaded: root.load()
    }

    Process {
        id: settingsDirProcess
    }
}
