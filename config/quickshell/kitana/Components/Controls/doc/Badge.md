# Badge

## Component Overview

Badge is the shared Kitana badge control for compact labels, statuses, keyboard shortcuts, and labeled metadata.

## Project Structure And Dependencies

Source file: `Components/Controls/Badge.qml`.

Qt imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `string` | `""` | Badge label. |
| `size` | `string` | `"sm"` | Size variant: `xs`, `sm`, `md`, or `lg`. |
| `colorVariant` | `string` | `"subtle"` | Color variant: `primary`, `secondary`, `tertiary`, `subtle`, `ghost`, `inverted`, or `accent`. |
| `outline` | `bool` | `false` | Uses transparent fill with variant border and foreground colors. |
| `rounded` | `bool` | `false` | Uses pill radius instead of compact badge radius. |
| `icon` | `string` | `""` | Optional leading semantic icon token. |
| `trailingIcon` | `string` | `""` | Optional trailing semantic icon token. |

The component also exposes sizing and color override properties such as `badgeHeight`, `horizontalPadding`, `fontPixelSize`, `backgroundColor`, `foregroundColor`, `borderColor`, and `iconTone` for compatibility wrappers and special cases.
