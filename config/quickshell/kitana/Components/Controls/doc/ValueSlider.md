# Value Slider

## Component Overview

ValueSlider is the shared Kitana slider control for percentage-like values such as volume, microphone gain, and brightness.

## Project Structure And Dependencies

Source file: `Components/Controls/ValueSlider.qml`.

Qt imports: `import QtQuick`, `import QtQuick.Controls.Basic as QtControls`.

Project imports: `import "../.."`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `trackColor` | `color` | `Colors.subtleSecondary` | Background rail color. |
| `fillColor` | `color` | `Colors.fgAccent` | Filled rail color. |
| `handleColor` | `color` | `fillColor` | Circular handle color. |
| `trackHeight` | `int` | `6` | Rail height in pixels. |
| `handleSize` | `int` | `16` | Handle diameter in pixels. |

The component inherits `QtControls.Slider`, including `from`, `to`, `value`, `moved`, and `enabled`.
