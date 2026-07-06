# Popup Backdrop

## Component Overview

`PopupBackdrop` is a reusable modal scrim and click-away dismissal layer for in-panel popups.

## Source

`Components/Controls/PopupBackdrop.qml`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `open` | `bool` | `false` | Controls backdrop opacity and whether backdrop clicks are accepted. |
| `rendered` | `bool` | `open` | Keeps the backdrop instantiated while a closing animation finishes. |
| `closeOnBackdropClick` | `bool` | `true` | Enables dismissing from clicks on the scrim. |
| `scrimColor` | `color` | `Colors.alpha(Colors.bgPrimary, 0.7)` | Scrim color drawn across the backdrop. |
| `scrimRadius` | `real` | `0` | Corner radius for in-card modal use. |
| `fadeDuration` | `int` | `140` | Opacity animation duration in milliseconds. |

## Signals

| Signal | Description |
|--------|-------------|
| `dismissed()` | Emitted when the backdrop click target requests dismissal. |
