# Typography

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the singleton design tokens for colors, icons, and typography area.

Typography is part of the Config module and contributes UI or state to the Kitana Quickshell desktop shell.

## Project Structure and Dependencies

Source file: `Config/Typography.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`.

Referenced or instantiated by: `Bar/Items/ControlCluster.qml`, `Bar/Items/Layout.qml`, `Bar/Items/Workspaces.qml`, `Bar/StartMenu.qml`, `Components/Controls/Icon.qml`, `Components/Controls/KeyHintBar.qml`, `Components/Controls/PanelRow.qml`, `Dashboard/Components/DashboardField.qml`, `Dashboard/Components/IslandSummary.qml`, `Dashboard/Components/MediaDeviceRow.qml`, `Dashboard/Components/MiniButton.qml`, `Dashboard/Components/PickerFooter.qml`.

## Component Hierarchy and Role

The root type is `PersistentProperties`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `fontFamilies` | `readonly var` | `[` | No | Read-only. Provides component state or configuration for `fontFamilies`. |
| `fontFamily` | `string` | `"JetBrainsMono Nerd Font Propo"` | No | Stores the string value for `fontFamily`. |
| `iconFontFamily` | `readonly string` | `"JetBrainsMono Nerd Font Propo"` | No | Read-only. Stores the string value for `iconFontFamily`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
Typography {
}
```
