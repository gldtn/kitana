# Center

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable center island content used by the dashboard island area.

Center shows the date/time by default and swaps to a centered dashboard icon on hover inside the collapsed dashboard island.

## Project Structure and Dependencies

Source file: `Bar/Sections/Center.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../Items" as Items`, `import "../../Components/Controls" as Controls`, `import "../../Services" as Services`, `import "../../custom" as Custom`.

Referenced or instantiated by: `Dashboard/DashboardPanel.qml`.

## Component Hierarchy and Role

The root type is `Item`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `dashboardPanel` | `var` | `null` | No | Receives the shared dashboard panel instance used by bar controls to open dashboard tabs. |
| `panelScreen` | `var` | `null` | No | Selects the Quickshell screen or monitor that owns this window or bar instance. |
| `sourceX` | `real` | `0` | No | Screen-local x coordinate of the center island pill. |
| `sourceY` | `real` | `0` | No | Screen-local y coordinate of the center island pill. |
| `embedded` | `bool` | `false` | No | Switches the component into shared-pill mode so its own background is suppressed by a parent container. |
| `interactive` | `bool` | `true` | No | Enables the hover cursor and dashboard icon affordance. |
| `hovered` | `bool` | `false` | No | Allows parent windows with their own mouse target to drive hover visuals. |
| `forceDashboardIcon` | `bool` | `false` | No | Forces the dashboard icon state for non-interactive morph previews. |
| `hideWhenDashboardActive` | `bool` | `true` | No | Allows parent-owned island previews to stay visible while the dashboard morph begins. |
| `dashboardActive` | `readonly bool` | computed | No | Read-only. Hides standalone center islands while the dashboard panel is active. |
| `dashboardIconVisible` | `readonly bool` | computed | No | Read-only. Shows the hover-only dashboard icon in place of date/time. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
Center {
    embedded: false
}
```
