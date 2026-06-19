# System Status

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the Quickshell singleton services and process-backed state adapters area.

SystemStatus is a singleton service in the Services module that exposes shared state or command helpers to the rest of the shell.

## Project Structure and Dependencies

Source file: `Services/SystemStatus.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`, `import Quickshell.Bluetooth`, `import Quickshell.Io`, `import Quickshell.Networking`, `import Quickshell.Services.Pipewire`.

Project imports: `import ".."`.

Referenced or instantiated by: `Bar/Items/ControlCluster.qml`, `Dashboard/Components/VolumeSlider.qml`, `Dashboard/DashboardPanel.qml`, `Dashboard/Tabs/MediaTab.qml`, `System/Components/BluetoothDeviceRow.qml`, `System/Components/ControlSliders.qml`, `System/Components/QuickSettingsGrid.qml`, `System/Panes/AudioPane.qml`, `System/Panes/BluetoothPane.qml`, `System/Panes/NetworkPane.qml`, `System/Panes/SettingsPane.qml`, `System/ControlPanel.qml`.

## Component Hierarchy and Role

The root type is `Singleton`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `kitanaDir` | `readonly string` | `Quickshell.env("KITANA_DIR") \|\| Quickshell.env("HOME") + "/.local/share/kitana"` | No | Read-only. Stores the Kitana repository path used to call helper commands. |
| `bluetoothAdapter` | `readonly BluetoothAdapter` | `Bluetooth.defaultAdapter` | No | Read-only. Provides component state or configuration for `bluetoothAdapter`. |
| `bluetoothAvailable` | `readonly bool` | `bluetoothAdapter !== null` | No | Read-only. Enables or disables the `bluetoothAvailable` state. |
| `bluetoothEnabled` | `readonly bool` | `bluetoothAdapter ? bluetoothAdapter.enabled : false` | No | Read-only. Enables or disables the `bluetoothEnabled` state. |
| `bluetoothDiscovering` | `readonly bool` | `bluetoothAdapter ? bluetoothAdapter.discovering : false` | No | Read-only. Enables or disables the `bluetoothDiscovering` state. |
| `bluetoothDevices` | `readonly var` | `bluetoothAdapter && bluetoothAdapter.devices ? bluetoothAdapter.devices.values : []` | No | Read-only. Provides component state or configuration for `bluetoothDevices`. |
| `bluetoothSavedDevices` | `readonly var` | `sortedBluetoothDevices(true)` | No | Read-only. Provides component state or configuration for `bluetoothSavedDevices`. |
| `bluetoothAvailableDevices` | `readonly var` | `sortedBluetoothDevices(false)` | No | Read-only. Provides component state or configuration for `bluetoothAvailableDevices`. |
| `bluetoothConnectedCount` | `readonly int` | `{` | No | Read-only. Controls the numeric value for `bluetoothConnectedCount`. |
| `bluetoothIconName` | `readonly string` | `Icons.bluetoothName(bluetoothEnabled, bluetoothConnectedCount)` | No | Read-only. Stores the string value for `bluetoothIconName`. |
| `bluetoothLabel` | `readonly string` | `!bluetoothAvailable ? "none" : (!bluetoothEnabled ? "off" : (bluetoothConnectedCount > ...` | No | Read-only. Stores the string value for `bluetoothLabel`. |
| `bluetoothPendingPairAddress` | `string` | `""` | No | Stores the string value for `bluetoothPendingPairAddress`. |
| `bluetoothPairFinalizeAttempts` | `int` | `0` | No | Controls the numeric value for `bluetoothPairFinalizeAttempts`. |
| `bluetoothPairAudioTicks` | `int` | `0` | No | Controls the numeric value for `bluetoothPairAudioTicks`. |
| `networkDevices` | `readonly var` | `Networking.devices ? Networking.devices.values : []` | No | Read-only. Provides component state or configuration for `networkDevices`. |
| `wifiDevice` | `readonly var` | `networkDeviceByType(DeviceType.Wifi, false)` | No | Read-only. Provides component state or configuration for `wifiDevice`. |
| `wiredDevice` | `readonly var` | `networkDeviceByType(DeviceType.Wired, true)` | No | Read-only. Provides component state or configuration for `wiredDevice`. |
| `activeWifiNetwork` | `readonly var` | `connectedNetwork(wifiDevice)` | No | Read-only. Provides component state or configuration for `activeWifiNetwork`. |
| `activeWiredNetwork` | `readonly var` | `connectedNetwork(wiredDevice)` | No | Read-only. Provides component state or configuration for `activeWiredNetwork`. |
| `networkKind` | `readonly string` | `activeWifiNetwork ? "wifi" : (wiredDevice && wiredDevice.connected ? "wired" : "off")` | No | Read-only. Stores the string value for `networkKind`. |
| `networkName` | `readonly string` | `activeWifiNetwork ? activeWifiNetwork.name : (networkKind === "wired" ? (activeWiredNet...` | No | Read-only. Stores the string value for `networkName`. |
| `networkSignal` | `readonly int` | `activeWifiNetwork ? Math.round(activeWifiNetwork.signalStrength * 100) : 0` | No | Read-only. Controls the numeric value for `networkSignal`. |
| `wifiEnabled` | `readonly bool` | `Networking.wifiHardwareEnabled && Networking.wifiEnabled` | No | Read-only. Enables or disables the `wifiEnabled` state. |
| `wifiScanning` | `readonly bool` | `wifiScan.running` | No | Read-only. Enables or disables the `wifiScanning` state. |
| `wifiNetworks` | `readonly var` | `wifiNetworkItems()` | No | Read-only. Provides component state or configuration for `wifiNetworks`. |
| `networkIconName` | `readonly string` | `Icons.networkName(networkKind, networkSignal)` | No | Read-only. Stores the string value for `networkIconName`. |
| `networkLabel` | `readonly string` | `networkKind === "off" ? "off" : networkName` | No | Read-only. Stores the string value for `networkLabel`. |
| `pipewireNodes` | `readonly var` | `Pipewire.nodes ? Pipewire.nodes.values : []` | No | Read-only. Provides component state or configuration for `pipewireNodes`. |
| `audioSinkNode` | `readonly var` | `Pipewire.defaultAudioSink` | No | Read-only. Provides component state or configuration for `audioSinkNode`. |
| `micSourceNode` | `readonly var` | `Pipewire.defaultAudioSource` | No | Read-only. Provides component state or configuration for `micSourceNode`. |
| `pipewireAudioSinks` | `readonly var` | `pipewireNodes.filter(node => root.isPipewireOutput(node))` | No | Read-only. Provides component state or configuration for `pipewireAudioSinks`. |
| `pipewireTrackedObjects` | `readonly var` | `{` | No | Read-only. Provides component state or configuration for `pipewireTrackedObjects`. |
| `audioAvailable` | `readonly bool` | `audioSinkNode && audioSinkNode.audio` | No | Read-only. Enables or disables the `audioAvailable` state. |
| `audioMuted` | `readonly bool` | `audioAvailable ? audioSinkNode.audio.muted : false` | No | Read-only. Enables or disables the `audioMuted` state. |
| `audioVolume` | `readonly int` | `audioAvailable ? Math.round(audioSinkNode.audio.volume * 100) : 0` | No | Read-only. Controls the numeric value for `audioVolume`. |
| `audioSink` | `readonly string` | `audioSinkNode ? audioNodeLabel(audioSinkNode) : "Default sink"` | No | Read-only. Stores the string value for `audioSink`. |
| `audioSinks` | `readonly var` | `pipewireAudioSinks.map(node => ({` | No | Read-only. Provides component state or configuration for `audioSinks`. |
| `audioIconName` | `readonly string` | `Icons.audioVolumeName(audioMuted, audioVolume)` | No | Read-only. Stores the string value for `audioIconName`. |
| `audioLabel` | `readonly string` | `audioMuted ? "muted" : audioVolume + "%"` | No | Read-only. Stores the string value for `audioLabel`. |
| `micAvailable` | `readonly bool` | `micSourceNode && micSourceNode.audio && !isPipewireMonitor(micSourceNode)` | No | Read-only. Enables or disables the `micAvailable` state. |
| `micMuted` | `readonly bool` | `micAvailable ? micSourceNode.audio.muted : false` | No | Read-only. Enables or disables the `micMuted` state. |
| `micVolume` | `readonly int` | `micAvailable ? Math.round(micSourceNode.audio.volume * 100) : 0` | No | Read-only. Controls the numeric value for `micVolume`. |
| `micSource` | `readonly string` | `micAvailable ? audioNodeLabel(micSourceNode) : ""` | No | Read-only. Stores the string value for `micSource`. |
| `micIconName` | `readonly string` | `Icons.microphoneName(micAvailable, micMuted, micVolume)` | No | Read-only. Stores the string value for `micIconName`. |
| `micLabel` | `readonly string` | `!micAvailable ? "no mic" : (micMuted ? "muted" : micVolume + "%")` | No | Read-only. Stores the string value for `micLabel`. |
| `brightness` | `int` | `0` | No | Controls the numeric value for `brightness`. |
| `brightnessAvailable` | `bool` | `false` | No | Enables or disables the `brightnessAvailable` state. |
| `keyboardLayoutLabel` | `string` | `"US"` | No | Stores the string value for `keyboardLayoutLabel`. |
| `keyboardLayoutLongLabel` | `string` | `"English (US)"` | No | Stores the string value for `keyboardLayoutLongLabel`. |

## Methods

#### compactKeyboardLabel(keymap, layout, variant) : void

Performs component-specific behavior used internally or by parent components.

#### refresh() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

#### toggleBluetooth() : void

Performs component-specific behavior used internally or by parent components.

#### toggleBluetoothScan() : void

Performs component-specific behavior used internally or by parent components.

#### connectBluetoothDevice(device) : void

Performs component-specific behavior used internally or by parent components.

#### disconnectBluetoothDevice(device) : void

Performs component-specific behavior used internally or by parent components.

#### forgetBluetoothDevice(device) : void

Performs component-specific behavior used internally or by parent components.

#### bluetoothDeviceByAddress(address) : void

Performs component-specific behavior used internally or by parent components.

#### bluetoothDeviceSaved(device) : void

Performs component-specific behavior used internally or by parent components.

#### bluetoothDeviceTitle(device) : void

Performs component-specific behavior used internally or by parent components.

#### sortedBluetoothDevices(savedOnly) : void

Performs component-specific behavior used internally or by parent components.

#### bluetoothDeviceStatus(device) : void

Performs component-specific behavior used internally or by parent components.

#### bluetoothAddressFragment(address) : void

Performs component-specific behavior used internally or by parent components.

#### bluetoothAudioSinkForDevice(device) : void

Performs component-specific behavior used internally or by parent components.

#### bluetoothDeviceAudioActive(device) : void

Performs component-specific behavior used internally or by parent components.

#### toggleWifi() : void

Performs component-specific behavior used internally or by parent components.

#### scanWifi() : void

Performs component-specific behavior used internally or by parent components.

#### connectWifi(ssid) : void

Performs component-specific behavior used internally or by parent components.

#### networkDeviceByType(type, connectedOnly) : void

Performs component-specific behavior used internally or by parent components.

#### connectedNetwork(device) : void

Performs component-specific behavior used internally or by parent components.

#### wifiNetworkItems() : void

Performs component-specific behavior used internally or by parent components.

#### wifiNetworkByName(ssid) : void

Returns a semantic name used by the icon or display mapping.

#### toggleAudioMute() : void

Performs component-specific behavior used internally or by parent components.

#### setAudioVolume(percent) : void

Performs component-specific behavior used internally or by parent components.

#### setAudioSink(id) : void

Performs component-specific behavior used internally or by parent components.

#### toggleMicMute() : void

Performs component-specific behavior used internally or by parent components.

#### setMicVolume(percent) : void

Performs component-specific behavior used internally or by parent components.

#### audioNodeLabel(node) : void

Performs component-specific behavior used internally or by parent components.

#### audioNodeIconName(node) : void

Returns a semantic name used by the icon or display mapping.

#### audioNodeSubtitle(node) : void

Performs component-specific behavior used internally or by parent components.

#### isPipewireOutput(node) : void

Returns a boolean answer for the requested condition.

#### isPipewireMonitor(node) : void

Returns a boolean answer for the requested condition.

#### pipewireNodeById(id) : void

Performs component-specific behavior used internally or by parent components.

#### setBrightness(percent) : void

Performs component-specific behavior used internally or by parent components.

#### nextKeyboardLayout() : void

Updates keyboard selection or page state used by navigation.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.Pipewire`.

Uses PipeWire service objects for audio device or node state.

Starts external commands through Quickshell process helpers or `Process` objects.
