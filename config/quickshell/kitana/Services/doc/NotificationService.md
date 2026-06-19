# Notification Service

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the Quickshell singleton services and process-backed state adapters area.

NotificationService is a singleton service in the Services module that exposes shared state or command helpers to the rest of the shell.

## Project Structure and Dependencies

Source file: `Services/NotificationService.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`, `import Quickshell.Services.Notifications`.

Project imports: `import ".."`.

Referenced or instantiated by: `Bar/Items/ControlCluster.qml`, `Notifications/NotificationPopups.qml`, `Settings/SettingsPanel.qml`, `System/Components/NotificationRow.qml`, `System/Components/PanelHeader.qml`, `System/Components/QuickSettingsGrid.qml`, `System/Panes/NotificationsPane.qml`, `System/Panes/SettingsPane.qml`, `shell.qml`.

## Component Hierarchy and Role

The root type is `Singleton`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `doNotDisturb` | `bool` | `false` | No | Enables or disables the `doNotDisturb` state. |
| `notifications` | `var` | `[]` | No | Provides component state or configuration for `notifications`. |
| `popups` | `var` | `[]` | No | Provides component state or configuration for `popups`. |
| `collapsedGroups` | `var` | `({})` | No | Provides component state or configuration for `collapsedGroups`. |
| `nextId` | `int` | `1` | No | Controls the numeric value for `nextId`. |
| `count` | `readonly int` | `notifications.length` | No | Read-only. Stores the current number of tracked items. |

## Methods

#### dismiss(item) : void

Performs component-specific behavior used internally or by parent components.

#### dismissLast() : void

Performs component-specific behavior used internally or by parent components.

#### clear() : void

Performs component-specific behavior used internally or by parent components.

#### toggleDoNotDisturb() : void

Performs component-specific behavior used internally or by parent components.

#### groupKey(appName: string) : string

Performs component-specific behavior used internally or by parent components.

#### isGroupCollapsed(appName: string) : bool

Returns a boolean answer for the requested condition.

#### toggleGroup(appName: string) : void

Performs component-specific behavior used internally or by parent components.

#### appCount(appName: string) : int

Performs component-specific behavior used internally or by parent components.

#### visibleNotifications() : var

Performs component-specific behavior used internally or by parent components.

#### timeAgo(time) : string

Performs component-specific behavior used internally or by parent components.

#### escapeMarkup(value) : string

Performs component-specific behavior used internally or by parent components.

#### linkify(value) : string

Performs component-specific behavior used internally or by parent components.

#### tone(item) : string

Performs component-specific behavior used internally or by parent components.

#### toneForeground(item) : color

Performs component-specific behavior used internally or by parent components.

#### toneBackground(item) : color

Performs component-specific behavior used internally or by parent components.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.Notifications`.
