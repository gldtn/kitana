# Settings Tab

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the dashboard tab content for date/time, media, settings, themes, wallpapers, and weather area.

SettingsTab provides dashboard settings for wallpapers, weather, and world clocks.

## Project Structure and Dependencies

Source file: `Dashboard/Tabs/SettingsTab.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../Components"`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Dashboard/DashboardPanel.qml`.

## Component Hierarchy and Role

The root type is `ColumnLayout`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `dashboard` | `var` | `null` | No | Provides component state or configuration for `dashboard`. |
| `panel` | `readonly var` | `dashboard` | No | Read-only. Dashboard panel API used to update persisted weather and world-clock settings. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
SettingsTab {
}
```
