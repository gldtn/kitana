# Nav List Sidebar

## Component Overview

`NavListSidebar` is a reusable Flux-inspired vertical navigation list for settings and panel sidebars.

## Source

`Components/Controls/NavListSidebar.qml`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `string` | `""` | Sidebar title shown above the grouped nav list. |
| `currentValue` | `string` | `""` | Value of the currently active item. |
| `model` | `var` | `[]` | Section model. Each section may provide `heading` and `items`. |
| `sidebarWidth` | `int` | `218` | Preferred sidebar width. |

## Signals

| Signal | Description |
|--------|-------------|
| `activated(string value)` | Emitted when an enabled nav item is clicked. |

## Model Shape

Each section object may include:

| Field | Description |
|-------|-------------|
| `heading` | Optional uppercase/group label. |
| `items` | Array of nav items. |

Each item may include:

| Field | Description |
|-------|-------------|
| `value` | Stable page or route identifier. |
| `label` | Visible item label. |
| `iconName` | Kitana icon token. |
| `enabled` | Optional boolean enabled state. |
| `badge` | Optional compact badge text. |
