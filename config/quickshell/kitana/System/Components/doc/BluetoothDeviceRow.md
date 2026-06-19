# Bluetooth Device Row

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable control panel controls and rows area.

BluetoothDeviceRow is a reusable System component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `System/Components/BluetoothDeviceRow.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`, `import "../../Services" as Services`.

Referenced or instantiated by: `System/Panes/BluetoothPane.qml`.

## Component Hierarchy and Role

The root type is `Rectangle`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `modelData` | `var` | None | Yes | Receives the model value supplied by a delegate model. |
| `saved` | `readonly bool` | `modelData.paired \|\| modelData.trusted` | No | Read-only. Enables or disables the `saved` state. |
| `title` | `readonly string` | `modelData.name \|\| modelData.deviceName \|\| modelData.address \|\| "Unknown device"` | No | Read-only. Stores the primary label shown by the component. |
| `subtitle` | `readonly string` | `Services.SystemStatus.bluetoothDeviceStatus(modelData)` | No | Read-only. Stores secondary explanatory text shown by the component. |
| `actionButton` | `readonly var` | `disconnectButton.visible ? disconnectButton : (forgetButton.visible ? forgetButton : null)` | No | Read-only. Provides component state or configuration for `actionButton`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.SystemStatus`.

## Usage Example

```qml
BluetoothDeviceRow {
    modelData: null
}
```
