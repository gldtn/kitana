# Date Time Tab

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the dashboard tab content for date/time, media, settings, themes, wallpapers, and weather area.

DateTimeTab provides one tab of the dashboard experience.

## Project Structure and Dependencies

Source file: `Dashboard/Tabs/DateTimeTab.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../Components"`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Dashboard/DashboardPanel.qml`.

## Component Hierarchy and Role

The root type is `RowLayout`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `dashboard` | `var` | `null` | No | Provides component state or configuration for `dashboard`. |
| `panel` | `readonly var` | `dashboard` | No | Read-only. Dashboard panel API used by the tab. |
| `weather` | `readonly var` | `panel ? panel.weather : ({})` | No | Read-only. Provides component state or configuration for `weather`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
DateTimeTab {
}
```
