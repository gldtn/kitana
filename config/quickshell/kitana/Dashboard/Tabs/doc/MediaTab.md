# Media Tab

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the dashboard tab content for date/time, media, settings, themes, wallpapers, and weather area.

MediaTab provides one tab of the dashboard experience.

## Project Structure and Dependencies

Source file: `Dashboard/Tabs/MediaTab.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Effects`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../Components"`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`, `import "../../Services" as Services`.

Referenced or instantiated by: `Dashboard/DashboardPanel.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `dashboard` | `var` | `null` | No | Provides component state or configuration for `dashboard`. |
| `root` | `readonly var` | `dashboard` | No | Read-only. Provides component state or configuration for `root`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.MediaService`, `Services.SystemStatus`.

## Usage Example

```qml
MediaTab {
}
```
