// Kitana managed Quickshell module

import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../custom" as Custom
import "../Services" as Services
import "./Components" as Dashboard
import "./Tabs" as Tabs

PanelWindow {
    id: root

    Custom.Settings { id: settings }

    readonly property var panelSelf: root
    property real revealProgress: 0
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
    property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"
    property string wallpaperDir: Quickshell.env("KITANA_WALLPAPER_DIR") || Quickshell.env("HOME") + "/.config/kitana/wallpapers"
    property date currentTime: new Date()
    property date calendarMonth: new Date(currentTime.getFullYear(), currentTime.getMonth(), 1)
    property string firstClockTime: "--"
    property string firstClockDate: ""
    property string secondClockTime: "--"
    property string secondClockDate: ""
    property var cavaLevels: [1, 2, 3, 2, 1, 3, 4, 3, 2, 1, 2, 3, 2, 1, 2, 4, 3, 2, 1, 2, 3, 5, 4, 2, 1, 2, 3, 2, 1, 3, 2, 1]
    property int mediaVisualStep: 0
    property bool mediaAudioOverlayOpen: false
    readonly property bool mediaPlaying: Services.MediaService.playing

    PersistentProperties {
        id: weatherPreferences

        reloadableId: "kitanaDashboardWeather"
        property string location: "Attleboro, MA"
        property string units: "F"
        property bool hideLocation: false
    }

    PersistentProperties {
        id: worldClockPreferences

        reloadableId: "kitanaDashboardWorldClocks"
        property string firstName: "Eastern"
        property string firstTimeZone: "America/New_York"
        property string secondName: "Brasilia"
        property string secondTimeZone: "America/Sao_Paulo"
    }

    function open(tab: string): void {
        const wasVisible = visible;
        activeTab = tab || "datetime";
        resetPickerState();
        visible = true;
        if (!wasVisible) {
            revealProgress = 0;
            revealAnimation.restart();
        }
        focusPanel();
        refreshTab();
    }

    function close(): void {
        visible = false;
        revealProgress = 0;
        mediaAudioOverlayOpen = false;
    }

    function toggle(tab: string): void {
        if (visible && activeTab === tab)
            close();
        else
            open(tab || activeTab);
    }

    function focusPanel(): void {
        closeArea.forceActiveFocus();
    }

    IpcHandler {
        target: "kitana-dashboard"

        function open(tab: string): void { root.open(tab || "datetime"); }
        function close(): void { root.close(); }
        function toggle(tab: string): void { root.toggle(tab || "datetime"); }
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

    function updateMediaVisual(): void {
        mediaVisualStep = (mediaVisualStep + 1) % 360;
        const values = [];
        for (let i = 0; i < 32; i++) {
            const wave = Math.sin((mediaVisualStep + i * 18) / 11) + Math.sin((mediaVisualStep + i * 9) / 17);
            values.push(Math.max(1, Math.min(8, Math.round(4 + wave * 1.8))));
        }
        cavaLevels = values;
    }

    function refreshWeather(): void {
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
            previewBackground: parts[2] || "#1e1e2e",
            previewSurface: parts[3] || "#313244",
            previewBorder: parts[4] || "#45475a",
            previewForeground: parts[5] || "#cdd6f4",
            previewMuted: parts[6] || "#9399b2",
            previewAccent: parts[7] || "#89b4fa",
            previewOnAccentForeground: parts[8] || "#11111b",
            previewWarning: parts[9] || "#f9e2af",
            previewDanger: parts[10] || "#f38ba8"
        };
    }

    function applyTheme(theme: var): void {
        if (theme && theme.slug)
            themeApplyProcess.exec([kitanaDir + "/bin/kitana-theme", theme.slug]);
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
                hourly: [{}, {}, {}, {}, {
                    chanceofrain: String(rain),
                    weatherDesc: [{ value: weatherCodeDescription(code) }]
                }]
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
        return day === currentTime.getDate()
            && calendarMonth.getMonth() === currentTime.getMonth()
            && calendarMonth.getFullYear() === currentTime.getFullYear();
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

    visible: false
    focusable: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = new Date();
            if (root.visible && root.activeTab === "datetime" && root.currentTime.getSeconds() === 0)
                root.refreshWorldClocks();
            if (root.visible && root.activeTab === "media")
                root.refreshMedia();
        }
    }

    Timer {
        interval: 140
        running: root.visible && root.activeTab === "media" && root.mediaPlaying
        repeat: true
        onTriggered: root.updateMediaVisual()
    }

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
        onStatusChanged: if (status === FolderListModel.Ready) root.refreshWallpaperCache()
    }

    Process {
        id: applyProcess

        onRunningChanged: if (!running) root.close()
    }

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

    Process {
        id: themeApplyProcess

        onRunningChanged: if (!running) root.close()
    }

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

    MouseArea {
        id: closeArea
        anchors.fill: parent
        focus: true
        Keys.priority: Keys.BeforeItem
        Keys.onPressed: event => root.handleKey(event)
        onClicked: root.close()
    }

    Rectangle {
        id: card

        width: Math.min(700, parent.width - 32)
        height: Math.min(500, parent.height - settings.panelHeight - 34)
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: settings.panelHeight + settings.topMargin + 10
        opacity: root.revealProgress
        radius: 18
        color: Colors.panelBackground
        border.color: Colors.panelBorder
        border.width: 1
        clip: true

        transform: Translate {
            y: (1 - root.revealProgress) * -14
        }

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Dashboard.TabButton { dashboard: panelSelf; iconName: "calendar"; label: "Date"; tab: "datetime" }
                Dashboard.TabButton { dashboard: panelSelf; iconName: "weather.default"; label: "Weather"; tab: "weather" }
                Dashboard.TabButton { dashboard: panelSelf; iconName: "media.default"; label: "Media"; tab: "media" }
                Dashboard.TabButton { dashboard: panelSelf; iconName: "wallpaper"; label: "Wallpapers"; tab: "wallpapers" }
                Dashboard.TabButton { dashboard: panelSelf; iconName: "theme"; label: "Themes"; tab: "themes" }

                Item { Layout.fillWidth: true }

                Dashboard.TabButton { dashboard: panelSelf; iconName: "settings"; label: ""; tab: "settings"; compact: true }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.panelBorder
            }

            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: root.activeTab === "wallpapers" ? wallpapersTab : (root.activeTab === "themes" ? themesTab : (root.activeTab === "media" ? mediaTab : (root.activeTab === "weather" ? weatherTab : (root.activeTab === "settings" ? settingsTab : datetimeTab))))
            }
        }
    }

    NumberAnimation {
        id: revealAnimation
        target: root
        property: "revealProgress"
        to: 1
        duration: 140
        easing.type: Easing.OutCubic
    }

    Component { id: datetimeTab; Tabs.DateTimeTab { dashboard: panelSelf; worldClockPrefs: worldClockPreferences } }
    Component { id: weatherTab; Tabs.WeatherTab { dashboard: panelSelf; weatherPrefs: weatherPreferences } }
    Component { id: mediaTab; Tabs.MediaTab { dashboard: panelSelf } }
    Component { id: wallpapersTab; Tabs.WallpapersTab { dashboard: panelSelf } }
    Component { id: themesTab; Tabs.ThemesTab { dashboard: panelSelf } }
    Component { id: settingsTab; Tabs.SettingsTab { dashboard: panelSelf; weatherPrefs: weatherPreferences; worldClockPrefs: worldClockPreferences } }
}
