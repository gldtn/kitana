# Panel Header

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the reusable system panel controls and rows area.

PanelHeader is a reusable System component used to compose panel content consistently.

## Project Structure and Dependencies

Source file: `System/Components/PanelHeader.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`.

Project imports: `import "../.."`, `import "../../Components/Controls" as Controls`, `import "../../custom" as Custom`, `import "../../Services" as Services`.

Referenced or instantiated by: `System/SystemPanel.qml`.

## Component Hierarchy and Role

The root type is `Row`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panel` | `var` | `null` | No | Provides component state or configuration for `panel`. |

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.NotificationService`.

## Usage Example

```qml
PanelHeader {
}
```
