# Tabs

## Component Overview

Tabs is a reusable Flux-inspired tab selector with default underline tabs, segmented tabs, pill tabs, optional icons, and compact sizing.

## Project Structure and Dependencies

Source file: `Components/Controls/Tabs.qml`.

Qt imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../custom" as Custom`, `import "../../Services" as Services`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `model` | `var` | `[]` | Tab objects or strings. Object fields: `value`, `label`, `iconName`, `trailingIconName`, `enabled`, and `accent`. |
| `currentValue` | `string` | `""` | Currently selected tab value. |
| `variant` | `string` | `"default"` | Tab style: `default`, `segmented`, or `pills`. |
| `iconPosition` | `string` | `"leading"` | Icon layout: `leading` or `top`. |
| `small` | `bool` | `false` | Uses compact tab height and text size. |
| `showIcons` | `bool` | `true` | Shows tab icons when `iconName` is set. |
| `showLabels` | `bool` | `true` | Shows tab labels. |
| `equalWidth` | `bool` | `true` | Makes tabs share available width equally. |

## Signals

#### activated(value)

Emitted when a tab is clicked.
