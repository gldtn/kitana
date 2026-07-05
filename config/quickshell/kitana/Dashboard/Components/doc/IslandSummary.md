# Island Summary

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the collapsed dashboard island content area.

IslandSummary renders the collapsed dashboard island summary. It shows date, time, and weather by default, then switches to a compact Cava media visualizer while media is playing. Right-clicking the collapsed island cycles between automatic, forced date/time, and forced media visualizer modes.

## Project Structure and Dependencies

Source file: `Dashboard/Components/IslandSummary.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`, `import Kitana.Cava as KitanaCava`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../Services" as Services`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Dashboard/DashboardPanel.qml`.

## Component Hierarchy and Role

The root type is `Item`. It owns the fallback clock/weather row, the media visualizer row, and hover-only media metadata/controls. The media visualizer keeps the same fixed-width bar count in compact and expanded states. Hover metadata and controls fade in after the card starts expanding to avoid visible text stretching. Long media title and artist labels use a clipped marquee with soft edge fades. The island surface, mask, background, and broad click handling stay in `Dashboard/DashboardPanel.qml`.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `dashboardPanel` | `var` | `null` | No | Supplies dashboard weather data and formatting helpers used by the collapsed island summary. |
| `summaryMode` | `string` | `"auto"` | No | Local mode override: `auto`, `datetime`, or `media`. |
| `mediaDetailsRevealed` | `bool` | `false` | No | Delays hover detail opacity until the expanded card has room for text and controls. |
| `weatherCondition` | `readonly var` | computed | No | First current weather condition from dashboard weather data. |
| `weatherTemperature` | `readonly string` | computed | No | Current temperature formatted through the dashboard unit preference. |
| `weatherVisible` | `readonly bool` | computed | No | Shows or hides weather content when current weather data is available. |
| `mediaVisible` | `readonly bool` | computed | No | Uses the media visualizer summary while `MediaService` reports active playback. |
| `mediaExpanded` | `readonly bool` | computed | No | Expands the media summary on hover to show title, artist, and quick controls. |
| `spectrumActive` | `readonly bool` | computed | No | Runs the local Cava provider only while media is playing and the dashboard is collapsed. |
| `mediaInset` | `readonly int` | computed | No | Reuses dashboard spacing as expanded media content padding. |
| `spectrumVisibleBarCount` | `readonly int` | computed | No | Keeps the compact and expanded Cava bar count aligned. |

## Inter-Component Interactions

Reads weather state from the owning `DashboardPanel`, playback state from `MediaService`, and renders shared Kitana icon, color, and typography roles. Media controls call `MediaService.previous()`, `MediaService.playPause()`, and `MediaService.next()`. `DashboardPanel` calls `cycleSummaryMode()` on compact right-click and reads `compactOpenTab` for left-click routing.
