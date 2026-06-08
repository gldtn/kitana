// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io

Singleton {
    id: root

    readonly property BluetoothAdapter bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property bool bluetoothAvailable: bluetoothAdapter !== null
    readonly property bool bluetoothEnabled: bluetoothAdapter ? bluetoothAdapter.enabled : false
    readonly property bool bluetoothDiscovering: bluetoothAdapter ? bluetoothAdapter.discovering : false
    readonly property var bluetoothDevices: bluetoothAdapter && bluetoothAdapter.devices ? bluetoothAdapter.devices.values : []
    readonly property int bluetoothConnectedCount: {
        let count = 0;
        for (const device of bluetoothDevices) {
            if (device && device.connected)
                count++;
        }
        return count;
    }
    readonly property string bluetoothIcon: !bluetoothEnabled ? "󰂲" : (bluetoothConnectedCount > 0 ? "󰂱" : "󰂯")
    readonly property string bluetoothLabel: !bluetoothAvailable ? "none" : (!bluetoothEnabled ? "off" : (bluetoothConnectedCount > 0 ? bluetoothConnectedCount + "" : "on"))

    property string networkKind: "off"
    property string networkName: "off"
    property int networkSignal: 0
    property bool wifiEnabled: false
    property bool wifiScanning: false
    property var wifiNetworks: []
    readonly property string networkIcon: {
        if (networkKind === "wired")
            return "󰀂";
        if (networkKind === "wifi") {
            if (networkSignal >= 70)
                return "󰤨";
            if (networkSignal >= 40)
                return "󰤢";
            return "󰤟";
        }
        return "󰯡";
    }
    readonly property string networkLabel: networkKind === "off" ? "off" : networkName

    property bool audioMuted: false
    property int audioVolume: 0
    property string audioSink: ""
    property var audioSinks: []
    readonly property string audioIcon: audioMuted || audioVolume === 0 ? "" : (audioVolume >= 60 ? "" : "")
    readonly property string audioLabel: audioMuted ? "muted" : audioVolume + "%"

    property bool micAvailable: false
    property bool micMuted: false
    property int micVolume: 0
    property string micSourceId: ""
    property string micSource: ""
    readonly property string micIcon: !micAvailable ? "󰍭" : (micMuted || micVolume === 0 ? "󰍭" : "󰍬")
    readonly property string micLabel: !micAvailable ? "no mic" : (micMuted ? "muted" : micVolume + "%")

    property int brightness: 0
    property bool brightnessAvailable: false

    property string keyboardLayoutLabel: "US"
    property string keyboardLayoutLongLabel: "English (US)"

    function compactKeyboardLabel(keymap, layout, variant) {
        const normalizedKeymap = (keymap || "").toLowerCase();
        const normalizedLayout = (layout || "").toLowerCase();
        const normalizedVariant = (variant || "").toLowerCase();

        if (normalizedLayout === "br" || normalizedKeymap.indexOf("brazil") !== -1 || normalizedKeymap.indexOf("portuguese") !== -1)
            return "PT-BR";
        if (normalizedVariant === "intl" || normalizedKeymap.indexOf("intl") !== -1 || normalizedKeymap.indexOf("international") !== -1)
            return "US-INTL";
        if (normalizedLayout === "us" || normalizedKeymap.indexOf("english (us") !== -1)
            return "US";

        return (layout || keymap || "KB").toUpperCase().slice(0, 8);
    }

    function refresh() {
        audioPoll.exec(["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{ printf \"%s %d\", ($0 ~ /MUTED/ ? \"muted\" : \"volume\"), $2 * 100 }'"]);
        audioSinkPoll.exec(["sh", "-c", "wpctl status 2>/dev/null | awk '/Sinks:/ { s=1; next } s && /\\*/ { sub(/^.*\\* +[0-9]+\\. +/, \"\"); sub(/ \\[vol:.*$/, \"\"); print; exit }'"]);
        audioSinksPoll.exec(["sh", "-c", "wpctl status 2>/dev/null | awk '/Sinks:/ { s=1; next } s && /^[[:space:]]*[│├└ ]*[ *]*[0-9]+\\./ { line=$0; gsub(/^[^0-9]*/, \"\", line); sub(/ \\[vol:.*$/, \"\", line); print line } s && /Sources:/ { exit }'"]);
        micPoll.exec(["sh", "-c", "$HOME/.local/share/kitana/bin/kitana-audio-mic-status"]);
        networkPoll.exec(["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION dev status 2>/dev/null | awk -F: '$2==\"connected\" { print $1 \"|\" $3; found=1; exit } END { exit found ? 0 : 1 }' || { iface=$(ip route get 1.1.1.1 2>/dev/null | sed -n 's/.* dev \\([^ ]*\\).*/\\1/p'); [ -n \"$iface\" ] && printf 'ethernet|%s' \"$iface\"; }"]);
        wifiStatePoll.exec(["nmcli", "radio", "wifi"]);
        wifiPoll.exec(["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null | awk -F: '!seen[$2]++ && $2 != \"\" { print $1 \"|\" $2 \"|\" $3 \"|\" $4 }'"]);
        brightnessPoll.exec(["sh", "-c", "brightnessctl -c backlight -m 2>/dev/null | awk -F, '{ gsub(/%/, \"\", $4); print $4 }'"]);
        keyboardPoll.exec(["hyprctl", "devices", "-j"]);
    }

    function toggleBluetooth() {
        if (bluetoothAdapter)
            bluetoothAdapter.enabled = !bluetoothAdapter.enabled;
    }

    function toggleBluetoothScan() {
        if (bluetoothAdapter && bluetoothAdapter.enabled)
            bluetoothAdapter.discovering = !bluetoothAdapter.discovering;
    }

    function connectBluetoothDevice(device) {
        if (!device)
            return;
        if (device.connected)
            device.disconnect();
        else {
            device.trusted = true;
            device.connect();
        }
    }

    function toggleWifi() {
        wifiToggle.exec(["sh", "-c", "state=$(nmcli radio wifi 2>/dev/null); [ \"$state\" = enabled ] && nmcli radio wifi off || nmcli radio wifi on"]);
    }

    function scanWifi() {
        wifiScanning = true;
        wifiScan.exec(["sh", "-c", "dev=$(nmcli -t -f DEVICE,TYPE dev status 2>/dev/null | awk -F: '$2==\"wifi\" { print $1; exit }'); if [ -n \"$dev\" ]; then nmcli dev wifi rescan ifname \"$dev\" >/dev/null 2>&1 || true; else nmcli dev wifi rescan >/dev/null 2>&1 || true; fi; sleep 1"]);
    }

    function connectWifi(ssid) {
        if (!ssid)
            return;
        wifiConnect.exec(["nmcli", "dev", "wifi", "connect", ssid]);
    }

    function toggleAudioMute() {
        audioAction.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }

    function setAudioVolume(percent) {
        const clamped = Math.max(0, Math.min(100, Math.round(percent)));
        audioAction.exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", clamped + "%"]);
    }

    function setAudioSink(id) {
        if (!id)
            return;
        audioAction.exec(["wpctl", "set-default", id]);
    }

    function toggleMicMute() {
        if (micAvailable)
            micAction.exec(["pactl", "set-source-mute", micSourceId, "toggle"]);
    }

    function setMicVolume(percent) {
        if (!micAvailable)
            return;
        const clamped = Math.max(0, Math.min(100, Math.round(percent)));
        micAction.exec(["pactl", "set-source-volume", micSourceId, clamped + "%"]);
    }

    function setBrightness(percent) {
        const clamped = Math.max(1, Math.min(100, Math.round(percent)));
        brightnessAction.exec(["brightnessctl", "-c", "backlight", "set", clamped + "%"]);
    }

    function nextKeyboardLayout() {
        keyboardAction.exec(["hyprctl", "switchxkblayout", "all", "next"]);
    }

    Timer {
        interval: 2500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: audioPoll
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/);
                root.audioMuted = parts[0] === "muted";
                root.audioVolume = parts.length > 1 ? parseInt(parts[1]) : 0;
            }
        }
    }

    Process {
        id: audioSinkPoll
        stdout: StdioCollector {
            onStreamFinished: root.audioSink = text.trim() || "Default sink"
        }
    }

    Process {
        id: audioSinksPoll
        stdout: StdioCollector {
            onStreamFinished: {
                const sinks = [];
                for (const line of text.trim().split("\n")) {
                    if (!line)
                        continue;
                    const match = line.match(/^(\d+)\.\s*(.*)$/);
                    if (match)
                        sinks.push({ id: match[1], name: match[2] });
                }
                root.audioSinks = sinks;
            }
        }
    }

    Process {
        id: micPoll
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|");
                root.micAvailable = parts.length >= 4 && parts[0].length > 0;
                root.micSourceId = root.micAvailable ? parts[0] : "";
                root.micSource = root.micAvailable ? (parts[1] || "Default microphone") : "";
                root.micMuted = root.micAvailable && parts[2] === "yes";
                root.micVolume = root.micAvailable ? parseInt(parts[3] || "0") : 0;
            }
        }
    }

    Process {
        id: networkPoll
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|");
                const type = parts[0] || "off";
                root.networkKind = type === "wifi" ? "wifi" : (type === "ethernet" ? "wired" : "off");
                root.networkName = parts[1] || "off";
            }
        }
    }

    Process {
        id: wifiStatePoll
        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = text.trim() === "enabled"
        }
    }

    Process {
        id: wifiPoll
        stdout: StdioCollector {
            onStreamFinished: {
                const networks = [];
                let activeSignal = 0;
                for (const line of text.trim().split("\n")) {
                    if (!line)
                        continue;
                    const parts = line.split("|");
                    const item = { active: parts[0] === "yes", ssid: parts[1] || "", signal: parseInt(parts[2] || "0"), security: parts[3] || "" };
                    networks.push(item);
                    if (item.active)
                        activeSignal = item.signal;
                }
                root.wifiNetworks = networks;
                root.networkSignal = activeSignal;
            }
        }
    }

    Process {
        id: brightnessPoll
        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim();
                root.brightnessAvailable = value.length > 0;
                root.brightness = parseInt(value || "0");
            }
        }
    }

    Process {
        id: keyboardPoll
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const devices = JSON.parse(text.trim() || "{}");
                    const keyboards = devices.keyboards || [];
                    let keyboard = null;

                    for (const item of keyboards) {
                        if (item && item.main) {
                            keyboard = item;
                            break;
                        }
                    }

                    if (!keyboard && keyboards.length > 0)
                        keyboard = keyboards[0];
                    if (!keyboard)
                        return;

                    const index = keyboard.active_layout_index || 0;
                    const layouts = (keyboard.layout || "").split(",");
                    const variants = (keyboard.variant || "").split(",");
                    const layout = layouts[index] || layouts[0] || "";
                    const variant = variants[index] || "";
                    const keymap = keyboard.active_keymap || layout || "Keyboard";

                    root.keyboardLayoutLongLabel = keymap;
                    root.keyboardLayoutLabel = root.compactKeyboardLabel(keymap, layout, variant);
                } catch (error) {
                    root.keyboardLayoutLabel = "KB";
                    root.keyboardLayoutLongLabel = "Keyboard layout unavailable";
                }
            }
        }
    }

    Process { id: wifiToggle; onRunningChanged: if (!running) root.refresh() }
    Process { id: wifiScan; onRunningChanged: if (!running) { root.wifiScanning = false; root.refresh(); } }
    Process { id: wifiConnect; onRunningChanged: if (!running) root.refresh() }
    Process { id: audioAction; onRunningChanged: if (!running) root.refresh() }
    Process { id: micAction; onRunningChanged: if (!running) root.refresh() }
    Process { id: brightnessAction; onRunningChanged: if (!running) root.refresh() }
    Process { id: keyboardAction; onRunningChanged: if (!running) root.refresh() }
}
