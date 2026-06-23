# Action Tile

## Component Overview

ActionTile is a reusable centered action tile with an icon, title, subtitle, and shortcut badge.

## Project Structure and Dependencies

Source file: `Components/Controls/ActionTile.qml`.

Qt imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `iconName` | `string` | `Icons.defaultIcon` | Icon token to render. |
| `shortcut` | `string` | `""` | Shortcut text shown in the badge. |
| `title` | `string` | `""` | Primary action label. |
| `subtitle` | `string` | `""` | Secondary action label. |

## Signals

#### clicked()

Emitted when the action tile is clicked.
