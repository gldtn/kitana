# Media Service

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the Quickshell singleton services and process-backed state adapters area.

MediaService is a singleton service in the Services module that exposes active MPRIS player metadata, progress state, and playback command helpers to the rest of the shell.

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
| `maxTrackLength` | `readonly real` | `24 * 60 * 60` | No | Read-only. Maximum sane track duration in seconds accepted for progress display. |
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
| `canSeek` | `readonly bool` | computed | No | Read-only. Indicates whether absolute progress seeking is available. |
| `hasProgress` | `readonly bool` | computed | No | Read-only. Indicates whether track length and progress are available. |
| `position` | `readonly real` | computed | No | Read-only. Current playback position in seconds. |
| `length` | `readonly real` | computed | No | Read-only. Current track length in seconds. |
| `progress` | `readonly real` | computed | No | Read-only. Normalized playback progress from 0 to 1. |
| `positionLabel` | `readonly string` | computed | No | Read-only. Formatted current playback position. |
| `lengthLabel` | `readonly string` | computed | No | Read-only. Formatted current track length. |
| `shuffleSupported` | `readonly bool` | computed | No | Read-only. Indicates whether the active player supports shuffle. |
| `shuffle` | `readonly bool` | computed | No | Read-only. Indicates whether shuffle is active. |
| `loopSupported` | `readonly bool` | computed | No | Read-only. Indicates whether the active player supports loop mode. |
| `loopState` | `readonly int` | computed | No | Read-only. Active MPRIS loop state. |
| `looping` | `readonly bool` | computed | No | Read-only. Indicates whether a non-off loop mode is active. |
| `loopLabel` | `readonly string` | computed | No | Read-only. Human-readable repeat mode label. |

## Methods

#### preferredPlayer() : var

Performs component-specific behavior used internally or by parent components.

#### artSource() : string

Performs component-specific behavior used internally or by parent components.

#### clamp(value: real, minimum: real, maximum: real) : real

Constrains a numeric value to the supplied range.

#### saneDuration(seconds: real) : bool

Returns whether an MPRIS duration is finite, positive, and short enough to display as a normal track.

#### formatTime(seconds: real) : string

Formats seconds as an elapsed media time label.

#### refreshPosition() : void

Emits the active player's position change signal while the media UI is monitoring progress.

#### setPosition(ratio: real) : void

Seeks the active player to a normalized position from 0 to 1 when supported.

#### toggleShuffle() : void

Toggles shuffle on the active player when supported.

#### cycleLoop() : void

Cycles the active player repeat mode through off, playlist, and track when supported.

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
