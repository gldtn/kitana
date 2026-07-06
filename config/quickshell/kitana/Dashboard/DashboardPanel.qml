// Kitana managed Quickshell module

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../Components/Controls" as Controls
import "../custom" as Custom
import "../Services" as Services
import "./Components" as Dashboard
import "./Tabs" as Tabs

// qmllint disable uncreatable-type
PanelWindow {
    id: root
    // qmllint enable uncreatable-type

    Custom.Settings {
        id: settings
    }

    readonly property var panelSelf: root
    property bool panelVisible: false
    property bool closing: false
    property real morphProgress: 0
    property var fallbackScreen: null
    property var panelScreen: null
    property bool barVisible: true
    property string activeTab: "datetime"
    property var wallpapers: []
    property var themes: []
    property string weatherStatus: "Loading weather..."
    property var weather: ({})
    property int wallpaperPage: 0
    property int wallpaperPageSize: 16
    property int wallpaperCurrentIndex: 0
    property int themePage: 0
    property int themePageSize: 6
    property int themeCurrentIndex: 0
    property string pickerQuery: ""
    property bool pickerSearchActive: false
    property bool pickerHelpVisible: false
    property string wallpaperDirPending: ""
    property string wallpaperSetName: "default"
    property string wallpaperManagerPath: ""
    property string wallpaperManagerStatus: ""
    property bool wallpaperSetBusy: false
    property string wallpaperSetAction: ""
    property real settingsPreferredContentHeight: 0
    property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"
    property string wallpaperDir: Quickshell.env("KITANA_WALLPAPER_DIR") || Quickshell.env("HOME") + "/.config/kitana/wallpapers"
    property date currentTime: new Date()
    property date calendarMonth: new Date(currentTime.getFullYear(), currentTime.getMonth(), 1)
    property string firstClockTime: "--"
    property string firstClockDate: ""
    property string secondClockTime: "--"
    property string secondClockDate: ""
    property bool mediaAudioOverlayOpen: false
    readonly property string stateDir: (Quickshell.env("HOME") || "") + "/.local/state/kitana"
    readonly property string weatherCachePath: stateDir + "/dashboard-weather-cache.json"
    readonly property string weatherLocation: Services.QuickshellSettings.weatherLocation
    readonly property string weatherUnits: Services.QuickshellSettings.weatherUnits
    readonly property bool weatherHideLocation: Services.QuickshellSettings.weatherHideLocation
    readonly property var worldClocks: Services.QuickshellSettings.worldClocks

    signal openingRequested(var panel)

    readonly property bool islandActive: panelVisible
    readonly property bool expandedSurface: panelVisible || closing
    readonly property var activeScreen: panelScreen || fallbackScreen
    readonly property var focusedMonitor: Hyprland.focusedMonitor
    readonly property int activeScreenWidth: activeScreen ? activeScreen.width : 1920
    readonly property int activeScreenHeight: activeScreen ? activeScreen.height : 1080
    readonly property real collapsedWidth: Math.max(islandPreview.implicitWidth, 1)
    readonly property real collapsedHeight: Math.max(islandPreview.implicitHeight, Services.UiPreferences.pillHeight)
    readonly property real collapsedBaseHeight: Services.UiPreferences.pillHeight
    readonly property real collapsedX: Math.max(0, (activeScreenWidth - collapsedWidth) / 2)
    readonly property real collapsedY: Services.UiPreferences.topMargin + (Services.UiPreferences.panelHeight - collapsedBaseHeight) / 2
    readonly property bool settingsExpanded: activeTab === "settings"
    readonly property real expandedChromeHeight: 2 * 14 + 10 + tabSelector.implicitHeight
    readonly property real expandedTargetWidth: settingsExpanded ? 820 : 700
    readonly property real expandedTargetHeight: settingsExpanded && settingsPreferredContentHeight > 0 ? Math.max(500, settingsPreferredContentHeight + expandedChromeHeight) : 500
    readonly property real expandedWidth: Math.min(expandedTargetWidth, Math.max(collapsedWidth, activeScreenWidth - 32))
    readonly property real expandedHeight: Math.min(expandedTargetHeight, Math.max(collapsedHeight, activeScreenHeight - Services.UiPreferences.panelHeight - 34))
    readonly property real expandedX: (activeScreenWidth - expandedWidth) / 2
    readonly property real expandedTopMargin: Services.UiPreferences.topMargin + 6
    readonly property real collapsedRadius: Math.min(collapsedHeight / 2, Services.UiPreferences.pillRadius)
    readonly property real expandedRadius: 18
    readonly property real contentOpacity: smoothstep(0.58, 1, morphProgress)
    readonly property real previewOpacity: 1 - smoothstep(0.12, 0.42, morphProgress)
    readonly property var hyprlandMonitor: panelScreen ? Hyprland.monitorFor(panelScreen) : null
    readonly property var activeWorkspace: hyprlandMonitor !== null ? hyprlandMonitor.activeWorkspace : null
    readonly property bool hiddenByFullscreen: !expandedSurface && activeWorkspace !== null && activeWorkspace.hasFullscreen && hasTrueFullscreen(activeWorkspace)
    // dashboard-wide UI properties
    readonly property color sectionContainer: Colors.bgSecondary
    readonly property color sectionBorder: Colors.borderFaint
    readonly property real sectionBorderWidth: 0.6
    readonly property real sectionRadius: 16
    readonly property real tabCardHorizontalInset: 0
    readonly property real tabCardVerticalInset: 0
    readonly property real tabCardSpacing: 12

    function lerp(from: real, to: real, progress: real): real {
        return from + (to - from) * progress;
    }

    function smoothstep(edge0: real, edge1: real, value: real): real {
        const progress = Math.max(0, Math.min(1, (value - edge0) / (edge1 - edge0)));
        return progress * progress * (3 - 2 * progress);
    }

    function animateTo(progress: real): void {
        morphAnimation.stop();
        morphAnimation.from = morphProgress;
        morphAnimation.to = progress;
        morphAnimation.restart();
    }

    function compactContains(x: real, y: real): bool {
        return x >= collapsedX && x <= collapsedX + collapsedWidth && y >= collapsedY && y <= collapsedY + collapsedHeight;
    }

    function compactOpenTab(): string {
        return islandSummary ? islandSummary.compactOpenTab : (Services.MediaService.playing ? "media" : "datetime");
    }

    function reopenFromCompact(): void {
        open(compactOpenTab());
    }

    function hasTrueFullscreen(workspace: var): bool {
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

    function open(tab: string): void {
        if (!panelScreen && fallbackScreen)
            panelScreen = fallbackScreen;
        openingRequested(root.panelSelf);
        activeTab = tab || "datetime";
        resetPickerState();
        closing = false;
        panelVisible = true;
        animateTo(1);
        focusPanel();
        refreshTab();
    }

    function close(): void {
        if (!panelVisible)
            return;
        closing = true;
        mediaAudioOverlayOpen = false;
        animateTo(0);
    }

    function toggle(tab: string): void {
        const targetTab = tab || activeTab;
        if (panelVisible && !closing && activeTab === targetTab)
            close();
        else
            open(targetTab);
    }

    function focusPanel(): void {
        closeArea.forceActiveFocus();
    }

    Connections {
        target: Hyprland

        function onRawEvent(event): void {
            if (event.name === "fullscreen" || event.name === "fullscreenmode")
                Hyprland.refreshToplevels();
        }
    }

    Connections {
        target: Services.QuickshellSettings

        function onWeatherLocationChanged(): void {
            root.weather = ({});
            root.loadCachedWeather();
            root.refreshWeather();
        }

        function onWeatherUnitsChanged(): void {
            root.weather = ({});
            root.refreshWeather();
        }

        function onWorldClocksChanged(): void {
            root.refreshWorldClocks();
        }
    }

    function refreshTab(): void {
        if (activeTab === "themes" && themes.length === 0)
            themeListProcess.exec([kitanaDir + "/bin/kitana-theme", "--list"]);
        if ((activeTab === "weather" || activeTab === "datetime") && !weather.current_condition)
            refreshWeather();
        if (activeTab === "datetime")
            refreshWorldClocks();
        if (activeTab === "media")
            refreshMedia();
    }

    function refreshMedia(): void {
        Services.SystemStatus.refresh();
    }

    function refreshWeather(): void {
        if (weatherProcess.running)
            return;

        const location = weatherLocationKey();
        const target = location.length > 0 ? encodeURIComponent(location) : "";
        weatherStatus = "Loading weather...";
        weatherProcess.exec(["curl", "-fsSL", "https://wttr.in/" + target + "?format=j1"]);
    }

    function weatherLocationKey(): string {
        return weatherLocation.trim();
    }

    function setWeatherLocation(value: string): void {
        const unchanged = value === weatherLocation;
        Services.QuickshellSettings.setWeatherLocation(value);
        if (unchanged)
            refreshWeather();
    }

    function toggleWeatherUnits(): void {
        Services.QuickshellSettings.setWeatherUnits(weatherUnits === "C" ? "F" : "C");
    }

    function setWeatherHideLocation(value: bool): void {
        Services.QuickshellSettings.setWeatherHideLocation(value);
    }

    function worldClockLabel(index: int): string {
        return Services.QuickshellSettings.normalizeWorldClocks(worldClocks)[index].label;
    }

    function worldClockTimezone(index: int): string {
        return Services.QuickshellSettings.normalizeWorldClocks(worldClocks)[index].timezone;
    }

    function setWorldClockLabel(index: int, value: string): void {
        Services.QuickshellSettings.setWorldClockLabel(index, value);
    }

    function setWorldClockTimezone(index: int, value: string): void {
        Services.QuickshellSettings.setWorldClockTimezone(index, value);
    }

    function weatherCachePayload(data: var): var {
        return {
            current_condition: data.current_condition || [],
            nearest_area: data.nearest_area || [],
            weather: data.weather || []
        };
    }

    function cacheWeather(data: var): void {
        if (!data || !data.current_condition)
            return;

        weatherCacheFile.setText(JSON.stringify({
            location: weatherLocationKey(),
            weather: weatherCachePayload(data)
        }));
    }

    function loadCachedWeather(): void {
        try {
            const cached = weatherCacheFile.text().trim();
            if (cached.length === 0)
                return;

            const parsed = JSON.parse(cached);
            if (parsed && parsed.location === weatherLocationKey() && parsed.weather && parsed.weather.current_condition) {
                weather = parsed.weather;
                weatherStatus = "";
            }
        } catch (error) {
            weatherCacheFile.setText("");
        }
    }

    function basename(path: string): string {
        return path.split("/").pop();
    }

    function fileUrl(path: string): string {
        return "file://" + path.split("/").map(part => encodeURIComponent(part)).join("/");
    }

    function pathFromFileUrl(path: string): string {
        const value = String(path || "");
        const localPath = value.indexOf("file://") === 0 ? value.slice(7) : value;

        try {
            return decodeURIComponent(localPath);
        } catch (error) {
            return localPath;
        }
    }

    function wallpaperFolderUrl(): string {
        return fileUrl(wallpaperDir);
    }

    function refreshWallpaperCache(): void {
        const items = [];
        let filteredCount = 0;

        for (let i = 0; i < wallpaperFolderModel.count; i++) {
            const path = wallpaperFolderModel.get(i, "filePath");
            if (path)
                items.push(pathFromFileUrl(path.toString()));
        }
        wallpapers = items;
        filteredCount = filteredWallpapers().length;
        wallpaperPage = Math.min(wallpaperPage, wallpaperPageCount() - 1);
        wallpaperCurrentIndex = filteredCount > 0 ? Math.max(0, Math.min(wallpaperCurrentIndex, filteredCount - 1)) : -1;
    }

    function applyWallpaper(path: string): void {
        if (path)
            applyProcess.exec([kitanaDir + "/bin/kitana-wallpaper", path]);
    }

    function loadWallpaperDir(): void {
        if (!wallpaperDirLoadProcess.running)
            wallpaperDirLoadProcess.exec([kitanaDir + "/bin/kitana-wallpaper", "--dir"]);
    }

    function setWallpaperDir(path: string): void {
        const nextDir = pathFromFileUrl(path).trim();
        const currentDir = pathFromFileUrl(wallpaperDir).trim();
        if (nextDir.length === 0 || wallpaperDirSetProcess.running)
            return;
        if (nextDir === currentDir)
            return;

        wallpaperDirPending = nextDir;
        root.wallpaperManagerStatus = "Updating wallpaper folder...";
        wallpaperDirSetProcess.exec([kitanaDir + "/bin/kitana-wallpaper", "--set-dir", nextDir]);
    }

    function applyWallpaperDir(path: string): void {
        if (path.length === 0)
            return;

        if (path === wallpaperDir) {
            wallpaperDirPending = "";
            refreshWallpaperCache();
            return;
        }

        wallpaperDir = path;
        wallpaperDirPending = "";
        wallpaperPage = 0;
        wallpaperCurrentIndex = 0;
        wallpapers = [];
    }

    function setWallpaperSetName(value: string): void {
        root.wallpaperSetName = value.trim();
    }

    function setWallpaperManagerPath(value: string): void {
        root.wallpaperManagerPath = pathFromFileUrl(value).trim();
    }

    function currentWallpaperPath(): string {
        const items = filteredWallpapers();
        return wallpaperCurrentIndex >= 0 && wallpaperCurrentIndex < items.length ? items[wallpaperCurrentIndex] : "";
    }

    function runWallpaperSetCommand(args: var, action: string): void {
        if (root.wallpaperSetBusy)
            return;

        const command = [kitanaDir + "/bin/kitana-wallpaper-set"];
        for (const arg of args)
            command.push(String(arg));

        root.wallpaperSetAction = action;
        root.wallpaperManagerStatus = "Working...";
        wallpaperSetProcess.exec(command);
    }

    function createWallpaperSet(): void {
        if (root.wallpaperSetName.length > 0)
            runWallpaperSetCommand(["create", root.wallpaperSetName], "refresh");
    }

    function deleteWallpaperSet(): void {
        if (root.wallpaperSetName.length > 0)
            runWallpaperSetCommand(["delete", root.wallpaperSetName], "refresh");
    }

    function activateWallpaperSet(): void {
        if (root.wallpaperSetName.length > 0)
            runWallpaperSetCommand(["activate", root.wallpaperSetName], "reloadDir");
    }

    function addWallpaperToSet(): void {
        if (root.wallpaperSetName.length > 0 && root.wallpaperManagerPath.length > 0)
            runWallpaperSetCommand(["add", root.wallpaperSetName, root.wallpaperManagerPath], "refresh");
    }

    function importWallpaperDirToSet(): void {
        if (root.wallpaperSetName.length > 0 && root.wallpaperManagerPath.length > 0)
            runWallpaperSetCommand(["import-dir", root.wallpaperSetName, root.wallpaperManagerPath], "refresh");
    }

    function removeCurrentWallpaperFromSet(): void {
        const current = currentWallpaperPath();
        if (root.wallpaperSetName.length > 0 && current.length > 0)
            runWallpaperSetCommand(["remove", root.wallpaperSetName, basename(current)], "reloadDir");
    }

    function generateWallpaperSetTheme(): void {
        if (root.wallpaperSetName.length > 0)
            runWallpaperSetCommand(["generate", root.wallpaperSetName, "--current"], "refresh");
    }

    function generateWallpaperSetAllThemes(): void {
        if (root.wallpaperSetName.length > 0)
            runWallpaperSetCommand(["generate", root.wallpaperSetName, "--all"], "refresh");
    }

    function themeFromLine(line: string): var {
        const parts = line.split("|");
        return {
            slug: parts[0] || "",
            name: parts[1] || parts[0] || "Theme",
            previewBackground: parts[2] || Colors.bgPrimary,
            previewSurface: parts[3] || Colors.bgSecondary,
            previewBorder: parts[4] || Colors.borderFaint,
            previewForeground: parts[5] || Colors.fgPrimary,
            previewMuted: parts[6] || Colors.fgSecondary,
            previewAccent: parts[7] || Colors.bgAccent,
            previewOnAccentForeground: parts[8] || Colors.fgOnPrimary,
            previewWarning: parts[9] || Colors.warning,
            previewDanger: parts[10] || Colors.error
        };
    }

    function applyTheme(theme: var): void {
        if (!theme || !theme.slug || themeApplyProcess.running)
            return;

        const slug = theme.slug;
        close();
        Qt.callLater(() => themeApplyProcess.exec([kitanaDir + "/bin/kitana-theme", slug]));
    }

    function resetPickerState(): void {
        pickerQuery = "";
        pickerSearchActive = false;
        pickerHelpVisible = false;
        wallpaperPage = 0;
        wallpaperCurrentIndex = 0;
        themePage = 0;
        themeCurrentIndex = 0;
    }

    function selectTab(tab: string): void {
        if (activeTab !== tab)
            resetPickerState();
        activeTab = tab;
        refreshTab();
    }

    function filteredWallpapers(): var {
        const needle = pickerQuery.toLowerCase();
        return needle.length === 0 ? wallpapers : wallpapers.filter(path => basename(path).toLowerCase().indexOf(needle) !== -1);
    }

    function wallpaperPageCount(): int {
        return Math.max(1, Math.ceil(filteredWallpapers().length / wallpaperPageSize));
    }

    function pageItems(page: int, items: var, pageSize: int): var {
        const start = page * pageSize;
        return items.slice(start, start + pageSize);
    }

    function wallpaperPageItems(): var {
        return pageItems(wallpaperPage, filteredWallpapers(), wallpaperPageSize);
    }

    function setWallpaperPage(page: int): void {
        const count = wallpaperPageCount();
        wallpaperPage = Math.max(0, Math.min(count - 1, page));
        wallpaperCurrentIndex = Math.min(filteredWallpapers().length - 1, wallpaperPage * wallpaperPageSize);
    }

    function shiftWallpaperPage(delta: int): void {
        const count = wallpaperPageCount();
        setWallpaperPage((wallpaperPage + delta + count) % count);
    }

    function filteredThemes(): var {
        const needle = pickerQuery.toLowerCase();
        return needle.length === 0 ? themes : themes.filter(theme => theme.name.toLowerCase().indexOf(needle) !== -1 || theme.slug.toLowerCase().indexOf(needle) !== -1);
    }

    function themePageCount(): int {
        return Math.max(1, Math.ceil(filteredThemes().length / themePageSize));
    }

    function themePageItems(): var {
        return pageItems(themePage, filteredThemes(), themePageSize);
    }

    function setThemePage(page: int): void {
        const count = themePageCount();
        themePage = Math.max(0, Math.min(count - 1, page));
        themeCurrentIndex = Math.min(filteredThemes().length - 1, themePage * themePageSize);
    }

    function shiftThemePage(delta: int): void {
        const count = themePageCount();
        setThemePage((themePage + delta + count) % count);
    }

    function movePickerSelection(delta: int): void {
        const items = activeTab === "themes" ? filteredThemes() : filteredWallpapers();
        if (items.length === 0)
            return;

        if (activeTab === "themes") {
            themeCurrentIndex = (themeCurrentIndex + delta + items.length) % items.length;
            themePage = Math.floor(themeCurrentIndex / themePageSize);
        } else {
            wallpaperCurrentIndex = (wallpaperCurrentIndex + delta + items.length) % items.length;
            wallpaperPage = Math.floor(wallpaperCurrentIndex / wallpaperPageSize);
        }
    }

    function refreshPickerFilter(): void {
        if (activeTab === "themes") {
            themePage = 0;
            themeCurrentIndex = filteredThemes().length > 0 ? 0 : -1;
        } else if (activeTab === "wallpapers") {
            wallpaperPage = 0;
            wallpaperCurrentIndex = filteredWallpapers().length > 0 ? 0 : -1;
        }
    }

    function applyCurrentPickerItem(): void {
        if (activeTab === "themes")
            applyTheme(filteredThemes()[themeCurrentIndex]);
        else if (activeTab === "wallpapers") {
            const wallpaper = filteredWallpapers()[wallpaperCurrentIndex];
            if (wallpaper)
                applyWallpaper(wallpaper);
        }
    }

    function handleKey(event: var): void {
        const pickerTab = activeTab === "wallpapers" || activeTab === "themes";
        const text = event.text.toLowerCase();
        const key = event.key;

        if (key === Qt.Key_Escape) {
            if (pickerSearchActive) {
                pickerSearchActive = false;
                focusPanel();
            } else {
                close();
            }
            event.accepted = true;
            return;
        }

        if (pickerSearchActive)
            return;

        if (key === Qt.Key_1) {
            selectTab("datetime");
            event.accepted = true;
            return;
        } else if (key === Qt.Key_2) {
            selectTab("weather");
            event.accepted = true;
            return;
        } else if (key === Qt.Key_3) {
            selectTab("media");
            event.accepted = true;
            return;
        } else if (key === Qt.Key_4) {
            selectTab("wallpapers");
            event.accepted = true;
            return;
        } else if (key === Qt.Key_5) {
            selectTab("themes");
            event.accepted = true;
            return;
        } else if (key === Qt.Key_Period || text === ".") {
            selectTab("settings");
            event.accepted = true;
            return;
        }

        if (!pickerTab)
            return;

        if (key === Qt.Key_Return || key === Qt.Key_Enter || key === Qt.Key_Space) {
            applyCurrentPickerItem();
            event.accepted = true;
        } else if (key === Qt.Key_Left || key === Qt.Key_H) {
            movePickerSelection(-1);
            event.accepted = true;
        } else if (key === Qt.Key_Right || key === Qt.Key_L) {
            movePickerSelection(1);
            event.accepted = true;
        } else if (key === Qt.Key_Up || key === Qt.Key_K) {
            movePickerSelection(activeTab === "themes" ? -3 : -4);
            event.accepted = true;
        } else if (key === Qt.Key_Down || key === Qt.Key_J) {
            movePickerSelection(activeTab === "themes" ? 3 : 4);
            event.accepted = true;
        } else if (key === Qt.Key_PageUp || text === "[" || text === "p") {
            activeTab === "themes" ? shiftThemePage(-1) : shiftWallpaperPage(-1);
            event.accepted = true;
        } else if (key === Qt.Key_PageDown || text === "]" || text === "n") {
            activeTab === "themes" ? shiftThemePage(1) : shiftWallpaperPage(1);
            event.accepted = true;
        } else if (text === "/") {
            pickerSearchActive = true;
            event.accepted = true;
        } else if (text === "?") {
            pickerHelpVisible = !pickerHelpVisible;
            event.accepted = true;
        }
    }

    function tempValue(day: var, keyC: string, keyF: string): string {
        if (!day)
            return "--";
        return weatherUnits === "F" ? day[keyF] + "°F" : day[keyC] + "°C";
    }

    function windValue(condition: var): string {
        if (!condition)
            return "--";
        return weatherUnits === "F" ? condition.windspeedMiles + " mph" : condition.windspeedKmph + " km/h";
    }

    function forecastDays(): var {
        return weather.weather ? weather.weather.slice(0, 5) : [];
    }

    function weatherCodeDescription(code: int): string {
        if (code === 0)
            return "Sunny";
        if (code === 1 || code === 2)
            return "Partly cloudy";
        if (code === 3)
            return "Cloudy";
        if (code === 45 || code === 48)
            return "Fog";
        if (code >= 51 && code <= 57)
            return "Drizzle";
        if (code >= 61 && code <= 67)
            return "Rain";
        if (code >= 71 && code <= 77)
            return "Snow";
        if (code >= 80 && code <= 82)
            return "Rain shower";
        if (code >= 85 && code <= 86)
            return "Snow shower";
        if (code >= 95)
            return "Thunderstorm";
        return "Forecast";
    }

    function openMeteoDays(data: var): var {
        const daily = data && data.daily ? data.daily : null;
        if (!daily || !daily.time)
            return [];

        const days = [];
        for (let i = 0; i < daily.time.length; i++) {
            const min = Math.round(daily.temperature_2m_min[i]);
            const max = Math.round(daily.temperature_2m_max[i]);
            const rain = daily.precipitation_probability_max ? Math.round(daily.precipitation_probability_max[i] || 0) : 0;
            const code = daily.weather_code ? daily.weather_code[i] : -1;
            days.push({
                date: daily.time[i],
                mintempF: weatherUnits === "F" ? String(min) : "--",
                maxtempF: weatherUnits === "F" ? String(max) : "--",
                mintempC: weatherUnits === "C" ? String(min) : "--",
                maxtempC: weatherUnits === "C" ? String(max) : "--",
                hourly: [
                    {},
                    {},
                    {},
                    {},
                    {
                        chanceofrain: String(rain),
                        weatherDesc: [
                            {
                                value: weatherCodeDescription(code)
                            }
                        ]
                    }
                ]
            });
        }
        return days;
    }

    function refreshExtendedForecast(data: var): void {
        const area = data && data.nearest_area && data.nearest_area.length > 0 ? data.nearest_area[0] : null;
        if (!area || !area.latitude || !area.longitude)
            return;

        const tempUnit = weatherUnits === "F" ? "fahrenheit" : "celsius";
        forecastProcess.exec(["curl", "-fsSL", "https://api.open-meteo.com/v1/forecast?latitude=" + area.latitude + "&longitude=" + area.longitude + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&temperature_unit=" + tempUnit + "&timezone=auto&forecast_days=5"]);
    }

    function daysInMonth(month: date): int {
        return new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate();
    }

    function calendarDay(slot: int): int {
        const first = calendarMonth.getDay();
        const day = slot - first + 1;
        return day > 0 && day <= daysInMonth(calendarMonth) ? day : 0;
    }

    function isToday(day: int): bool {
        return day === currentTime.getDate() && calendarMonth.getMonth() === currentTime.getMonth() && calendarMonth.getFullYear() === currentTime.getFullYear();
    }

    function shiftMonth(delta: int): void {
        calendarMonth = new Date(calendarMonth.getFullYear(), calendarMonth.getMonth() + delta, 1);
    }

    function dayOfYear(date: date): int {
        const start = Date.UTC(date.getFullYear(), 0, 0);
        const target = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate());
        return Math.floor((target - start) / 86400000);
    }

    function daysInYear(date: date): int {
        const year = date.getFullYear();
        return new Date(year, 1, 29).getMonth() === 1 ? 366 : 365;
    }

    function isoWeek(date: date): int {
        const target = new Date(date.valueOf());
        const day = (date.getDay() + 6) % 7;
        target.setDate(target.getDate() - day + 3);
        const firstThursday = new Date(target.getFullYear(), 0, 4);
        return 1 + Math.round(((target - firstThursday) / 86400000 - 3 + ((firstThursday.getDay() + 6) % 7)) / 7);
    }

    function refreshWorldClocks(): void {
        firstClockProcess.exec(["env", "TZ=" + worldClockTimezone(0), "date", "+%l:%M %p|%a, %b %-d"]);
        secondClockProcess.exec(["env", "TZ=" + worldClockTimezone(1), "date", "+%l:%M %p|%a, %b %-d"]);
    }

    visible: barVisible && !hiddenByFullscreen
    focusable: expandedSurface
    screen: activeScreen
    implicitWidth: activeScreenWidth
    implicitHeight: activeScreenHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region {
        item: root.expandedSurface ? closeArea : card
        radius: root.expandedSurface ? 0 : Math.round(card.radius)
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-panel"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: expandedSurface ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    // qmllint disable unqualified unresolved-type
    margins.top: 0
    margins.left: 0
    margins.right: 0
    margins.bottom: 0
    // qmllint enable unqualified unresolved-type

    Component.onCompleted: {
        weatherCacheDirProcess.exec(["mkdir", "-p", root.stateDir]);
        root.loadWallpaperDir();
        root.refreshWeather();
    }

    // Keep dashboard shortcuts live after IPC opens without requiring pointer focus.
    HyprlandFocusGrab {
        active: root.expandedSurface
        windows: [root]
    }

    // Clock and tab refresh timer
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = new Date();
            if (root.panelVisible && root.activeTab === "datetime" && root.currentTime.getSeconds() === 0)
                root.refreshWorldClocks();
            if (root.panelVisible && root.activeTab === "media")
                root.refreshMedia();
        }
    }

    // Background weather refresh for the collapsed island.
    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.refreshWeather()
    }

    // Wallpaper directory model
    FolderListModel {
        id: wallpaperFolderModel

        showDirsFirst: false
        showDotAndDotDot: false
        showHidden: false
        caseSensitive: false
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif", "*.avif"]
        showFiles: true
        showDirs: false
        sortField: FolderListModel.Name
        folder: root.wallpaperFolderUrl()

        onCountChanged: root.refreshWallpaperCache()
        onStatusChanged: if (status === FolderListModel.Ready)
            root.refreshWallpaperCache()
    }

    // Wallpaper apply command runner
    Process {
        id: applyProcess

        onRunningChanged: if (!running)
            root.close()
    }

    // Wallpaper directory reader
    Process {
        id: wallpaperDirLoadProcess

        stdout: StdioCollector {
            onStreamFinished: root.applyWallpaperDir(text.trim())
        }

        stderr: StdioCollector {
            onStreamFinished: if (text.trim().length > 0)
                root.wallpaperManagerStatus = text.trim()
        }
    }

    // Wallpaper directory persistence command runner
    Process {
        id: wallpaperDirSetProcess

        stdout: StdioCollector {
            onStreamFinished: root.applyWallpaperDir(text.trim())
        }
    }

    // Custom wallpaper set command runner
    Process {
        id: wallpaperSetProcess

        stdout: StdioCollector {
            onStreamFinished: if (text.trim().length > 0)
                root.wallpaperManagerStatus = text.trim().split("\n").pop()
        }

        stderr: StdioCollector {
            onStreamFinished: if (text.trim().length > 0)
                root.wallpaperManagerStatus = text.trim().split("\n").pop()
        }

        onRunningChanged: {
            root.wallpaperSetBusy = running;
            if (running)
                return;

            if (root.wallpaperSetAction === "reloadDir")
                root.loadWallpaperDir();
            else if (root.wallpaperSetAction === "refresh")
                root.refreshWallpaperCache();

            root.wallpaperSetAction = "";
        }
    }

    // Theme list command runner
    Process {
        id: themeListProcess

        stdout: StdioCollector {
            onStreamFinished: {
                root.themes = text.trim().length > 0 ? text.trim().split("\n").map(line => root.themeFromLine(line)) : [];
                root.themePage = 0;
                root.themeCurrentIndex = root.themes.length > 0 ? 0 : -1;
            }
        }
    }

    // Theme apply command runner
    Process {
        id: themeApplyProcess
    }

    // Cached weather lets the collapsed island show stale-but-recent data while refreshing.
    FileView {
        id: weatherCacheFile

        path: root.weatherCachePath
        printErrors: false
        onLoaded: root.loadCachedWeather()
    }

    // Weather cache directory creator
    Process {
        id: weatherCacheDirProcess
    }

    // Primary weather fetch process
    Process {
        id: weatherProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    root.weather = parsed;
                    root.weatherStatus = "";
                    root.cacheWeather(parsed);
                    root.refreshExtendedForecast(parsed);
                } catch (error) {
                    root.weather = ({});
                    root.weatherStatus = "Weather unavailable";
                }
            }
        }
    }

    // Extended forecast fetch process
    Process {
        id: forecastProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const days = root.openMeteoDays(JSON.parse(text));
                    if (!root.weather.weather || days.length <= root.weather.weather.length)
                        return;

                    const merged = Object.assign({}, root.weather);
                    merged.weather = root.weather.weather.concat(days.slice(root.weather.weather.length));
                    root.weather = merged;
                    root.cacheWeather(merged);
                } catch (error) {
                    // wttr.in already supplied the first three days; keep those on forecast fetch failure.
                }
            }
        }
    }

    // First world clock process
    Process {
        id: firstClockProcess

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|");
                root.firstClockTime = parts[0] ? parts[0].trim() : "--";
                root.firstClockDate = parts[1] || "";
            }
        }
    }

    // Second world clock process
    Process {
        id: secondClockProcess

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|");
                root.secondClockTime = parts[0] ? parts[0].trim() : "--";
                root.secondClockDate = parts[1] || "";
            }
        }
    }

    // Full-screen close and keyboard handler
    MouseArea {
        id: closeArea
        anchors.fill: parent
        enabled: root.expandedSurface
        visible: root.expandedSurface
        hoverEnabled: true
        focus: root.expandedSurface
        Keys.priority: Keys.BeforeItem
        Keys.onPressed: event => root.handleKey(event)
        onClicked: mouse => {
            if (root.closing && root.compactContains(mouse.x, mouse.y)) {
                root.reopenFromCompact();
                return;
            }
            root.close();
        }
    }

    // Main dashboard card
    Rectangle {
        id: card

        x: root.lerp(root.collapsedX, root.expandedX, root.morphProgress)
        y: root.lerp(root.collapsedY, root.expandedTopMargin, root.morphProgress)
        width: root.lerp(root.collapsedWidth, root.expandedWidth, root.morphProgress)
        height: root.lerp(root.collapsedHeight, root.expandedHeight, root.morphProgress)
        opacity: root.visible ? 1 : 0
        radius: root.lerp(root.collapsedRadius, root.expandedRadius, root.morphProgress)
        color: Colors.mixColorWithAlpha(Colors.barItemBg, Colors.bgPrimary, root.morphProgress)
        border.color: Colors.mixColor(Colors.barItemBorder, Colors.borderLight, root.morphProgress)
        border.width: root.lerp(Services.UiPreferences.barBorderWidth, 1, root.morphProgress)
        clip: true

        Behavior on x {
            enabled: root.expandedSurface && !root.closing && root.morphProgress >= 0.99

            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        Behavior on width {
            enabled: root.expandedSurface && !root.closing && root.morphProgress >= 0.99

            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            enabled: root.expandedSurface && !root.closing && root.morphProgress >= 0.99

            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        // Prevent clicks inside card from closing dashboard
        MouseArea {
            id: cardMouse

            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: root.expandedSurface ? Qt.ArrowCursor : Qt.PointingHandCursor
            onPressed: mouse => mouse.accepted = true
            onClicked: mouse => {
                if (!root.expandedSurface && mouse.button === Qt.RightButton) {
                    islandSummary.cycleSummaryMode();
                    return;
                }

                if (root.closing) {
                    root.reopenFromCompact();
                    return;
                }
                if (!root.expandedSurface)
                    root.open(root.compactOpenTab());
            }
        }

        // Collapsed island content inside the morphing dashboard card.
        Item {
            id: islandPreview

            x: root.collapsedX - card.x
            y: root.collapsedY - card.y
            implicitWidth: Math.max(islandSummary.implicitWidth, Services.UiPreferences.pillHeight) + Services.UiPreferences.clockHorizontalPadding
            implicitHeight: Math.max(islandSummary.implicitHeight, Services.UiPreferences.pillHeight)
            width: implicitWidth
            height: implicitHeight
            opacity: root.previewOpacity
            visible: opacity > 0

            Dashboard.IslandSummary {
                id: islandSummary

                anchors.centerIn: parent
                dashboardPanel: root.panelSelf
            }
        }

        // Dashboard tab chrome and content area
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10
            opacity: root.contentOpacity
            visible: opacity > 0

            // Dashboard tab selector row
            RowLayout {
                id: tabSelector

                Layout.fillWidth: true
                spacing: 8

                Controls.Tabs {
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                    iconPosition: "top"
                    model: [
                        {
                            value: "datetime",
                            label: qsTr("Date"),
                            iconName: "calendar"
                        },
                        {
                            value: "weather",
                            label: qsTr("Weather"),
                            iconName: "weather.default"
                        },
                        {
                            value: "media",
                            label: qsTr("Media"),
                            iconName: "media.default"
                        },
                        {
                            value: "wallpapers",
                            label: qsTr("Wallpapers"),
                            iconName: "wallpaper"
                        },
                        {
                            value: "themes",
                            label: qsTr("Themes"),
                            iconName: "theme"
                        },
                        {
                            value: "settings",
                            label: qsTr("Settings"),
                            iconName: "settings"
                        }
                    ]
                    currentValue: root.activeTab
                    onActivated: value => root.selectTab(value)
                }
            }

            // Active dashboard tab loader
            Loader {
                id: activeTabLoader

                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: root.activeTab === "wallpapers" ? wallpapersTab : (root.activeTab === "themes" ? themesTab : (root.activeTab === "media" ? mediaTab : (root.activeTab === "weather" ? weatherTab : (root.activeTab === "settings" ? settingsTab : datetimeTab))))
            }
        }
    }

    // Dashboard island morph animation
    NumberAnimation {
        id: morphAnimation
        target: root
        property: "morphProgress"
        duration: root.closing ? 240 : 340
        easing.type: root.closing ? Easing.InOutCubic : Easing.OutQuint
        onStopped: if (root.closing && root.morphProgress <= 0.01) {
            root.panelVisible = false;
            root.closing = false;
            root.morphProgress = 0;
        }
    }

    // Date and calendar tab component
    Component {
        id: datetimeTab
        Tabs.DateTimeTab {
            dashboard: root.panelSelf
        }
    }

    // Weather tab component
    Component {
        id: weatherTab
        Tabs.WeatherTab {
            dashboard: root.panelSelf
        }
    }

    // Media tab component
    Component {
        id: mediaTab
        Tabs.MediaTab {
            dashboard: root.panelSelf
        }
    }

    // Wallpaper picker tab component
    Component {
        id: wallpapersTab
        Tabs.WallpapersTab {
            dashboard: root.panelSelf
        }
    }

    // Theme picker tab component
    Component {
        id: themesTab
        Tabs.ThemesTab {
            dashboard: root.panelSelf
        }
    }

    // Dashboard settings tab component
    Component {
        id: settingsTab
        Tabs.SettingsTab {
            dashboard: root.panelSelf
        }
    }
}
