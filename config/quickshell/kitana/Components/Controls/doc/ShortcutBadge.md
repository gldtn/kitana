# Shortcut Badge

## Component Overview

ShortcutBadge is a keyboard shortcut compatibility wrapper over the shared Badge control.

## Project Structure and Dependencies

Source file: `Components/Controls/ShortcutBadge.qml`.

Qt imports: none directly.

Project imports: `import "../.."`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `string` | `""` | Badge label, usually a single shortcut key. |
| `badgeHeight` | `int` | `18` | Preferred badge height. |
| `horizontalPadding` | `int` | `5` | Per-side horizontal padding around the label. |
| `textPixelSize` | `int` | `root.defaultFontPixelSize()` | Label text size. |
| `backgroundColor` | `color` | `Colors.scrimSecondary` | Badge surface color. |
| `borderColor` | `color` | `Colors.borderLight` | Badge border color. |
| `tone` | `string` | `"subtle"` | Label text tone. |
