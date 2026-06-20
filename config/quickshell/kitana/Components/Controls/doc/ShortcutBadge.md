# Shortcut Badge

## Component Overview

ShortcutBadge is a reusable static keyboard shortcut label with subtle background and border roles.

## Project Structure and Dependencies

Source file: `Components/Controls/ShortcutBadge.qml`.

Qt imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `string` | `""` | Badge label, usually a single shortcut key. |
| `badgeHeight` | `int` | `18` | Preferred badge height. |
| `horizontalPadding` | `int` | `10` | Total horizontal padding added around the label. |
| `textPixelSize` | `int` | `settings.textPixelSize - 2` | Label text size. |
| `backgroundColor` | `color` | `Colors.subtleSecondary` | Badge surface color. |
| `borderColor` | `color` | `Colors.borderFaint` | Badge border color. |
| `tone` | `string` | `"secondary"` | Label icon/text tone. |
