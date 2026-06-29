# Segmented Tabs

## Component Overview

SegmentedTabs is a reusable segmented selector with optional icons, equal-width segments, and compact sizing.

## Project Structure and Dependencies

Source file: `Components/Controls/SegmentedTabs.qml`.

Qt imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../custom" as Custom`, `import "../../Services" as Services`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `model` | `var` | `[]` | Segment objects or strings. Object fields: `value`, `label`, `iconName`, `enabled`. |
| `currentValue` | `string` | `""` | Currently selected segment value. |
| `small` | `bool` | `false` | Uses compact segment height and text size. |
| `showIcons` | `bool` | `true` | Shows segment icons when `iconName` is set. |
| `showLabels` | `bool` | `true` | Shows segment labels. |
| `equalWidth` | `bool` | `true` | Makes segments share available width equally. |

## Signals

#### activated(value)

Emitted when a segment is clicked.
