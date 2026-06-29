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
import "../Bar/Sections" as BarSections
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
    property real sourceX: 0
    property real sourceY: Services.UiPreferences.topMargin + (Services.UiPreferences.panelHeight - Services.UiPreferences.pillHeight) / 2
    property real sourceWidth: 240
    property real sourceHeight: Services.UiPreferences.pillHeight
    property string activeTab: "datetime"
    property var wallpapers: []
    property var themes: []
    property string weatherStatus: "Loading weather..."
    property var weather: ({})
    property alias weatherLocation: weatherPreferences.location
    property alias weatherUnits: weatherPreferences.units
    property int wallpaperPage: 0
    property int wallpaperPageSize: 12
    property int wallpaperCurrentIndex: 0
    property int themePage: 0
    property int themePageSize: 6
    property int themeCurrentIndex: 0
    property string pickerQuery: ""
    property bool pickerSearchActive: false
    property bool pickerHelpVisible: false
    property bool compactHoverLatched: false
    property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"
    property string wallpaperDir: Quickshell.env("KITANA_WALLPAPER_DIR") || Quickshell.env("HOME") + "/.config/kitana/wallpapers"
    property date currentTime: new Date()
    property date calendarMonth: new Date(currentTime.getFullYear(), currentTime.getMonth(), 1)
    property string firstClockTime: "--"
    property string firstClockDate: ""
    property string secondClockTime: "--"
    property string secondClockDate: ""
    property bool mediaAudioOverlayOpen: false

    // Saved weather preferences
    PersistentProperties {
        id: weatherPreferences

        reloadableId: "kitanaDashboardWeather"
        property string location: "Attleboro, MA"
        property string units: "F"
        property bool hideLocation: false
    }

    // Saved world clock preferences
    PersistentProperties {
        id: worldClockPreferences

        reloadableId: "kitanaDashboardWorldClocks"
        property string firstName: "Eastern"
        property string firstTimeZone: "America/New_York"
        property string secondName: "Brasilia"
        property string secondTimeZone: "America/Sao_Paulo"
    }

    readonly property bool islandActive: panelVisible
    readonly property bool expandedSurface: panelVisible || closing
    readonly property var focusedScreen: screenForMonitor(Hyprland.focusedMonitor)
    readonly property var activeScreen: expandedSurface ? (panelScreen || focusedScreen || fallbackScreen) : (focusedScreen || panelScreen || fallbackScreen)
    readonly property int activeScreenWidth: activeScreen ? activeScreen.width : 1920
    readonly property int activeScreenHeight: activeScreen ? activeScreen.height : 1080
    readonly property real collapsedWidth: Math.max(sourceWidth, Services.UiPreferences.pillHeight * 4)
    readonly property real collapsedHeight: Math.max(sourceHeight, Services.UiPreferences.pillHeight)
    readonly property real collapsedX: Math.max(0, (activeScreenWidth - collapsedWidth) / 2)
    readonly property real collapsedY: Services.UiPreferences.topMargin + (Services.UiPreferences.panelHeight - collapsedHeight) / 2
    readonly property int compactX: Math.round(collapsedX)
    readonly property int compactY: Math.round(collapsedY)
    readonly property int compactWidth: Math.round(collapsedWidth)
    readonly property int compactHeight: Math.round(collapsedHeight)
    readonly property real expandedWidth: Math.min(700, Math.max(collapsedWidth, activeScreenWidth - 32))
    readonly property real expandedHeight: Math.min(500, Math.max(collapsedHeight, activeScreenHeight - Services.UiPreferences.panelHeight - 34))
    readonly property real expandedX: (activeScreenWidth - expandedWidth) / 2
    readonly property real expandedTopMargin: Services.UiPreferences.topMargin + 6
    readonly property real collapsedRadius: Math.min(collapsedHeight / 2, Services.UiPreferences.pillRadius)
    readonly property real expandedRadius: 18
    readonly property real contentOpacity: Math.max(0, Math.min(1, (morphProgress - 0.36) / 0.64))
    readonly property real previewOpacity: Math.max(0, Math.min(1, 1 - morphProgress * 2.6))

    function lerp(from: real, to: real, progress: real): real {
        return from + (to - from) * progress;
    }

    function animateTo(progress: real): void {
        morphAnimation.stop();
        morphAnimation.from = morphProgress;
        morphAnimation.to = progress;
        morphAnimation.restart();
    }

    function compactContains(x: real, y: real): bool {
        return x >= compactX && x <= compactX + compactWidth && y >= compactY && y <= compactY + compactHeight;
    }

    function setCompactHoverLatched(value: bool): void {
        compactHoverLatched = value;
    }

    function updateCompactHover(x: real, y: real): void {
        compactHoverLatched = compactContains(x, y);
    }

    function reopenFromCompact(): void {
        compactHoverLatched = true;
        open(activeTab || "datetime", panelScreen, compactX, compactY, compactWidth, compactHeight);
    }

    function screenForMonitor(monitor: var): var {
        if (!monitor || !monitor.name)
            return null;
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === monitor.name)
                return Quickshell.screens[i];
        }
        return null;
    }

    function open(tab: string, sourceScreen: var, x: var, y: var, width: var, height: var): void {
        if (sourceScreen)
            panelScreen = sourceScreen;
        else if (activeScreen)
            panelScreen = activeScreen;
        else if (!panelScreen && fallbackScreen)
            panelScreen = fallbackScreen;
        if (typeof width === "number" && width > 0)
            sourceWidth = width;
        if (typeof height === "number" && height > 0)
            sourceHeight = height;
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

    function toggle(tab: string, sourceScreen: var, x: var, y: var, width: var, height: var): void {
        const targetTab = tab || activeTab;
        if (panelVisible && !closing && activeTab === targetTab)
            close();
        else
            open(targetTab, sourceScreen, x, y, width, height);
    }

    function focusPanel(): void {
        closeArea.forceActiveFocus();
    }

    // Dashboard IPC command bridge
    IpcHandler {
        target: "kitana-dashboard"

        function open(tab: string): void {
            root.open(tab || "datetime");
        }
        function close(): void {
            root.close();
        }
        function toggle(tab: string): void {
            root.toggle(tab || "datetime");
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

        const location = weatherLocation.trim();
        const target = location.length > 0 ? encodeURIComponent(location) : "";
        weatherStatus = "Loading weather...";
        weatherProcess.exec(["curl", "-fsSL", "https://wttr.in/" + target + "?format=j1"]);
    }

    function basename(path: string): string {
        return path.split("/").pop();
    }

    function fileUrl(path: string): string {
        return "file://" + path.split("/").map(part => encodeURIComponent(part)).join("/");
    }

    function pathFromFileUrl(path: string): string {
        return path.indexOf("file://") === 0 ? path.slice(7) : path;
    }

    function wallpaperFolderUrl(): string {
        return fileUrl(wallpaperDir);
    }

    function refreshWallpaperCache(): void {
        const items = [];
        for (let i = 0; i < wallpaperFolderModel.count; i++) {
            const path = wallpaperFolderModel.get(i, "filePath");
            if (path)
                items.push(pathFromFileUrl(path.toString()));
        }
        wallpapers = items;
        wallpaperPage = Math.min(wallpaperPage, wallpaperPageCount() - 1);
        wallpaperCurrentIndex = wallpapers.length > 0 ? Math.max(0, Math.min(wallpaperCurrentIndex, filteredWallpapers().length - 1)) : -1;
    }

    function applyWallpaper(path: string): void {
        if (path)
            applyProcess.exec([kitanaDir + "/bin/kitana-wallpaper", path]);
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

    function shiftWallpaperPage(delta: int): void {
        const count = wallpaperPageCount();
        wallpaperPage = (wallpaperPage + delta + count) % count;
        wallpaperCurrentIndex = Math.min(filteredWallpapers().length - 1, wallpaperPage * wallpaperPageSize);
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

    function shiftThemePage(delta: int): void {
        const count = themePageCount();
        themePage = (themePage + delta + count) % count;
        themeCurrentIndex = Math.min(filteredThemes().length - 1, themePage * themePageSize);
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
        else if (activeTab === "wallpapers")
            applyWallpaper(filteredWallpapers()[wallpaperCurrentIndex]);
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

        if (!pickerTab || pickerSearchActive)
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
        firstClockProcess.exec(["env", "TZ=" + worldClockPreferences.firstTimeZone, "date", "+%l:%M %p|%a, %b %-d"]);
        secondClockProcess.exec(["env", "TZ=" + worldClockPreferences.secondTimeZone, "date", "+%l:%M %p|%a, %b %-d"]);
    }

    visible: expandedSurface
    focusable: expandedSurface
    screen: activeScreen
    implicitWidth: expandedSurface ? activeScreenWidth : compactWidth
    implicitHeight: expandedSurface ? activeScreenHeight : compactHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-panel"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: expandedSurface ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: root.expandedSurface
        bottom: root.expandedSurface
    }

    // qmllint disable unqualified unresolved-type
    margins.top: root.expandedSurface ? 0 : root.compactY
    margins.left: root.expandedSurface ? 0 : root.compactX
    margins.right: 0
    margins.bottom: 0
    // qmllint enable unqualified unresolved-type

    Component.onCompleted: root.refreshWeather()

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

    // Primary weather fetch process
    Process {
        id: weatherProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    root.weather = parsed;
                    root.weatherStatus = "";
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
        focus: true
        Keys.priority: Keys.BeforeItem
        Keys.onPressed: event => root.handleKey(event)
        onPositionChanged: mouse => root.updateCompactHover(mouse.x, mouse.y)
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

        x: root.expandedSurface ? root.lerp(root.compactX, root.expandedX, root.morphProgress) : 0
        y: root.expandedSurface ? root.lerp(root.compactY, root.expandedTopMargin, root.morphProgress) : 0
        width: root.lerp(root.compactWidth, root.expandedWidth, root.morphProgress)
        height: root.lerp(root.compactHeight, root.expandedHeight, root.morphProgress)
        opacity: root.visible ? 1 : 0
        radius: root.lerp(root.collapsedRadius, root.expandedRadius, root.morphProgress)
        color: Colors.mixColor(Colors.bgSecondary, Colors.bgPrimary, root.morphProgress)
        border.color: Colors.borderLight
        border.width: 1
        clip: true

        // Prevent clicks inside card from closing dashboard
        MouseArea {
            id: cardMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.expandedSurface ? Qt.ArrowCursor : Qt.PointingHandCursor
            onPressed: mouse => mouse.accepted = true
            onPositionChanged: mouse => root.updateCompactHover(card.x + mouse.x, card.y + mouse.y)
            onClicked: {
                if (root.closing) {
                    root.reopenFromCompact();
                    return;
                }
                if (!root.expandedSurface)
                    root.open("datetime", root.activeScreen);
            }
        }

        // Collapsed island preview that replaces the old bar center pill.
        BarSections.Center {
            id: islandPreview

            anchors.centerIn: parent
            embedded: true
            interactive: false
            forceDashboardIcon: root.compactHoverLatched
            hideWhenDashboardActive: false
            dashboardPanel: root.panelSelf
            panelScreen: root.activeScreen
            sourceX: root.collapsedX
            sourceY: root.collapsedY
            opacity: root.previewOpacity
            visible: opacity > 0
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
                Layout.fillWidth: true
                spacing: 8

                Dashboard.TabButton {
                    dashboard: root.panelSelf
                    iconName: "calendar"
                    label: "Date"
                    tab: "datetime"
                }
                Dashboard.TabButton {
                    dashboard: root.panelSelf
                    iconName: "weather.default"
                    label: "Weather"
                    tab: "weather"
                }
                Dashboard.TabButton {
                    dashboard: root.panelSelf
                    iconName: "media.default"
                    label: "Media"
                    tab: "media"
                }
                Dashboard.TabButton {
                    dashboard: root.panelSelf
                    iconName: "wallpaper"
                    label: "Wallpapers"
                    tab: "wallpapers"
                }
                Dashboard.TabButton {
                    dashboard: root.panelSelf
                    iconName: "theme"
                    label: "Themes"
                    tab: "themes"
                }

                Item {
                    Layout.fillWidth: true
                }

                Dashboard.TabButton {
                    dashboard: root.panelSelf
                    iconName: "settings"
                    label: ""
                    tab: "settings"
                    compact: true
                }

                Controls.CloseButton {
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: {
                        root.setCompactHoverLatched(false);
                        root.close();
                    }
                }
            }

            // Tab header divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.borderFaint
            }

            // Active dashboard tab loader
            Loader {
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
        duration: root.closing ? 220 : 260
        easing.type: root.closing ? Easing.InOutCubic : Easing.OutCubic
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
            worldClockPrefs: worldClockPreferences
        }
    }

    // Weather tab component
    Component {
        id: weatherTab
        Tabs.WeatherTab {
            dashboard: root.panelSelf
            weatherPrefs: weatherPreferences
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
            weatherPrefs: weatherPreferences
            worldClockPrefs: worldClockPreferences
        }
    }
}
