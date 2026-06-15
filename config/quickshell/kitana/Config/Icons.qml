// Kitana managed Quickshell icon tokens

pragma Singleton

import QtQuick
import ".." as Kitana

QtObject {
    readonly property string defaultIcon: "ui.unknown"

    readonly property var glyphs: ({
        "brand.arch": "",

        "launcher.apps": "󰍉",
        "panel.open": "󰅂",
        "panel.close": "󰅁",

        "dashboard": "",
        "clock": "󰥔",
        "calendar": "󰃭",
        "calculator": "󰃬",
        "search": "󰍉",
        "settings": "󰒓",
        "theme": "󰏘",
        "wallpaper": "󰸉",
        "brightness": "󰃠",

        "caffeine.on": "󰾪",
        "caffeine.off": "󰅶",

        "audio.output": "󰓃",
        "audio.output.wired": "󰓃",
        "audio.headphones": "󰋋",
        "audio.display": "󰍹",
        "audio.volume.high": "",
        "audio.volume.medium": "",
        "audio.volume.low": "",
        "audio.volume.muted": "",
        "audio.mic": "󰍬",
        "audio.mic.muted": "󰍭",

        "network.off": "󰖪",
        "network.wifi": "󰖩",
        "network.wifi.high": "󰤨",
        "network.wifi.medium": "󰤢",
        "network.wifi.low": "󰤟",
        "network.wifi.off": "󰖪",
        "network.wired": "󰀂",

        "bluetooth.on": "󰂯",
        "bluetooth.connected": "󰂱",
        "bluetooth.off": "󰂲",
        "bluetooth.disconnect": "󰌸",
        "bluetooth.scan": "󰓦",

        "battery.full": "󰁹",
        "battery.high": "󰂁",
        "battery.medium": "󰁾",
        "battery.low": "󰁻",
        "battery.empty": "󰂎",
        "battery.charging": "󰂄",

        "notifications.on": "󰂚",
        "notifications.active": "󱅫",
        "notifications.off": "󰂛",
        "notifications.dismiss.all": "󰎟",

        "media.default": "󰝚",
        "media.play": "󰐊",
        "media.pause": "󰏤",
        "media.stop": "󰓛",
        "media.previous": "󰒮",
        "media.next": "󰒭",
        "media.refresh": "󰑐",

        "power.power": "󰐥",
        "power.lock": "󰌾",
        "power.logout": "󰍃",
        "power.reboot": "󰜉",
        "power.shutdown": "󰐥",
        "power.suspend": "󰤄",

        "workspace.layout": "󰕰",
        "workspace.layout.dwindle": "󰕮",
        "workspace.layout.scrolling": "󰜎",

        "display.monitor": "󰍹",
        "input.keyboard": "󰌌",

        "screenshot.default": "󰄀",
        "screenshot.window": "",
        "screenshot.region": "󰩭",
        "screenshot.clipboard": "󰅇",

        "weather.default": "󰖕",
        "weather.sunrise": "󰖜",
        "weather.sunset": "󰖛",
        "weather.moon": "",
        "weather.wind": "󰖝",
        "weather.thermometer": "󰔏",
        "weather.water": "󰖌",
        "weather.pressure": "󰓅",
        "weather.visibility": "󰈈",
        "weather.visibility.off": "󰈉",

        "ui.close": "󰅖",
        "ui.check": "󰄬",
        "ui.chevron.down": "󰅀",
        "ui.chevron.up": "󰅃",
        "ui.chevron.left": "󰅁",
        "ui.chevron.right": "󰅂",
        "ui.delete": "󰆴",
        "ui.refresh": "󰑐",
        "ui.scan": "󰓦",
        "ui.visibility": "󰈈",
        "ui.visibility.off": "󰈉",
        "ui.unknown": "󰋗"
    })

    readonly property var sizes: ({
        "bar": 14,
        "button": 16,
        "tile": 18,
        "panel": 22,
        "hero": 32
    })

    function glyph(name: string): string {
        const value = glyphs[name];
        if (value)
            return value;

        console.warn("Unknown icon:", name);
        return glyphs[defaultIcon];
    }

    function size(role: string): int {
        const value = sizes[role];
        if (value)
            return value;

        console.warn("Unknown icon size role:", role);
        return sizes["button"];
    }

    function toneColor(tone: string): color {
        if (tone === "primary")
            return Kitana.Colors.iconPrimary;
        if (tone === "secondary")
            return Kitana.Colors.iconSecondary;
        if (tone === "muted")
            return Kitana.Colors.iconMuted;
        if (tone === "subtle")
            return Kitana.Colors.iconSubtle;
        if (tone === "accent")
            return Kitana.Colors.iconAccent;
        if (tone === "onAccent")
            return Kitana.Colors.iconOnAccent;
        if (tone === "inverse")
            return Kitana.Colors.iconInverse;
        if (tone === "brand")
            return Kitana.Colors.iconBrand;
        if (tone === "disabled")
            return Kitana.Colors.iconDisabled;
        if (tone === "danger")
            return Kitana.Colors.iconDanger;

        console.warn("Unknown icon tone:", tone);
        return Kitana.Colors.iconPrimary;
    }

    function bluetoothName(enabled: bool, connectedCount: int): string {
        return !enabled ? "bluetooth.off" : (connectedCount > 0 ? "bluetooth.connected" : "bluetooth.on");
    }

    function caffeineName(enabled: bool): string {
        return enabled ? "caffeine.on" : "caffeine.off";
    }

    function networkName(kind: string, signal: int): string {
        if (kind === "wired")
            return "network.wired";
        if (kind === "wifi") {
            if (signal >= 70)
                return "network.wifi.high";
            if (signal >= 40)
                return "network.wifi.medium";
            return "network.wifi.low";
        }
        return "network.off";
    }

    function audioVolumeName(muted: bool, volume: int): string {
        if (muted || volume === 0)
            return "audio.volume.muted";
        if (volume >= 67)
            return "audio.volume.high";
        if (volume >= 34)
            return "audio.volume.medium";
        return "audio.volume.low";
    }

    function microphoneName(available: bool, muted: bool, volume: int): string {
        return !available || muted || volume === 0 ? "audio.mic.muted" : "audio.mic";
    }

    function notificationName(count: int, doNotDisturb: bool): string {
        if (doNotDisturb)
            return "notifications.off";
        return count > 0 ? "notifications.active" : "notifications.on";
    }

    function audioDeviceName(kind: string): string {
        if (kind === "bluetooth" || kind === "headset")
            return "audio.headphones";
        if (kind === "hdmi")
            return "audio.display";
        return "audio.output.wired";
    }

    function workspaceLayoutName(layoutName: string): string {
        return layoutName === "scrolling" ? "workspace.layout.scrolling" : "workspace.layout.dwindle";
    }
}
