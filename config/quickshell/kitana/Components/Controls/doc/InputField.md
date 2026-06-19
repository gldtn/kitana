# Input Field

## Component Overview

InputField is a reusable framed text input using the shared `Colors.input*` roles.

## Project Structure and Dependencies

Source file: `Components/Controls/InputField.qml`.

Qt imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | `alias` | `input.text` | Editable input text. |
| `placeholderText` | `string` | `""` | Placeholder text drawn by the control. |
| `echoMode` | `alias` | `input.echoMode` | Text echo mode for normal or password fields. |
| `inputFocus` | `alias` | `input.focus` | Forwards focus to the internal input. |
| `activeFocusOnTab` | inherited bool | `false` | Enables tab focus on the internal input. |
| `iconName` | `string` | `""` | Optional leading icon. |
| `fieldHeight` | `int` | `36` | Preferred and implicit field height. |
| `iconSize` | `int` | `settings.iconPixelSize` | Leading icon size. |
| `horizontalPadding` | `int` | `12` | Left and right content padding. |
| `textPixelSize` | `int` | `settings.textPixelSize` | Input text size. |
| `inputActiveFocus` | `readonly bool` | computed | True while the internal input has active focus. |

## Signals

#### accepted()

Emitted when Return is pressed.

#### escaped()

Emitted when Escape is pressed.

#### editingFinished()

Forwarded from the internal `TextInput`.

#### keyPressed(event)

Forwarded from the internal `TextInput` for panel-specific keyboard handling.

## Methods

#### forceActiveFocus(reason: var) : void

Focuses the internal `TextInput`.
