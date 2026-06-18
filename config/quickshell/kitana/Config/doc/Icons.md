# Icons

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the singleton design tokens for colors, icons, and typography area.

Icons is a singleton configuration object that provides shared design tokens or user-facing settings.

## Project Structure and Dependencies

Source file: `Config/Icons.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import ".." as Kitana`.

Referenced or instantiated by: `Bar/Items/Layout.qml`, `Bar/Items/Status.qml`, `Bar/StartMenu.qml`, `Components/Controls/Icon.qml`, `Components/Controls/PanelRow.qml`, `Config/Colors.qml`, `Dashboard/Components/MediaButton.qml`, `Dashboard/Components/MiniButton.qml`, `Dashboard/Components/TabButton.qml`, `Dashboard/Components/TodayFact.qml`, `Dashboard/Components/WeatherMetric.qml`, `Launcher/AppLauncher.qml`.

## Component Hierarchy and Role

The root type is `QtObject`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `defaultIcon` | `readonly string` | `"ui.unknown"` | No | Read-only. Stores the string value for `defaultIcon`. |
| `glyphs` | `readonly var` | `({` | No | Read-only. Provides component state or configuration for `glyphs`. |
| `sizes` | `readonly var` | `({` | No | Read-only. Provides component state or configuration for `sizes`. |

## Methods

#### glyph(name: string) : string

Performs component-specific behavior used internally or by parent components.

#### size(role: string) : int

Performs component-specific behavior used internally or by parent components.

#### toneColor(tone: string) : color

Performs component-specific behavior used internally or by parent components.

#### bluetoothName(enabled: bool, connectedCount: int) : string

Returns a semantic name used by the icon or display mapping.

#### caffeineName(enabled: bool) : string

Returns a semantic name used by the icon or display mapping.

#### networkName(kind: string, signal: int) : string

Returns a semantic name used by the icon or display mapping.

#### audioVolumeName(muted: bool, volume: int) : string

Returns a semantic name used by the icon or display mapping.

#### microphoneName(available: bool, muted: bool, volume: int) : string

Returns a semantic name used by the icon or display mapping.

#### notificationName(count: int, doNotDisturb: bool) : string

Returns a semantic name used by the icon or display mapping.

#### audioDeviceName(kind: string) : string

Returns a semantic name used by the icon or display mapping.

#### workspaceLayoutName(layoutName: string) : string

Returns a semantic name used by the icon or display mapping.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.
