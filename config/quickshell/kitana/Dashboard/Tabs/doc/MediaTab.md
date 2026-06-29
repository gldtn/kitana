# Media Tab

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the dashboard tab content for date/time, media, settings, themes, wallpapers, and weather area.

MediaTab provides the dashboard media player, including album art, MPRIS progress controls, transport actions, queue mode chips, and the audio output overlay.

## Project Structure and Dependencies

Source file: `Dashboard/Tabs/MediaTab.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Effects`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../Components"`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`, `import "../../Services" as Services`.

Referenced or instantiated by: `Dashboard/DashboardPanel.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide dashboard media playback controls.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `dashboard` | `var` | `null` | No | Provides component state or configuration for `dashboard`. |
| `panel` | `readonly var` | `dashboard` | No | Read-only. References the owning dashboard panel. |
| `mediaActive` | `readonly bool` | computed | No | Read-only. Tracks whether the media tab is currently visible. |
| `audioOverlayOpen` | `readonly bool` | computed | No | Read-only. Mirrors the dashboard audio overlay state. |
| `albumArtSource` | `readonly string` | `Services.MediaService.artSource()` | No | Read-only. Provides the resolved album art URL for the player hero. |
| `progressInset` | `readonly real` | `9` | No | Read-only. Aligns the progress rail and elapsed time labels. |

## Methods

#### closeAudioOverlay() : void

Closes the media tab audio output overlay on the owning dashboard panel.

#### toggleAudioOverlay() : void

Refreshes audio state and toggles the media tab audio output overlay.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.MediaService`, `Services.SystemStatus`.

Uses native Quickshell MPRIS state through `MediaService` for playback, progress, seeking, shuffle, and repeat controls.

## Usage Example

```qml
MediaTab {
}
```
