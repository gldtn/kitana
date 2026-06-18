# App Search Service

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the Quickshell singleton services and process-backed state adapters area.

AppSearchService is a singleton service in the Services module that exposes shared state or command helpers to the rest of the shell.

## Project Structure and Dependencies

Source file: `Services/AppSearchService.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`, `import Quickshell.Io`.

Project imports: `import ".."`.

Referenced or instantiated by: `Launcher/AppLauncher.qml`.

## Component Hierarchy and Role

The root type is `Singleton`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `applications` | `var` | `[]` | No | Provides component state or configuration for `applications`. |
| `usage` | `var` | `({})` | No | Provides component state or configuration for `usage`. |
| `maxSearchResults` | `readonly int` | `14` | No | Read-only. Controls the numeric value for `maxSearchResults`. |
| `maxBrowseResults` | `readonly int` | `60` | No | Read-only. Controls the numeric value for `maxBrowseResults`. |
| `kitanaDir` | `readonly string` | `Quickshell.env("KITANA_DIR") \|\| Quickshell.env("HOME") + "/.local/share/kitana"` | No | Read-only. Stores the Kitana repository path used to call helper commands. |
| `usagePath` | `readonly string` | `(Quickshell.env("HOME") \|\| "") + "/.local/state/kitana/quickshell-launcher-usage.json"` | No | Read-only. Stores the string value for `usagePath`. |

## Methods

#### refresh() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

#### loadUsage() : void

Performs component-specific behavior used internally or by parent components.

#### saveUsage() : void

Performs component-specific behavior used internally or by parent components.

#### recordLaunch(item) : void

Performs component-specific behavior used internally or by parent components.

#### isVisible(app) : bool

Returns a boolean answer for the requested condition.

#### normalize(value) : string

Performs component-specific behavior used internally or by parent components.

#### tokenize(value) : var

Performs component-specific behavior used internally or by parent components.

#### wordBoundaryMatch(value, query) : bool

Performs component-specific behavior used internally or by parent components.

#### score(app, query) : int

Performs component-specific behavior used internally or by parent components.

#### textScore(text, query) : int

Performs component-specific behavior used internally or by parent components.

#### appUsageKey(app) : string

Performs component-specific behavior used internally or by parent components.

#### actionUsageKey(app, action) : string

Performs component-specific behavior used internally or by parent components.

#### frecencyBoost(usageKey) : int

Performs component-specific behavior used internally or by parent components.

#### appItem(app, appScore) : var

Performs component-specific behavior used internally or by parent components.

#### appActionItems(app, query, appScore) : var

Performs component-specific behavior used internally or by parent components.

#### sessionItems(query) : var

Performs component-specific behavior used internally or by parent components.

#### evaluateExpression(expression) : var

Performs component-specific behavior used internally or by parent components.

#### peek() : void

Performs component-specific behavior used internally or by parent components.

#### take(type) : void

Performs component-specific behavior used internally or by parent components.

#### parseFactor() : void

Performs component-specific behavior used internally or by parent components.

#### parseTerm() : void

Performs component-specific behavior used internally or by parent components.

#### parseExpression() : void

Performs component-specific behavior used internally or by parent components.

#### calculatorItem(query) : var

Performs component-specific behavior used internally or by parent components.

#### search(query) : var

Performs component-specific behavior used internally or by parent components.

#### onApplicationsChanged() : void

Performs component-specific behavior used internally or by parent components.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.
