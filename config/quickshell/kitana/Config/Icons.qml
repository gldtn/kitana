// Kitana managed Quickshell icon tokens

pragma Singleton

import QtQuick

QtObject {
    readonly property string appSearch: "󰍉"
    readonly property string arch: ""
    readonly property string audioOutput: "󰓃"
    readonly property string bluetooth: "󰂯"
    readonly property string bluetoothConnected: "󰂱"
    readonly property string bluetoothDisabled: "󰂲"
    readonly property string brightness: "󰃠"
    readonly property string calendar: "󰃭"
    readonly property string check: "󰄬"
    readonly property string chevronLeft: "󰅁"
    readonly property string chevronRight: "󰅂"
    readonly property string close: "󰅖"
    readonly property string dashboard: "󰕮"
    readonly property string deleteForever: "󰆴"
    readonly property string disconnect: "󰌸"
    readonly property string ethernet: "󰀂"
    readonly property string keyboard: "󰌌"
    readonly property string lock: "󰌾"
    readonly property string logout: "󰍃"
    readonly property string media: "󰝚"
    readonly property string mic: "󰍬"
    readonly property string micMuted: "󰍭"
    readonly property string monitor: "󰍹"
    readonly property string moon: ""
    readonly property string networkOff: "󰖪"
    readonly property string notifications: "󰂚"
    readonly property string notificationsActive: "󱅫"
    readonly property string notificationsOff: "󰂛"
    readonly property string palette: "󰏘"
    readonly property string pause: "󰏤"
    readonly property string play: "󰐊"
    readonly property string power: "󰐥"
    readonly property string pressure: "󰓅"
    readonly property string previous: "󰒮"
    readonly property string next: "󰒭"
    readonly property string refresh: "󰑐"
    readonly property string restart: "󰜉"
    readonly property string scan: "󰓦"
    readonly property string settings: "󰒓"
    readonly property string shutdown: "󰐥"
    readonly property string stop: "󰓛"
    readonly property string sunrise: "󰖜"
    readonly property string sunset: "󰖛"
    readonly property string thermometer: "󰔏"
    readonly property string theme: "󰏘"
    readonly property string trash: "󰆴"
    readonly property string visibility: "󰈈"
    readonly property string visibilityOff: "󰈉"
    readonly property string volumeDown: "󰖀"
    readonly property string volumeMuted: "󰖁"
    readonly property string volumeUp: "󰕾"
    readonly property string wallpaper: "󰸉"
    readonly property string waterDrop: "󰖌"
    readonly property string weather: "󰖕"
    readonly property string wind: "󰖝"
    readonly property string wifi: "󰖩"
    readonly property string wifiLow: "󰤟"
    readonly property string wifiMedium: "󰤢"
    readonly property string wifiHigh: "󰤨"
    readonly property string wiredAudio: "󰓃"

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

    function notification(count: int, doNotDisturb: bool): string {
        if (doNotDisturb)
            return notificationsOff;
        return count > 0 ? notificationsActive : notifications;
    }

    function audioDevice(kind: string): string {
        if (kind === "bluetooth" || kind === "headset")
            return "headphones";
        if (kind === "hdmi")
            return monitor;
        return wiredAudio;
    }
}
