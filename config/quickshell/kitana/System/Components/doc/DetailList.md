# Detail List

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable system panel controls and rows area.

DetailList is a reusable System component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `System/Components/DetailList.qml`.

Qt and Quickshell imports: `import QtQuick`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

Referenced or instantiated by: `System/Panes/AudioPane.qml`, `System/Panes/NetworkPane.qml`.

## Component Hierarchy and Role

The root type is `Column`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `title` | `string` | `""` | No | Stores the primary label shown by the component. |
| `emptyText` | `string` | `""` | No | Stores the string value for `emptyText`. |
| `modelData` | `var` | `[]` | No | Receives the model value supplied by a delegate model. |
| `delegateComponent` | `Component` | None | No | Provides component state or configuration for `delegateComponent`. |
| `headerComponent` | `Component` | `null` | No | Provides component state or configuration for `headerComponent`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

## Usage Example

```qml
DetailList {
    title: ""
}
```
