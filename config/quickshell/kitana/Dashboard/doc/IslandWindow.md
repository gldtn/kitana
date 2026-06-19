# Island Window

## Component Overview

IslandWindow is the per-monitor collapsed dashboard island. It shows the reusable center date/time content on every bar monitor and only allows the focused monitor's island to open the shared dashboard panel.

## Project Structure and Dependencies

Source file: `Dashboard/IslandWindow.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`, `import Quickshell.Wayland`.

Project imports: `import "../Bar/Sections" as BarSections`, `import "../Services" as Services`.

Referenced or instantiated by: `shell.qml`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `panelScreen` | `var` | `null` | Screen that owns this island window. |
| `dashboardPanel` | `var` | `null` | Shared dashboard panel that expands from the active island. |
| `barVisible` | `bool` | `true` | Keeps the island in sync with bar visibility. |
| `screenName` | `readonly string` | computed | Name of `panelScreen`. |
| `focusedScreenName` | `readonly string` | computed | Name of the dashboard panel's focused screen. |
| `dashboardScreenName` | `readonly string` | computed | Name of the screen currently used by the expanded dashboard. |
| `focusedScreen` | `readonly bool` | computed | True when this island belongs to the compositor-focused monitor. |
| `lastDashboardScreen` | `readonly bool` | computed | True when this island belongs to the last monitor used by the dashboard. |
| `fallbackScreen` | `readonly bool` | computed | True when no focused monitor is known and this island belongs to the fallback screen. |
| `activeScreen` | `readonly bool` | computed | True when this island belongs to the focused monitor. |
| `hiddenByDashboard` | `readonly bool` | computed | Hides this island's content while its monitor is being used by the expanded dashboard. |
| `latchedHover` | `readonly bool` | computed | Keeps hover visuals active after close if the pointer stayed over this island. |
| `islandWidth` | `readonly int` | computed | Rounded collapsed island width. |
| `islandHeight` | `readonly int` | computed | Rounded collapsed island height. |
| `islandX` | `readonly int` | computed | Screen-local x coordinate for the island. |
| `islandY` | `readonly int` | computed | Screen-local y coordinate for the island. |

## Methods

#### toggleDashboard() : void

Opens or toggles the shared dashboard only when this island belongs to the focused monitor.

#### syncHoverState(hovered: bool) : void

Updates the shared dashboard hover latch when the island receives pointer enter or exit events.
