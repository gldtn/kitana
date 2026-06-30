# Island Summary

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the collapsed dashboard island content area.

IslandSummary renders the compact date, time, and weather summary shown inside the dashboard island.

## Project Structure and Dependencies

Source file: `Dashboard/Components/IslandSummary.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../Services" as Services`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Dashboard/DashboardPanel.qml`.

## Component Hierarchy and Role

The root type is `Item`. It owns only the summary row; the island surface, mask, background, click handling, and hover dashboard icon stay in `Dashboard/DashboardPanel.qml`.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `dashboardPanel` | `var` | `null` | No | Supplies dashboard weather data and formatting helpers used by the collapsed island summary. |
| `weatherCondition` | `readonly var` | computed | No | First current weather condition from dashboard weather data. |
| `weatherTemperature` | `readonly string` | computed | No | Current temperature formatted through the dashboard unit preference. |
| `weatherVisible` | `readonly bool` | computed | No | Shows or hides weather content when current weather data is available. |

## Inter-Component Interactions

Reads weather state from the owning `DashboardPanel` and renders shared Kitana icon, color, and typography roles.
