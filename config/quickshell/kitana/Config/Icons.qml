// Kitana managed Quickshell icon tokens

pragma Singleton

import QtQuick
import ".."

QtObject {
    readonly property string appSearch: icon("search", "󰍉")
    readonly property string arch: icon("terminal", "")
    readonly property string audioOutput: icon("speaker", "󰓃")
    readonly property string bluetooth: icon("bluetooth", "󰂯")
    readonly property string bluetoothConnected: icon("bluetooth_connected", "󰂱")
    readonly property string bluetoothDisabled: icon("bluetooth_disabled", "󰂲")
    readonly property string brightness: icon("brightness_6", "󰃠")
    readonly property string calendar: icon("calendar_month", "󰃭")
    readonly property string check: icon("check_circle", "󰄬")
    readonly property string chevronLeft: icon("chevron_left", "󰅁")
    readonly property string chevronRight: icon("chevron_right", "󰅂")
    readonly property string close: icon("close", "󰅖")
    readonly property string dashboard: icon("dashboard", "󰕮")
    readonly property string deleteForever: icon("delete", "󰆴")
    readonly property string disconnect: icon("link_off", "󰌸")
    readonly property string ethernet: icon("lan", "󰌘")
    readonly property string keyboard: icon("keyboard", "󰌌")
    readonly property string lock: icon("lock", "󰌾")
    readonly property string logout: icon("logout", "󰍃")
    readonly property string media: icon("music_note", "󰝚")
    readonly property string mic: icon("mic", "󰍬")
    readonly property string micMuted: icon("mic_off", "󰍭")
    readonly property string monitor: icon("desktop_windows", "󰍹")
    readonly property string moon: icon("dark_mode", "󰍛")
    readonly property string networkOff: icon("wifi_off", "󰖪")
    readonly property string notifications: icon("notifications", "󰂚")
    readonly property string notificationsActive: icon("notifications_active", "󰂛")
    readonly property string notificationsOff: icon("notifications_off", "󰂛")
    readonly property string palette: icon("palette", "󰏘")
    readonly property string pause: icon("pause", "󰏤")
    readonly property string play: icon("play_arrow", "󰐊")
    readonly property string power: icon("power_settings_new", "󰐥")
    readonly property string pressure: icon("speed", "󰓅")
    readonly property string previous: icon("skip_previous", "󰒮")
    readonly property string next: icon("skip_next", "󰒭")
    readonly property string refresh: icon("refresh", "󰑐")
    readonly property string restart: icon("restart_alt", "󰜉")
    readonly property string scan: icon("sync", "󰓦")
    readonly property string settings: icon("settings", "󰒓")
    readonly property string shutdown: icon("power_settings_new", "󰐥")
    readonly property string stop: icon("stop", "󰓛")
    readonly property string sunrise: icon("wb_twilight", "󰖜")
    readonly property string sunset: icon("wb_twilight", "󰖛")
    readonly property string thermometer: icon("device_thermostat", "󰔏")
    readonly property string theme: icon("format_paint", "󰏘")
    readonly property string trash: icon("delete", "󰆴")
    readonly property string visibility: icon("visibility", "󰈈")
    readonly property string visibilityOff: icon("visibility_off", "󰈉")
    readonly property string volumeDown: icon("volume_down", "󰕿")
    readonly property string volumeMuted: icon("volume_off", "󰖁")
    readonly property string volumeUp: icon("volume_up", "󰕾")
    readonly property string wallpaper: icon("wallpaper", "󰸉")
    readonly property string waterDrop: icon("water_drop", "󰖌")
    readonly property string weather: icon("partly_cloudy_day", "󰖕")
    readonly property string wind: icon("air", "󰖝")
    readonly property string wifi: icon("wifi", "󰖩")
    readonly property string wifiLow: icon("network_wifi_1_bar", "󰤟")
    readonly property string wifiMedium: icon("network_wifi_2_bar", "󰤢")
    readonly property string wifiHigh: icon("wifi", "󰤨")
    readonly property string wiredAudio: icon("speaker", "󰓃")

    function icon(material: string, nerd: string): string {
        return Typography.materialIcons ? material : nerd;
    }

    function bluetoothStatus(enabled: bool, connectedCount: int): string {
        return !enabled ? bluetoothDisabled : (connectedCount > 0 ? bluetoothConnected : bluetooth);
    }

    function network(kind: string, signal: int): string {
        if (kind === "wired")
            return ethernet;
        if (kind === "wifi") {
            if (signal >= 70)
                return wifiHigh;
            if (signal >= 40)
                return wifiMedium;
            return wifiLow;
        }
        return networkOff;
    }

    function audio(muted: bool, volume: int): string {
        return muted || volume === 0 ? volumeMuted : (volume >= 60 ? volumeUp : volumeDown);
    }

    function microphone(available: bool, muted: bool, volume: int): string {
        return !available || muted || volume === 0 ? micMuted : mic;
    }

    function audioDevice(kind: string): string {
        if (kind === "bluetooth" || kind === "headset")
            return "headphones";
        if (kind === "hdmi")
            return monitor;
        return wiredAudio;
    }
}
