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
| `colorVariant` | `string` | `"subtle"` | Color variant: `primary`, `secondary`, `subtle`, `ghost`, or `accent`. |
| `surfaceVariant` | `string` | `"default"` | Surface context for color tuning. Use `tertiary` when the badge sits on `Colors.bgTertiary`. |
| `hasBorder` | `bool` | `false` | Adds a fractional border around the badge without changing the fill. |
| `rounded` | `bool` | `false` | Uses pill radius instead of compact badge radius. |
| `icon` | `string` | `""` | Optional leading semantic icon token. |
| `trailingIcon` | `string` | `""` | Optional trailing semantic icon token. |
| `textVerticalOffset` | `real` | `0.5` for `xs`, otherwise `0` | Visual text baseline offset for optical centering. |
| `iconVerticalOffset` | `real` | `-0.5` for `xs`, otherwise `0` | Visual icon offset for optical centering. |

Use `colorVariant: "ghost"` with `hasBorder: true` for a transparent outlined badge. The component also exposes sizing and color override properties such as `badgeHeight`, `horizontalPadding`, `fontPixelSize`, `backgroundColor`, `foregroundColor`, `borderColor`, `borderWidth`, and `iconTone` for compatibility wrappers and special cases.
