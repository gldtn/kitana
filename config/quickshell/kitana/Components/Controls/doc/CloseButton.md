# Close Button

## Component Overview

CloseButton is a reusable Kitana dismiss control for close, clear, and notification dismiss actions.

## Project Structure and Dependencies

Source file: `Components/Controls/CloseButton.qml`.

Qt imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `variant` | `string` | `"subtle"` | Selects the default hover color and icon tones. Supported values are `subtle`, `dark`, and `light`. |
| `iconName` | `string` | `"ui.close"` | Icon token to render. |
| `buttonSize` | `int` | `22` | Square button size. |
| `iconSize` | `int` | `13` | Icon pixel size. |
| `normalColor` | `color` | `transparent` | Background color when idle. |
| `hoverColor` | `color` | variant default | Background color on hover. |
| `normalTone` | `string` | variant default | Icon tone when idle. |
| `hoverTone` | `string` | variant default | Icon tone on hover. |
| `hovered` | `readonly bool` | computed | True while the pointer is over the button. |

## Signals

#### clicked()

Emitted when the close button is clicked.
