// Kitana managed Quickshell service

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import ".."

Singleton {
    id: root

    readonly property string kitanaDir: Quickshell.env("KITANA_DIR") || Quickshell.env("HOME") + "/.local/share/kitana"

    readonly property BluetoothAdapter bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property bool bluetoothAvailable: bluetoothAdapter !== null
    readonly property bool bluetoothEnabled: bluetoothAdapter ? bluetoothAdapter.enabled : false
    readonly property bool bluetoothDiscovering: bluetoothAdapter ? bluetoothAdapter.discovering : false
    readonly property var bluetoothDevices: bluetoothAdapter && bluetoothAdapter.devices ? bluetoothAdapter.devices.values : []
    readonly property var bluetoothSavedDevices: sortedBluetoothDevices(true)
    readonly property var bluetoothAvailableDevices: sortedBluetoothDevices(false)
    readonly property int bluetoothConnectedCount: {
        let count = 0;
        for (const device of bluetoothDevices) {
            if (device && device.connected)
                count++;
        }
        return count;
    }
    readonly property string bluetoothIconName: Icons.bluetoothName(bluetoothEnabled, bluetoothConnectedCount)
    readonly property string bluetoothLabel: !bluetoothAvailable ? "none" : (!bluetoothEnabled ? "off" : (bluetoothConnectedCount > 0 ? bluetoothConnectedCount + "" : "on"))
    property string bluetoothPendingPairAddress: ""
    property int bluetoothPairFinalizeAttempts: 0
    property int bluetoothPairAudioTicks: 0

    readonly property var networkDevices: Networking.devices ? Networking.devices.values : []
    readonly property var wifiDevice: networkDeviceByType(DeviceType.Wifi, false)
    readonly property var wiredDevice: networkDeviceByType(DeviceType.Wired, true)
    readonly property var activeWifiNetwork: connectedNetwork(wifiDevice)
    readonly property var activeWiredNetwork: connectedNetwork(wiredDevice)
    readonly property string networkKind: activeWifiNetwork ? "wifi" : (wiredDevice && wiredDevice.connected ? "wired" : "off")
    readonly property string networkName: activeWifiNetwork ? activeWifiNetwork.name : (networkKind === "wired" ? (activeWiredNetwork ? activeWiredNetwork.name : wiredDevice.name) : "off")
    readonly property int networkSignal: activeWifiNetwork ? Math.round(activeWifiNetwork.signalStrength * 100) : 0
    readonly property bool wifiEnabled: Networking.wifiHardwareEnabled && Networking.wifiEnabled
    readonly property bool wifiScanning: wifiScan.running
    readonly property var wifiNetworks: wifiNetworkItems()
    readonly property string networkIconName: Icons.networkName(networkKind, networkSignal)
    readonly property string networkLabel: networkKind === "off" ? "off" : networkName

    readonly property var pipewireNodes: Pipewire.nodes ? Pipewire.nodes.values : []
    readonly property var audioSinkNode: Pipewire.defaultAudioSink
    readonly property var micSourceNode: Pipewire.defaultAudioSource
    readonly property var pipewireAudioSinks: pipewireNodes.filter(node => root.isPipewireOutput(node))
    readonly property var pipewireTrackedObjects: {
        const objects = [];
        if (audioSinkNode)
            objects.push(audioSinkNode);
        if (micSourceNode)
            objects.push(micSourceNode);
        for (const node of pipewireAudioSinks) {
            if (node)
                objects.push(node);
        }
        return objects;
    }
    readonly property bool audioAvailable: audioSinkNode && audioSinkNode.audio
    readonly property bool audioMuted: audioAvailable ? audioSinkNode.audio.muted : false
    readonly property int audioVolume: audioAvailable ? Math.round(audioSinkNode.audio.volume * 100) : 0
    readonly property string audioSink: audioSinkNode ? audioNodeLabel(audioSinkNode) : "Default sink"
    readonly property int audioBitDepth: audioNodeBitDepth(audioSinkNode)
    property int audioSampleRate: 0
    readonly property string audioQualityLabel: audioQualityText(audioBitDepth, audioSampleRate)
    readonly property var audioSinks: pipewireAudioSinks.map(node => ({
        id: node.id,
        name: root.audioNodeLabel(node),
        iconName: root.audioNodeIconName(node),
        subtitle: root.audioNodeSubtitle(node)
    }))
    readonly property string audioIconName: Icons.audioVolumeName(audioMuted, audioVolume)
    readonly property string audioLabel: audioMuted ? "muted" : audioVolume + "%"

    readonly property bool micAvailable: micSourceNode && micSourceNode.audio && !isPipewireMonitor(micSourceNode)
    readonly property bool micMuted: micAvailable ? micSourceNode.audio.muted : false
    readonly property int micVolume: micAvailable ? Math.round(micSourceNode.audio.volume * 100) : 0
    readonly property string micSource: micAvailable ? audioNodeLabel(micSourceNode) : ""
    readonly property string micIconName: Icons.microphoneName(micAvailable, micMuted, micVolume)
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
        if (audioSinkNode)
            audioQualityPoll.exec(["pw-metadata", "-n", "settings", "0", "clock.rate"]);
        else
            audioSampleRate = 0;
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

        const address = device.address || "";
        if (!address)
            return;

        if (device.pairing) {
            device.cancelPair();
            bluetoothPendingPairAddress = "";
            bluetoothPairFinalizeAttempts = 0;
            bluetoothPairAudioTicks = 0;
        } else if (device.connected) {
            return;
        } else if (device.paired) {
            device.trusted = true;
            device.connect();
        } else {
            if (bluetoothPendingPairAddress === address)
                return;

            bluetoothPendingPairAddress = address;
            bluetoothPairFinalizeAttempts = 0;
            bluetoothPairAudioTicks = 0;
            bluetoothPairAction.exec([kitanaDir + "/bin/kitana-bluetooth-pair", address]);
            bluetoothPairFinalize.start();
        }
    }

    function disconnectBluetoothDevice(device) {
        if (!device || !device.connected)
            return;

        device.disconnect();
    }

    function forgetBluetoothDevice(device) {
        if (!device)
            return;

        const address = device.address || "";
        if (!address)
            return;

        if (device.pairing)
            device.cancelPair();
        device.forget();
        if (bluetoothPendingPairAddress === address)
            bluetoothPendingPairAddress = "";
        bluetoothPairFinalizeAttempts = 0;
        bluetoothPairAudioTicks = 0;
    }

    function bluetoothDeviceByAddress(address) {
        for (const device of bluetoothDevices) {
            if (device && device.address === address)
                return device;
        }

        return null;
    }

    function bluetoothDeviceSaved(device) {
        return device && (device.connected || device.paired || device.trusted);
    }

    function bluetoothDeviceTitle(device) {
        return device ? (device.name || device.deviceName || device.address || "Unknown device") : "Unknown device";
    }

    function sortedBluetoothDevices(savedOnly) {
        const items = [];
        for (const device of bluetoothDevices) {
            if (device && bluetoothDeviceSaved(device) === savedOnly)
                items.push(device);
        }

        return items.sort((left, right) => (right.connected - left.connected) || bluetoothDeviceTitle(left).localeCompare(bluetoothDeviceTitle(right)));
    }

    function bluetoothDeviceStatus(device) {
        if (!device)
            return "Available";

        const address = device.address || "";
        if (address && bluetoothPendingPairAddress === address) {
            if (bluetoothDeviceAudioActive(device))
                return "Connected";
            if (device.connected || device.paired || device.trusted)
                return "Connecting...";
            return "Pairing...";
        }

        if (device.pairing)
            return "Pairing...";
        if (device.connected)
            return "Connected";
        if (device.paired)
            return "Paired";
        if (device.trusted)
            return "Trusted";
        return "Available";
    }

    function bluetoothAddressFragment(address) {
        return (address || "").split(":").join("_").toLowerCase();
    }

    function bluetoothAudioSinkForDevice(device) {
        if (!device)
            return null;

        const address = (device.address || "").toUpperCase();
        const macFragment = bluetoothAddressFragment(address);
        for (const node of pipewireAudioSinks) {
            if (!node)
                continue;

            const props = node.properties || {};
            const nodeAddress = (props["api.bluez5.address"] || props["bluez5.address"] || "").toUpperCase();
            const name = (node.name || "").toLowerCase();

            if (address && nodeAddress === address)
                return node;
            if (macFragment && name.indexOf(macFragment) !== -1)
                return node;
        }

        return null;
    }

    function bluetoothDeviceAudioActive(device) {
        const sink = bluetoothAudioSinkForDevice(device);
        return sink && audioSinkNode && sink.id === audioSinkNode.id;
    }

    Timer {
        id: bluetoothPairFinalize
        interval: 500
        repeat: true
        onTriggered: {
            const device = root.bluetoothDeviceByAddress(root.bluetoothPendingPairAddress);
            if (!device) {
                stop();
                root.bluetoothPendingPairAddress = "";
                root.bluetoothPairFinalizeAttempts = 0;
                root.bluetoothPairAudioTicks = 0;
            } else if (bluetoothPairAction.running) {
                return;
            } else if (root.bluetoothDeviceAudioActive(device)) {
                root.bluetoothPairAudioTicks++;
                if (root.bluetoothPairAudioTicks >= 2) {
                    stop();
                    root.bluetoothPendingPairAddress = "";
                    root.bluetoothPairFinalizeAttempts = 0;
                    root.bluetoothPairAudioTicks = 0;
                }
            } else if (device.connected || device.paired || device.trusted) {
                root.bluetoothPairAudioTicks = 0;
                device.trusted = true;
                if (!device.connected && root.bluetoothPairFinalizeAttempts % 4 === 0)
                    device.connect();
                root.bluetoothPairFinalizeAttempts++;
                if (root.bluetoothPairFinalizeAttempts >= 40) {
                    stop();
                    root.bluetoothPendingPairAddress = "";
                    root.bluetoothPairFinalizeAttempts = 0;
                    root.bluetoothPairAudioTicks = 0;
                }
            } else if (!device.pairing && !bluetoothPairAction.running) {
                stop();
                root.bluetoothPendingPairAddress = "";
                root.bluetoothPairFinalizeAttempts = 0;
                root.bluetoothPairAudioTicks = 0;
            }
        }
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function scanWifi() {
        if (!Networking.wifiHardwareEnabled)
            return;

        if (!Networking.wifiEnabled)
            Networking.wifiEnabled = true;
        if (wifiDevice)
            wifiDevice.scannerEnabled = true;
        wifiScan.exec(["sh", "-c", "nmcli radio wifi on >/dev/null 2>&1 || true; sleep 1; nmcli dev wifi rescan >/dev/null 2>&1 || true; sleep 1"]);
    }

    function connectWifi(ssid) {
        if (!ssid)
            return;

        const network = wifiNetworkByName(ssid);
        if (!network || network.connected)
            return;

        if (network.known || network.security === WifiSecurityType.Open)
            network.connect();
        else
            wifiConnect.exec(["nmcli", "dev", "wifi", "connect", ssid]);
    }

    function networkDeviceByType(type, connectedOnly) {
        for (const device of networkDevices) {
            if (device && device.type === type && (!connectedOnly || device.connected))
                return device;
        }

        return null;
    }

    function connectedNetwork(device) {
        if (!device || !device.networks)
            return null;

        for (const network of device.networks.values) {
            if (network && network.connected)
                return network;
        }

        return null;
    }

    function wifiNetworkItems() {
        if (!wifiDevice || !wifiDevice.networks)
            return [];

        const items = [];
        const names = new Set();
        for (const network of wifiDevice.networks.values) {
            const ssid = network ? network.name : "";
            if (!ssid || names.has(ssid))
                continue;

            names.add(ssid);
            items.push({
                active: network.connected,
                ssid: ssid,
                signal: Math.round(network.signalStrength * 100),
                security: network.security === WifiSecurityType.Open ? "" : WifiSecurityType.toString(network.security)
            });
        }

        return items.sort((left, right) => (right.active - left.active) || (right.signal - left.signal) || left.ssid.localeCompare(right.ssid));
    }

    function wifiNetworkByName(ssid) {
        if (!wifiDevice || !wifiDevice.networks)
            return null;

        for (const network of wifiDevice.networks.values) {
            if (network && network.name === ssid)
                return network;
        }

        return null;
    }

    function toggleAudioMute() {
        if (audioAvailable)
            audioSinkNode.audio.muted = !audioSinkNode.audio.muted;
    }

    function setAudioVolume(percent) {
        const clamped = Math.max(0, Math.min(100, Math.round(percent)));
        if (audioAvailable)
            audioSinkNode.audio.volume = clamped / 100;
    }

    function setAudioSink(id) {
        const node = pipewireNodeById(id);
        if (node)
            Pipewire.preferredDefaultAudioSink = node;
    }

    function toggleMicMute() {
        if (micAvailable)
            micSourceNode.audio.muted = !micSourceNode.audio.muted;
    }

    function setMicVolume(percent) {
        if (!micAvailable)
            return;
        const clamped = Math.max(0, Math.min(100, Math.round(percent)));
        micSourceNode.audio.volume = clamped / 100;
    }

    function audioNodeLabel(node) {
        if (!node)
            return "Audio device";

        const props = node.properties || {};
        const description = props["node.description"] || node.description || "";
        if (description && description !== node.name)
            return description;

        const deviceDescription = props["device.description"] || "";
        if (deviceDescription)
            return deviceDescription;

        const nickname = node.nickname || "";
        if (nickname && nickname !== node.name)
            return nickname;

        const name = node.name || "";
        if (name.indexOf("bluez") !== -1)
            return "Bluetooth Audio";
        if (name.indexOf("usb") !== -1)
            return "USB Audio";
        if (name.indexOf("hdmi") !== -1)
            return "HDMI Audio";
        if (name.indexOf("analog-stereo") !== -1)
            return "Built-in Audio";

        return name || "Audio device";
    }

    function audioNodeBitDepth(node): int {
        if (!node)
            return 0;

        const props = node.properties || {};
        const bits = parseInt(props["alsa.resolution_bits"] || props["audio.bits"] || "0");
        if (bits > 0)
            return bits;

        const format = String(props["audio.format"] || "").toUpperCase();
        const match = format.match(/(?:S|U|F)(\d+)/);
        return match ? parseInt(match[1]) : 0;
    }

    function audioQualityText(bits: int, rate: int): string {
        const parts = [];
        if (bits > 0)
            parts.push(bits + "-bit");
        if (rate > 0)
            parts.push(formatSampleRate(rate));
        return parts.length > 0 ? parts.join(" / ") : "Audio Quality";
    }

    function formatSampleRate(rate: int): string {
        if (rate <= 0)
            return "";

        if (rate % 1000 === 0)
            return Math.round(rate / 1000) + " kHz";
        return (Math.round(rate / 100) / 10).toFixed(1) + " kHz";
    }

    function parseAudioSampleRate(text: string): int {
        const match = text.match(/key:'clock\.rate'\s+value:'([^']+)'/);
        if (!match)
            return 0;

        const rate = String(match[1]).match(/\d+/);
        return rate ? parseInt(rate[0]) : 0;
    }

    function audioNodeIconName(node) {
        if (!node)
            return "audio.output";

        const props = node.properties || {};
        const formFactor = (props["device.form-factor"] || "").toLowerCase();
        const bus = (props["device.bus"] || "").toLowerCase();
        const name = (node.name || "").toLowerCase();

        if (bus === "bluetooth" || name.indexOf("bluez") !== -1)
            return Icons.audioDeviceName("bluetooth");
        if (formFactor === "headphone" || formFactor === "headset" || formFactor === "hands-free" || formFactor === "handset")
            return Icons.audioDeviceName("headset");
        if (formFactor === "tv" || formFactor === "monitor" || name.indexOf("hdmi") !== -1)
            return Icons.audioDeviceName("hdmi");
        if (bus === "usb" || name.indexOf("usb") !== -1)
            return "audio.output";

        return "ui.check";
    }

    function audioNodeSubtitle(node) {
        if (!node)
            return "Output device";

        const props = node.properties || {};
        const formFactor = (props["device.form-factor"] || "").toLowerCase();
        const bus = (props["device.bus"] || "").toLowerCase();
        const name = (node.name || "").toLowerCase();

        if (bus === "bluetooth" || name.indexOf("bluez") !== -1)
            return "Bluetooth audio";
        if (formFactor === "headphone" || formFactor === "headset" || formFactor === "hands-free" || formFactor === "handset")
            return "Headset audio";
        if (formFactor === "tv" || formFactor === "monitor" || name.indexOf("hdmi") !== -1)
            return "HDMI audio";
        if (bus === "usb" || name.indexOf("usb") !== -1)
            return "USB audio";
        if (name.indexOf("analog") !== -1)
            return "Built-in audio";

        return "Output device";
    }

    function isPipewireOutput(node) {
        return node && node.audio && node.isSink && !node.isStream;
    }

    function isPipewireMonitor(node) {
        return node && (node.name || "").endsWith(".monitor");
    }

    function pipewireNodeById(id) {
        const numericId = parseInt(id);
        for (const node of pipewireNodes) {
            if (node && node.id === numericId)
                return node;
        }

        return null;
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

    PwObjectTracker { objects: root.pipewireTrackedObjects }

    Process {
        id: audioQualityPoll

        stdout: StdioCollector {
            onStreamFinished: {
                const rate = root.parseAudioSampleRate(text);
                if (rate > 0)
                    root.audioSampleRate = rate;
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

    Process { id: wifiConnect; onRunningChanged: if (!running) root.refresh() }
    Process { id: wifiScan; onRunningChanged: if (!running) root.refresh() }
    Process { id: bluetoothPairAction; onRunningChanged: if (!running) root.refresh() }
    Process { id: brightnessAction; onRunningChanged: if (!running) root.refresh() }
    Process { id: keyboardAction; onRunningChanged: if (!running) root.refresh() }
}
