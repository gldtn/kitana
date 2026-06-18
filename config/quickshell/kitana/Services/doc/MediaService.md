# Media Service

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the Quickshell singleton services and process-backed state adapters area.

MediaService is a singleton service in the Services module that exposes shared state or command helpers to the rest of the shell.

## Project Structure and Dependencies

Source file: `Services/MediaService.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`, `import Quickshell.Services.Mpris`.

Referenced or instantiated by: `Dashboard/DashboardPanel.qml`, `Dashboard/Tabs/MediaTab.qml`.

## Component Hierarchy and Role

The root type is `Singleton`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `players` | `readonly var` | `Mpris.players.values \|\| []` | No | Read-only. Provides component state or configuration for `players`. |
| `activePlayer` | `readonly var` | `preferredPlayer()` | No | Read-only. Provides component state or configuration for `activePlayer`. |
| `available` | `readonly bool` | `activePlayer !== null` | No | Read-only. Enables or disables the `available` state. |
| `playing` | `readonly bool` | `available && activePlayer.isPlaying` | No | Read-only. Enables or disables the `playing` state. |
| `status` | `readonly string` | `!available ? "Stopped" : (playing ? "Playing" : "Paused")` | No | Read-only. Stores the string value for `status`. |
| `playerName` | `readonly string` | `available ? (activePlayer.identity \|\| activePlayer.desktopEntry \|\| "Media") : "Media"` | No | Read-only. Stores the string value for `playerName`. |
| `title` | `readonly string` | `available ? (activePlayer.trackTitle \|\| "Unknown Track") : "Nothing Playing"` | No | Read-only. Stores the primary label shown by the component. |
| `artist` | `readonly string` | `available ? (activePlayer.trackArtist \|\| "Unknown Artist") : ""` | No | Read-only. Stores the string value for `artist`. |
| `album` | `readonly string` | `available ? (activePlayer.trackAlbum \|\| "") : ""` | No | Read-only. Stores the string value for `album`. |
| `artUrl` | `readonly string` | `available ? (activePlayer.trackArtUrl \|\| "") : ""` | No | Read-only. Stores the string value for `artUrl`. |
| `canPrevious` | `readonly bool` | `available && activePlayer.canGoPrevious` | No | Read-only. Enables or disables the `canPrevious` state. |
| `canNext` | `readonly bool` | `available && activePlayer.canGoNext` | No | Read-only. Enables or disables the `canNext` state. |
| `canStop` | `readonly bool` | `available && activePlayer.canControl` | No | Read-only. Enables or disables the `canStop` state. |
| `canTogglePlaying` | `readonly bool` | `available && activePlayer.canTogglePlaying` | No | Read-only. Enables or disables the `canTogglePlaying` state. |

## Methods

#### preferredPlayer() : var

Performs component-specific behavior used internally or by parent components.

#### artSource() : string

Performs component-specific behavior used internally or by parent components.

#### previous() : void

Updates keyboard selection or page state used by navigation.

#### playPause() : void

Performs component-specific behavior used internally or by parent components.

#### stop() : void

Performs component-specific behavior used internally or by parent components.

#### next() : void

Updates keyboard selection or page state used by navigation.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.Mpris`.

Uses MPRIS media player data.
