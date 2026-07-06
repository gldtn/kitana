# Numeric Stepper

## Component Overview

`NumericStepper` is a compact rounded decrement/value/increment control for integer, fractional, and percentage values.

## Source

`Components/Controls/NumericStepper.qml`

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `value` | `real` | `0` | Current numeric value. |
| `minimum` | `real` | `0` | Lower bound for decrement actions. |
| `maximum` | `real` | `100` | Upper bound for increment actions. |
| `step` | `real` | `1` | Amount added or removed per click. |
| `decimals` | `int` | `0` | Decimal places shown for non-percentage values. |
| `suffix` | `string` | `" px"` | Text appended to non-percentage values. |
| `percentage` | `bool` | `false` | Displays the value as a rounded percentage when true. |
| `controlWidth` | `int` | `142` | Preferred control width. |
| `canDecrease` | `bool` | derived | True when the current value is above `minimum`. |
| `canIncrease` | `bool` | derived | True when the current value is below `maximum`. |

## Signals

| Signal | Description |
|--------|-------------|
| `valueRequested(real requestedValue)` | Emitted when the user clicks decrement or increment. |
