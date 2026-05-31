// Kitana managed Quickshell module

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../custom" as Custom
import "../Services" as Services

PanelWindow {
    id: root

    Custom.Settings { id: settings }

    property var panelScreen: null
    property string activeTab: "datetime"
    property var wallpapers: []
    property var themes: []
    property string weatherStatus: "Loading weather..."
    property var weather: ({})
    property alias weatherLocation: weatherPrefs.location
    property alias weatherUnits: weatherPrefs.units
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
    property date currentTime: new Date()
    property date calendarMonth: new Date(currentTime.getFullYear(), currentTime.getMonth(), 1)
    property string firstClockTime: "--"
    property string firstClockDate: ""
    property string secondClockTime: "--"
    property string secondClockDate: ""
    property string mediaStatus: "Stopped"
    property string mediaArtist: ""
    property string mediaTitle: "Nothing Playing"
    property string mediaAlbum: ""
    property string mediaArt: ""
    property string mediaPlayer: ""
    property var cavaLevels: [1, 2, 3, 2, 1, 3, 4, 3, 2, 1, 2, 3, 2, 1, 2, 4, 3, 2, 1, 2, 3, 5, 4, 2, 1, 2, 3, 2, 1, 3, 2, 1]
    property int mediaVisualStep: 0
    readonly property bool mediaPlaying: mediaStatus === "Playing"

    PersistentProperties {
        id: weatherPrefs

        reloadableId: "kitanaDashboardWeather"
        property string location: "Attleboro, MA"
        property string units: "F"
        property bool hideLocation: false
    }

    PersistentProperties {
        id: worldClockPrefs

        reloadableId: "kitanaDashboardWorldClocks"
        property string firstName: "Eastern"
        property string firstTimeZone: "America/New_York"
        property string secondName: "Brasilia"
        property string secondTimeZone: "America/Sao_Paulo"
    }

    function open(tab: string): void {
        activeTab = tab || "datetime";
        resetPickerState();
        visible = true;
        closeArea.forceActiveFocus();
        refreshTab();
    }

    function close(): void {
        visible = false;
    }

    function toggle(tab: string): void {
        if (visible && activeTab === tab)
            close();
        else
            open(tab || activeTab);
    }

    IpcHandler {
        target: "kitana-dashboard"

        function open(tab: string): void { root.open(tab || "datetime"); }
        function close(): void { root.close(); }
        function toggle(tab: string): void { root.toggle(tab || "datetime"); }
    }

    function refreshTab(): void {
        if (activeTab === "wallpapers" && wallpapers.length === 0)
            listProcess.exec([kitanaDir + "/bin/kitana-wallpaper", "--list"]);
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
        mediaProcess.exec(["sh", "-c", "playerctl metadata --format '{{status}}|{{artist}}|{{title}}|{{album}}|{{mpris:artUrl}}|{{playerName}}' 2>/dev/null || true"]);
        Services.SystemStatus.refresh();
    }

    function mediaAction(action: string): void {
        mediaActionProcess.exec(["playerctl", action]);
    }

    function mediaArtSource(): string {
        if (!mediaArt)
            return "";
        return mediaArt.indexOf("file://") === 0 || mediaArt.indexOf("http") === 0 ? mediaArt : "file://" + mediaArt;
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
        return "file://" + path;
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
            background: parts[2] || "#1e1e2e",
            surface: parts[3] || "#313244",
            surfaceAlt: parts[4] || "#45475a",
            foreground: parts[5] || "#cdd6f4",
            muted: parts[6] || "#9399b2",
            accent: parts[7] || "#89b4fa",
            accentText: parts[8] || "#11111b",
            warning: parts[9] || "#f9e2af",
            danger: parts[10] || "#f38ba8"
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
                closeArea.forceActiveFocus();
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
        return weather.weather ? weather.weather.slice(0, 6) : [];
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
        firstClockProcess.exec(["env", "TZ=" + worldClockPrefs.firstTimeZone, "date", "+%l:%M %p|%a, %b %-d"]);
        secondClockProcess.exec(["env", "TZ=" + worldClockPrefs.secondTimeZone, "date", "+%l:%M %p|%a, %b %-d"]);
    }

    screen: panelScreen
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

    Process {
        id: listProcess

        stdout: StdioCollector {
            onStreamFinished: {
                root.wallpapers = text.trim().length > 0 ? text.trim().split("\n") : [];
                root.wallpaperPage = 0;
            }
        }
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
                    root.weather = JSON.parse(text);
                    root.weatherStatus = "";
                } catch (error) {
                    root.weather = ({});
                    root.weatherStatus = "Weather unavailable";
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

    Process {
        id: mediaProcess

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|");
                if (parts.length < 3 || text.trim().length === 0) {
                    root.mediaStatus = "Stopped";
                    root.mediaArtist = "";
                    root.mediaTitle = "Nothing Playing";
                    root.mediaAlbum = "";
                    root.mediaArt = "";
                    root.mediaPlayer = "";
                    return;
                }
                root.mediaStatus = parts[0] || "Stopped";
                root.mediaArtist = parts[1] || "Unknown Artist";
                root.mediaTitle = parts[2] || "Unknown Track";
                root.mediaAlbum = parts[3] || "";
                root.mediaArt = parts[4] || "";
                root.mediaPlayer = parts[5] || "";
            }
        }
    }

    Process { id: mediaActionProcess; onRunningChanged: if (!running) root.refreshMedia() }

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
        radius: 18
        color: Colors.panelStrong
        border.color: Colors.panelBorder
        border.width: 1
        clip: true

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

                TabButton { icon: "󰃰"; label: "Date"; tab: "datetime" }
                TabButton { icon: "󰖕"; label: "Weather"; tab: "weather" }
                TabButton { icon: "󰝚"; label: "Media"; tab: "media" }
                TabButton { icon: "󰸉"; label: "Wallpapers"; tab: "wallpapers" }
                TabButton { icon: "󰏘"; label: "Themes"; tab: "themes" }

                Item { Layout.fillWidth: true }

                TabButton { icon: "󰒓"; label: ""; tab: "settings"; compact: true }
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

    component TabButton: Rectangle {
        id: tabButton

        property string icon: ""
        property string label: ""
        property string tab: ""
        property bool compact: false
        readonly property bool selected: root.activeTab === tab

        Layout.preferredWidth: compact ? 34 : tabContent.implicitWidth + 22
        Layout.preferredHeight: 34
        radius: 10
        color: selected ? Colors.surfaceHighlight : (tabMouse.containsMouse ? Colors.surfaceHover : "transparent")
        border.color: selected ? Colors.panelBorderStrong : "transparent"
        border.width: 1

        Row {
            id: tabContent
            anchors.centerIn: parent
            spacing: 7

            Text {
                text: tabButton.icon
                color: tabButton.selected ? Colors.accent : Colors.foreground
                font.family: settings.fontFamily
                font.pixelSize: settings.iconPixelSize
            }

            Text {
                text: tabButton.label
                visible: !tabButton.compact
                color: Colors.foreground
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: tabMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.activeTab !== tabButton.tab)
                    root.resetPickerState();
                root.activeTab = tabButton.tab;
                root.refreshTab();
            }
        }
    }

    component VolumeSlider: Rectangle {
        id: volumeSlider

        property int value: 0

        Layout.preferredHeight: 34
        radius: 10
        color: Colors.surface
        border.color: volumeMouse.containsMouse ? Colors.panelBorderStrong : Colors.panelBorder
        border.width: 1
        clip: true

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * Math.max(0, Math.min(100, volumeSlider.value)) / 100
            radius: parent.radius
            color: Colors.surfaceHighlight
        }

        Text {
            anchors.centerIn: parent
            text: "Volume " + volumeSlider.value + "%"
            color: Colors.foreground
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.DemiBold
        }

        MouseArea {
            id: volumeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => Services.SystemStatus.setAudioVolume(mouse.x / width * 100)
            onPositionChanged: mouse => {
                if (pressed)
                    Services.SystemStatus.setAudioVolume(mouse.x / width * 100);
            }
        }
    }

    component MediaDeviceRow: Rectangle {
        id: mediaDeviceRow

        property string name: ""
        property bool active: false
        signal clicked

        Layout.fillWidth: true
        Layout.preferredHeight: 46
        radius: 12
        color: active ? Colors.surfaceHighlight : (mediaDeviceMouse.containsMouse ? Colors.surfaceHover : Colors.surface)
        border.color: active ? Colors.panelBorderStrong : Colors.panelBorder
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Text {
                text: active ? "󰓃" : "󰕾"
                color: Colors.accent
                font.family: settings.fontFamily
                font.pixelSize: settings.iconPixelSize
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: name
                    color: Colors.foreground
                    elide: Text.ElideRight
                    font.family: settings.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.DemiBold
                }

                Text {
                    Layout.fillWidth: true
                    text: active ? "Current output" : "Output device"
                    color: Colors.muted
                    elide: Text.ElideRight
                    font.family: settings.fontFamily
                    font.pixelSize: settings.textPixelSize - 1
                }
            }
        }

        MouseArea {
            id: mediaDeviceMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: mediaDeviceRow.clicked()
        }
    }

    component MediaButton: Rectangle {
        id: mediaButton

        property string text: ""
        property bool prominent: false
        signal clicked

        Layout.preferredWidth: prominent ? 48 : 40
        Layout.preferredHeight: prominent ? 40 : 36
        radius: 12
        color: prominent ? Colors.surfaceHighlight : (mediaButtonMouse.containsMouse ? Colors.surfaceHover : Colors.surface)
        border.color: prominent ? Colors.panelBorderStrong : Colors.panelBorder
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: mediaButton.text
            color: prominent ? Colors.accent : Colors.foreground
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: settings.fontFamily
            font.pixelSize: prominent ? settings.iconPixelSize + 2 : settings.iconPixelSize - 1
        }

        MouseArea {
            id: mediaButtonMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: mediaButton.clicked()
        }
    }

    component CavaBars: Item {
        id: cavaBars

        Repeater {
            model: root.cavaLevels.length

            Rectangle {
                required property int index

                readonly property real level: root.mediaPlaying ? Math.max(1, root.cavaLevels[index] || 1) : 1
                width: Math.max(3, (cavaBars.width - (root.cavaLevels.length - 1) * 4) / root.cavaLevels.length)
                height: Math.max(4, cavaBars.height * level / 8)
                x: index * (width + 4)
                y: cavaBars.height - height
                radius: width / 2
                color: root.mediaPlaying ? Colors.accent : Colors.surfaceHighlight
                opacity: root.mediaPlaying ? 0.9 : 0.45

                Behavior on height { NumberAnimation { duration: 90 } }
                Behavior on y { NumberAnimation { duration: 90 } }
            }
        }
    }

    Component {
        id: datetimeTab

        RowLayout {
            spacing: 14

            Rectangle {
                Layout.preferredWidth: 250
                Layout.fillHeight: true
                radius: 16
                color: Colors.panel
                border.color: Colors.panelBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        Layout.fillWidth: true
                        text: Qt.formatDate(root.currentTime, "dddd")
                        color: Colors.muted
                        horizontalAlignment: Text.AlignHCenter
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize + 1
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: Qt.formatDate(root.currentTime, "d")
                        color: Colors.foreground
                        horizontalAlignment: Text.AlignHCenter
                        font.family: settings.fontFamily
                        font.pixelSize: 58
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: Qt.formatDate(root.currentTime, "MMMM yyyy")
                        color: Colors.muted
                        horizontalAlignment: Text.AlignHCenter
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize + 1
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Colors.panelBorder
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        TodayFact {
                            icon: "󰖐"
                            label: weather.current_condition ? weather.current_condition[0].weatherDesc[0].value : "Weather"
                            value: weather.current_condition ? root.tempValue(weather.current_condition[0], "temp_C", "temp_F") : "--"
                        }

                        TodayFact {
                            icon: "󰖛"
                            label: "Sunset"
                            value: weather.weather ? weather.weather[0].astronomy[0].sunset : "--"
                        }

                        TodayFact {
                            icon: "󰃭"
                            label: "Week " + root.isoWeek(root.currentTime)
                            value: "Day " + root.dayOfYear(root.currentTime) + "/" + root.daysInYear(root.currentTime)
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Colors.panelBorder
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "World Clock"
                        color: Colors.foreground
                        horizontalAlignment: Text.AlignHCenter
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        WorldClockRow {
                            name: worldClockPrefs.firstName
                            clockDateText: root.firstClockDate
                            clockTimeText: root.firstClockTime
                        }

                        WorldClockRow {
                            name: worldClockPrefs.secondName
                            clockDateText: root.secondClockDate
                            clockTimeText: root.secondClockTime
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 16
                color: Colors.panel
                border.color: Colors.panelBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: Qt.formatDate(root.calendarMonth, "MMMM yyyy")
                            color: Colors.foreground
                            font.family: settings.fontFamily
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        MiniButton { text: "‹"; onClicked: root.shiftMonth(-1) }
                        MiniButton { text: "Today"; widthOverride: 58; onClicked: root.calendarMonth = new Date(root.currentTime.getFullYear(), root.currentTime.getMonth(), 1) }
                        MiniButton { text: "›"; onClicked: root.shiftMonth(1) }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 7
                        rowSpacing: 6
                        columnSpacing: 6

                        Repeater {
                            model: ["S", "M", "T", "W", "T", "F", "S"]
                            Text {
                                Layout.fillWidth: true
                                text: modelData
                                color: Colors.muted
                                horizontalAlignment: Text.AlignHCenter
                                font.family: settings.fontFamily
                                font.pixelSize: settings.textPixelSize
                            }
                        }

                        Repeater {
                            model: 42

                            Rectangle {
                                required property int index
                                readonly property int day: root.calendarDay(index)

                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                radius: 10
                                color: root.isToday(day) ? Colors.surfaceHighlight : (day > 0 ? Colors.surface : "transparent")
                                border.color: root.isToday(day) ? Colors.panelBorderStrong : "transparent"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: day > 0 ? day : ""
                                    color: root.isToday(day) ? Colors.accent : Colors.foreground
                                    font.family: settings.fontFamily
                                    font.pixelSize: settings.textPixelSize
                                    font.weight: root.isToday(day) ? Font.Bold : Font.Normal
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component PickerFooter: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: root.pickerSearchActive ? 36 : (root.pickerHelpVisible ? 52 : 24)
        radius: 10
        color: root.pickerSearchActive ? Colors.surface : "transparent"
        border.color: root.pickerSearchActive ? Colors.panelBorder : "transparent"
        border.width: root.pickerSearchActive ? 1 : 0

        TextInput {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            verticalAlignment: TextInput.AlignVCenter
            visible: root.pickerSearchActive
            clip: true
            text: root.pickerQuery
            color: Colors.foreground
            selectionColor: Colors.surfaceHighlight
            selectedTextColor: Colors.foreground
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize
            onVisibleChanged: if (visible) forceActiveFocus()
            onTextChanged: {
                root.pickerQuery = text;
                root.refreshPickerFilter();
            }
            Keys.onEscapePressed: {
                root.pickerSearchActive = false;
                closeArea.forceActiveFocus();
            }
            Keys.onReturnPressed: {
                root.pickerSearchActive = false;
                closeArea.forceActiveFocus();
            }
        }

        Text {
            anchors.fill: parent
            visible: !root.pickerSearchActive
            verticalAlignment: Text.AlignVCenter
            text: root.pickerHelpVisible ? "arrows/hjkl move  ·  p/n pages  ·  enter/space apply  ·  / search  ·  ? hide help  ·  esc close" : "? help  ·  arrows/hjkl move  ·  / search  ·  enter/space apply  ·  esc close"
            color: Colors.muted
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }

    component PickerHelp: Item {
        Layout.fillWidth: true
        Layout.preferredHeight: root.pickerSearchActive ? 36 : (root.pickerHelpVisible ? 52 : 24)

        PickerFooter {
            width: Math.min(parent.width, 590)
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    component PickerTopInset: Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 4
    }

    Component {
        id: wallpapersTab

        ColumnLayout {
            spacing: 8

            PickerTopInset {}
            PickerHelp {}

            Item {
                id: wallpaperGrid

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                readonly property int columns: 4
                readonly property int gap: 10
                readonly property real cardWidth: Math.floor((width - (columns - 1) * gap) / columns)
                readonly property real cardHeight: Math.floor((height - 2 * gap) / 3)
                readonly property real trackWidth: columns * cardWidth + (columns - 1) * gap

                Repeater {
                    model: root.wallpaperPageItems()

                    Rectangle {
                        id: wallpaperCard

                        required property string modelData
                        required property int index
                        readonly property int sourceIndex: root.wallpaperPage * root.wallpaperPageSize + index
                        readonly property bool selected: sourceIndex === root.wallpaperCurrentIndex
                        readonly property int row: Math.floor(index / wallpaperGrid.columns)
                        readonly property int column: index % wallpaperGrid.columns
                        x: Math.round((wallpaperGrid.width - wallpaperGrid.trackWidth) / 2 + column * (wallpaperGrid.cardWidth + wallpaperGrid.gap))
                        y: row * (wallpaperGrid.cardHeight + wallpaperGrid.gap)
                        width: wallpaperGrid.cardWidth
                        height: wallpaperGrid.cardHeight
                        radius: 12
                        color: Colors.surface
                        border.color: selected || wallpaperMouse.containsMouse ? Colors.accent : Colors.panelBorder
                        border.width: selected || wallpaperMouse.containsMouse ? 2 : 1
                        clip: true
                        scale: selected || wallpaperMouse.containsMouse ? 1.015 : 1

                        Behavior on scale { NumberAnimation { duration: 120 } }

                        Image {
                            id: wallpaperImage
                            anchors.fill: parent
                            source: root.fileUrl(wallpaperCard.modelData)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: false
                        }

                        Rectangle {
                            id: wallpaperMask
                            anchors.fill: parent
                            radius: parent.radius
                            visible: false
                            layer.enabled: true
                        }

                        MultiEffect {
                            anchors.fill: wallpaperImage
                            source: wallpaperImage
                            maskEnabled: true
                            maskSource: wallpaperMask
                        }

                        MouseArea {
                            id: wallpaperMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.wallpaperCurrentIndex = wallpaperCard.sourceIndex
                            onClicked: root.applyWallpaper(wallpaperCard.modelData)
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 30

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    MiniButton { text: "‹"; onClicked: root.shiftWallpaperPage(-1) }

                    Text {
                        height: 28
                        text: (root.wallpaperPage + 1) + " / " + root.wallpaperPageCount()
                        verticalAlignment: Text.AlignVCenter
                        color: Colors.muted
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }

                    MiniButton { text: "›"; onClicked: root.shiftWallpaperPage(1) }
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    width: 110
                    text: root.filteredWallpapers().length + " wallpapers"
                    color: Colors.muted
                    horizontalAlignment: Text.AlignRight
                    font.family: settings.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    Component {
        id: themesTab

        ColumnLayout {
            spacing: 8

            PickerTopInset {}
            PickerHelp {}

            Item {
                id: themeGrid

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                readonly property int columns: 3
                readonly property int gap: 10
                readonly property real cardWidth: Math.floor((width - (columns - 1) * gap) / columns)
                readonly property real cardHeight: Math.floor((height - gap) / 2)
                readonly property real trackWidth: columns * cardWidth + (columns - 1) * gap

                Repeater {
                    model: root.themePageItems()

                    Rectangle {
                        id: themeCard

                        required property int index
                        required property var modelData
                        readonly property int sourceIndex: root.themePage * root.themePageSize + index
                        readonly property bool selected: sourceIndex === root.themeCurrentIndex
                        readonly property int row: Math.floor(index / themeGrid.columns)
                        readonly property int column: index % themeGrid.columns
                        x: Math.round((themeGrid.width - themeGrid.trackWidth) / 2 + column * (themeGrid.cardWidth + themeGrid.gap))
                        y: row * (themeGrid.cardHeight + themeGrid.gap)
                        width: themeGrid.cardWidth
                        height: themeGrid.cardHeight
                        radius: 14
                        color: modelData.background
                        border.color: selected || themeMouse.containsMouse ? modelData.accent : modelData.surfaceAlt
                        border.width: selected || themeMouse.containsMouse ? 2 : 1
                        clip: true
                        scale: selected || themeMouse.containsMouse ? 1.015 : 1

                        Behavior on scale { NumberAnimation { duration: 120 } }

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 14
                            radius: 12
                            color: modelData.surface
                            border.color: modelData.surfaceAlt
                            border.width: 1

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 14
                                anchors.top: parent.top
                                anchors.topMargin: 14
                                spacing: 8

                                Repeater {
                                    model: [themeCard.modelData.accent, themeCard.modelData.warning, themeCard.modelData.danger, themeCard.modelData.muted]

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: modelData
                                    }
                                }
                            }

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.margins: 14
                                spacing: 4

                                Text {
                                    Layout.fillWidth: true
                                    text: themeCard.modelData.name
                                    color: themeCard.modelData.foreground
                                    elide: Text.ElideRight
                                    font.family: settings.fontFamily
                                    font.pixelSize: settings.textPixelSize + 1
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: themeCard.modelData.slug
                                    color: themeCard.modelData.muted
                                    elide: Text.ElideRight
                                    font.family: settings.fontFamily
                                    font.pixelSize: settings.textPixelSize
                                }
                            }
                        }

                        MouseArea {
                            id: themeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.themeCurrentIndex = themeCard.sourceIndex
                            onClicked: root.applyTheme(themeCard.modelData)
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 30

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    MiniButton { text: "‹"; onClicked: root.shiftThemePage(-1) }

                    Text {
                        height: 28
                        text: (root.themePage + 1) + " / " + root.themePageCount()
                        verticalAlignment: Text.AlignVCenter
                        color: Colors.muted
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }

                    MiniButton { text: "›"; onClicked: root.shiftThemePage(1) }
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    width: 90
                    text: root.filteredThemes().length + " themes"
                    color: Colors.muted
                    horizontalAlignment: Text.AlignRight
                    font.family: settings.fontFamily
                    font.pixelSize: settings.textPixelSize
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    Component {
        id: mediaTab

        ColumnLayout {
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 244
                radius: 16
                color: Colors.panel
                border.color: Colors.panelBorder
                border.width: 1
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Rectangle {
                        id: albumCover

                        Layout.preferredWidth: 164
                        Layout.fillHeight: true
                        radius: 14
                        color: Colors.surface
                        border.color: Colors.panelBorder
                        border.width: 1
                        clip: true

                        Image {
                            id: albumArt

                            anchors.fill: parent
                            source: root.mediaArtSource()
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: false
                        }

                        Rectangle {
                            id: albumArtMask

                            anchors.fill: parent
                            radius: albumCover.radius
                            visible: false
                            layer.enabled: true
                        }

                        MultiEffect {
                            anchors.fill: albumArt
                            source: albumArt
                            visible: albumArt.source.toString().length > 0 && albumArt.status === Image.Ready
                            maskEnabled: true
                            maskSource: albumArtMask
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: root.mediaArtSource().length === 0
                            text: "󰎆"
                            color: Colors.accent
                            font.family: settings.fontFamily
                            font.pixelSize: 58
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                Layout.fillWidth: true
                                text: root.mediaPlayer ? root.mediaPlayer : "Media"
                                color: Colors.accent
                                elide: Text.ElideRight
                                font.family: settings.fontFamily
                                font.pixelSize: settings.textPixelSize
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: root.mediaStatus
                                color: root.mediaPlaying ? Colors.foreground : Colors.muted
                                font.family: settings.fontFamily
                                font.pixelSize: settings.textPixelSize
                                font.weight: Font.DemiBold
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.mediaTitle
                            color: Colors.foreground
                            elide: Text.ElideRight
                            font.family: settings.fontFamily
                            font.pixelSize: 24
                            font.weight: Font.Bold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.mediaArtist + (root.mediaAlbum ? "    " + root.mediaAlbum : "")
                            color: Colors.muted
                            elide: Text.ElideRight
                            font.family: settings.fontFamily
                            font.pixelSize: settings.textPixelSize + 1
                        }

                        CavaBars {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 58
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            MediaButton { text: "󰒮"; onClicked: root.mediaAction("previous") }
                            MediaButton { text: root.mediaPlaying ? "󰏤" : "󰐊"; prominent: true; onClicked: root.mediaAction("play-pause") }
                            MediaButton { text: "󰓛"; onClicked: root.mediaAction("stop") }
                            MediaButton { text: "󰒭"; onClicked: root.mediaAction("next") }
                            Item { Layout.fillWidth: true }
                            MediaButton { text: "󰑐"; onClicked: root.refreshMedia() }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 230
                    Layout.fillHeight: true
                    radius: 16
                    color: Colors.panel
                    border.color: Colors.panelBorder
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Text {
                            Layout.fillWidth: true
                            text: "Audio"
                            color: Colors.foreground
                            font.family: settings.fontFamily
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Services.SystemStatus.audioSink
                            color: Colors.muted
                            elide: Text.ElideRight
                            font.family: settings.fontFamily
                            font.pixelSize: settings.textPixelSize
                        }

                        VolumeSlider {
                            Layout.fillWidth: true
                            value: Services.SystemStatus.audioVolume
                        }

                        MiniButton {
                            Layout.fillWidth: true
                            text: Services.SystemStatus.audioMuted ? "Unmute" : "Mute"
                            heightOverride: 34
                            onClicked: Services.SystemStatus.toggleAudioMute()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 16
                    color: Colors.panel
                    border.color: Colors.panelBorder
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Text {
                            Layout.fillWidth: true
                            text: "Output Devices"
                            color: Colors.foreground
                            font.family: settings.fontFamily
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Flickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            contentWidth: width
                            contentHeight: mediaDeviceList.implicitHeight

                            ColumnLayout {
                                id: mediaDeviceList

                                width: parent.width
                                spacing: 8

                                Repeater {
                                    model: Services.SystemStatus.audioSinks

                                    MediaDeviceRow {
                                        required property var modelData

                                        name: modelData.name
                                        active: Services.SystemStatus.audioSink === modelData.name
                                        onClicked: Services.SystemStatus.setAudioSink(modelData.id)
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: Services.SystemStatus.audioSinks.length === 0
                                    text: "No output devices found"
                                    color: Colors.muted
                                    horizontalAlignment: Text.AlignHCenter
                                    font.family: settings.fontFamily
                                    font.pixelSize: settings.textPixelSize
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: settingsTab

        ColumnLayout {
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: "Dashboard Settings"
                color: Colors.foreground
                font.family: settings.fontFamily
                font.pixelSize: 16
                font.weight: Font.Bold
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 128
                radius: 16
                color: Colors.panel
                border.color: Colors.panelBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: "Weather"
                        color: Colors.foreground
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        DashboardField {
                            Layout.fillWidth: true
                            label: "Location"
                            value: root.weatherLocation
                            secret: weatherPrefs.hideLocation
                            onCommitted: value => {
                                root.weatherLocation = value;
                                root.refreshWeather();
                            }
                        }

                        MiniButton {
                            Layout.alignment: Qt.AlignBottom
                            text: weatherPrefs.hideLocation ? "󰈉" : "󰈈"
                            widthOverride: 46
                            heightOverride: 34
                            onClicked: weatherPrefs.hideLocation = !weatherPrefs.hideLocation
                        }

                        MiniButton {
                            Layout.alignment: Qt.AlignBottom
                            text: root.weatherUnits === "C" ? "°C" : "°F"
                            widthOverride: 46
                            heightOverride: 34
                            onClicked: root.weatherUnits = root.weatherUnits === "C" ? "F" : "C"
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 184
                radius: 16
                color: Colors.panel
                border.color: Colors.panelBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: "World Clocks"
                        color: Colors.foreground
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize
                        font.weight: Font.DemiBold
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 10

                        DashboardField {
                            Layout.fillWidth: true
                            label: "Clock 1 Name"
                            value: worldClockPrefs.firstName
                            onCommitted: value => worldClockPrefs.firstName = value
                        }

                        DashboardField {
                            Layout.fillWidth: true
                            label: "Clock 1 Timezone"
                            value: worldClockPrefs.firstTimeZone
                            onCommitted: value => {
                                worldClockPrefs.firstTimeZone = value;
                                root.refreshWorldClocks();
                            }
                        }

                        DashboardField {
                            Layout.fillWidth: true
                            label: "Clock 2 Name"
                            value: worldClockPrefs.secondName
                            onCommitted: value => worldClockPrefs.secondName = value
                        }

                        DashboardField {
                            Layout.fillWidth: true
                            label: "Clock 2 Timezone"
                            value: worldClockPrefs.secondTimeZone
                            onCommitted: value => {
                                worldClockPrefs.secondTimeZone = value;
                                root.refreshWorldClocks();
                            }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    Component {
        id: weatherTab

        ColumnLayout {
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: 10
                    color: Colors.surface
                    border.color: locationInput.activeFocus ? Colors.panelBorderStrong : Colors.panelBorder
                    border.width: 1

                    TextInput {
                        id: locationInput
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        text: root.weatherLocation
                        echoMode: weatherPrefs.hideLocation ? TextInput.Password : TextInput.Normal
                        color: Colors.foreground
                        selectionColor: Colors.surfaceHighlight
                        selectedTextColor: Colors.foreground
                        font.family: settings.fontFamily
                        font.pixelSize: settings.textPixelSize
                        onEditingFinished: {
                            root.weatherLocation = text;
                            root.refreshWeather();
                        }
                    }
                }

                MiniButton {
                    text: weatherPrefs.hideLocation ? "󰈉" : "󰈈"
                    widthOverride: 46
                    heightOverride: 34
                    onClicked: weatherPrefs.hideLocation = !weatherPrefs.hideLocation
                }

                MiniButton {
                    text: root.weatherUnits === "C" ? "°C" : "°F"
                    widthOverride: 46
                    heightOverride: 34
                    onClicked: root.weatherUnits = root.weatherUnits === "C" ? "F" : "C"
                }

                MiniButton { text: "󰑐"; heightOverride: 34; onClicked: root.refreshWeather() }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 122
                radius: 16
                color: Colors.panel
                border.color: Colors.panelBorder
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: "󰖐"
                        color: Colors.accent
                        font.family: settings.fontFamily
                        font.pixelSize: 42
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 150
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 4

                        Text {
                            text: weather.current_condition ? root.tempValue(weather.current_condition[0], "temp_C", "temp_F") : "--°"
                            color: Colors.foreground
                            font.family: settings.fontFamily
                            font.pixelSize: 28
                            font.weight: Font.Bold
                        }

                        Text {
                            text: weather.current_condition ? weather.current_condition[0].weatherDesc[0].value : root.weatherStatus
                            color: Colors.muted
                            font.family: settings.fontFamily
                            font.pixelSize: settings.textPixelSize + 1
                        }

                        Text {
                            text: weather.nearest_area ? weather.nearest_area[0].areaName[0].value : root.weatherLocation
                            color: Colors.muted
                            font.family: settings.fontFamily
                            font.pixelSize: settings.textPixelSize
                        }
                    }

                    GridLayout {
                        Layout.preferredWidth: 360
                        Layout.alignment: Qt.AlignVCenter
                        columns: 3
                        rowSpacing: 10
                        columnSpacing: 12
                        WeatherMetric { icon: "󰖎"; label: "Humidity"; value: weather.current_condition ? weather.current_condition[0].humidity + "%" : "--" }
                        WeatherMetric { icon: "󰖝"; label: "Wind"; value: root.windValue(weather.current_condition ? weather.current_condition[0] : null) }
                        WeatherMetric { icon: "󰅐"; label: "Feels"; value: weather.current_condition ? root.tempValue(weather.current_condition[0], "FeelsLikeC", "FeelsLikeF") : "--" }
                        WeatherMetric { icon: "󰖌"; label: "Precip"; value: weather.current_condition ? weather.current_condition[0].precipMM + " mm" : "--" }
                        WeatherMetric { icon: "󰒋"; label: "Pressure"; value: weather.current_condition ? weather.current_condition[0].pressure + " hPa" : "--" }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 74
                radius: 14
                color: Colors.panel
                border.color: Colors.panelBorder
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    WeatherMetric { icon: "󰖜"; label: "Sunrise"; value: weather.weather ? weather.weather[0].astronomy[0].sunrise : "--" }
                    WeatherMetric { icon: "󰖛"; label: "Sunset"; value: weather.weather ? weather.weather[0].astronomy[0].sunset : "--" }
                    WeatherMetric { icon: "󰖐"; label: "Moon"; value: weather.weather ? weather.weather[0].astronomy[0].moon_phase : "--"; Layout.fillWidth: true }
                    WeatherMetric { icon: "󰔏"; label: "Visibility"; value: weather.current_condition ? weather.current_condition[0].visibility + " km" : "--" }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: 10
                columnSpacing: 10

                Repeater {
                    model: root.forecastDays()

                    Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 96
                        radius: 14
                        color: Colors.surface
                        border.color: Colors.panelBorder
                        border.width: 1

                        Column {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 5

                            Text {
                                width: parent.width
                                text: Qt.formatDate(new Date(modelData.date), "ddd")
                                color: Colors.foreground
                                horizontalAlignment: Text.AlignHCenter
                                font.family: settings.fontFamily
                                font.pixelSize: settings.textPixelSize
                                font.weight: Font.DemiBold
                            }

                            Text {
                                width: parent.width
                                text: modelData.hourly && modelData.hourly.length > 0 ? modelData.hourly[4].weatherDesc[0].value : ""
                                color: Colors.muted
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                                font.family: settings.fontFamily
                                font.pixelSize: settings.textPixelSize - 1
                            }

                            Text {
                                width: parent.width
                                text: modelData.hourly && modelData.hourly.length > 0 && modelData.hourly[4].chanceofrain > 0 ? "󰖌 " + modelData.hourly[4].chanceofrain + "%" : "󰖐"
                                color: Colors.accent
                                horizontalAlignment: Text.AlignHCenter
                                font.family: settings.fontFamily
                                font.pixelSize: settings.textPixelSize
                            }

                            Text {
                                width: parent.width
                                text: root.weatherUnits === "F" ? modelData.mintempF + "°/" + modelData.maxtempF + "°" : modelData.mintempC + "°/" + modelData.maxtempC + "°"
                                color: Colors.muted
                                horizontalAlignment: Text.AlignHCenter
                                font.family: settings.fontFamily
                                font.pixelSize: settings.textPixelSize
                            }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Text {
                Layout.fillWidth: true
                text: "Weather data from wttr.in"
                color: Colors.muted
                horizontalAlignment: Text.AlignRight
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize - 1
            }
        }
    }

    component DashboardField: ColumnLayout {
        id: dashboardField

        property string label: ""
        property string value: ""
        property bool secret: false
        signal committed(string value)

        spacing: 5

        Text {
            Layout.fillWidth: true
            text: label
            color: Colors.muted
            elide: Text.ElideRight
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize - 1
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            radius: 10
            color: Colors.surface
            border.color: fieldInput.activeFocus ? Colors.panelBorderStrong : Colors.panelBorder
            border.width: 1

            TextInput {
                id: fieldInput
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                text: value
                echoMode: secret ? TextInput.Password : TextInput.Normal
                color: Colors.foreground
                selectionColor: Colors.surfaceHighlight
                selectedTextColor: Colors.foreground
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize
                onEditingFinished: dashboardField.committed(text)
            }
        }
    }

    component MiniButton: Rectangle {
        id: miniButton

        property string text: ""
        property int widthOverride: 32
        property int heightOverride: 28
        signal clicked

        Layout.preferredWidth: widthOverride
        Layout.preferredHeight: heightOverride
        width: widthOverride
        height: heightOverride
        radius: 9
        color: miniMouse.containsMouse ? Colors.surfaceHover : Colors.surface
        border.color: Colors.panelBorder
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: miniButton.text
            color: Colors.foreground
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize
        }

        MouseArea {
            id: miniMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: miniButton.clicked()
        }
    }

    component TodayFact: RowLayout {
        property string icon: ""
        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        spacing: 7

        Text {
            Layout.preferredWidth: 18
            Layout.alignment: Qt.AlignVCenter
            text: icon
            color: Colors.accent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: settings.fontFamily
            font.pixelSize: settings.iconPixelSize - 1
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: label
            color: Colors.muted
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: value
            color: Colors.foreground
            verticalAlignment: Text.AlignVCenter
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize
            font.weight: Font.DemiBold
        }
    }

    component WorldClockRow: RowLayout {
        property string name: ""
        property string clockDateText: ""
        property string clockTimeText: "--"

        Layout.fillWidth: true
        spacing: 6

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: name
                color: Colors.foreground
                elide: Text.ElideRight
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: clockDateText
                color: Colors.muted
                elide: Text.ElideRight
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize - 1
            }
        }

        Text {
            text: clockTimeText
            color: Colors.accent
            font.family: settings.fontFamily
            font.pixelSize: settings.textPixelSize + 1
            font.weight: Font.Bold
        }
    }

    component WeatherMetric: RowLayout {
        property string icon: ""
        property string label: ""
        property string value: ""

        Layout.minimumWidth: 92
        spacing: 8

        Text {
            text: icon
            color: Colors.accent
            font.family: settings.fontFamily
            font.pixelSize: settings.iconPixelSize
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: label
                color: Colors.muted
                elide: Text.ElideRight
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize - 1
            }

            Text {
                Layout.fillWidth: true
                text: value
                color: Colors.foreground
                elide: Text.ElideRight
                font.family: settings.fontFamily
                font.pixelSize: settings.textPixelSize
                font.weight: Font.DemiBold
            }
        }
    }
}
