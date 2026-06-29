# Dashboard Panel

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the dashboard panel shell and dashboard-wide state area.

DashboardPanel is the shared layer-shell panel window that expands from the active monitor's per-monitor island.

## Project Structure and Dependencies

Source file: `Dashboard/DashboardPanel.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`, `import Qt.labs.folderlistmodel`, `import Quickshell`, `import Quickshell.Hyprland`, `import Quickshell.Io`, `import Quickshell.Wayland`.

Project imports: `import ".."`, `import "../Bar/Sections" as BarSections`, `import "../Components/Controls" as Controls`, `import "../custom" as Custom`, `import "../Services" as Services`, `import "./Components" as Dashboard`, `import "./Tabs" as Tabs`.

Referenced or instantiated by: `shell.qml`.

## Component Hierarchy and Role

The root type is `PanelWindow`. It owns the expanded dashboard and morph animation, while `Dashboard/IslandWindow.qml` owns the always-visible collapsed islands on each monitor.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panelSelf` | `readonly var` | `root` | No | Read-only. Provides component state or configuration for `panelSelf`. |
| `panelVisible` | `bool` | `false` | No | Tracks whether the panel window should be visible. |
| `closing` | `bool` | `false` | No | Tracks whether the island is reversing back into the center pill. |
| `morphProgress` | `real` | `0` | No | Controls the numeric value for the island morph animation. |
| `fallbackScreen` | `var` | `null` | No | First-screen fallback used before Hyprland focused monitor data is available. |
| `panelScreen` | `var` | `null` | No | Selects the Quickshell screen or monitor that owns this window or bar instance. |
| `sourceX` | `real` | `0` | No | Screen-local x coordinate passed by a collapsed island. |
| `sourceY` | `real` | `Services.UiPreferences.topMargin + (...)` | No | Screen-local y coordinate passed by a collapsed island. |
| `sourceWidth` | `real` | `240` | No | Width of the center island pill used as the collapsed dashboard size. |
| `sourceHeight` | `real` | `Services.UiPreferences.pillHeight` | No | Height of the center island pill used as the collapsed dashboard size. |
| `activeTab` | `string` | `"datetime"` | No | Tracks which tab is currently selected. |
| `wallpapers` | `var` | `[]` | No | Provides component state or configuration for `wallpapers`. |
| `themes` | `var` | `[]` | No | Provides component state or configuration for `themes`. |
| `weatherStatus` | `string` | `"Loading weather..."` | No | Stores the string value for `weatherStatus`. |
| `weather` | `var` | `({})` | No | Provides component state or configuration for `weather`. |
| `weatherLocation` | `alias` | `weatherPreferences.location` | No | Exposes an internal child property through the `weatherLocation` alias. |
| `weatherUnits` | `alias` | `weatherPreferences.units` | No | Exposes an internal child property through the `weatherUnits` alias. |
| `wallpaperPage` | `int` | `0` | No | Controls the numeric value for `wallpaperPage`. |
| `wallpaperPageSize` | `int` | `12` | No | Controls the numeric value for `wallpaperPageSize`. |
| `wallpaperCurrentIndex` | `int` | `0` | No | Controls the numeric value for `wallpaperCurrentIndex`. |
| `themePage` | `int` | `0` | No | Controls the numeric value for `themePage`. |
| `themePageSize` | `int` | `6` | No | Controls the numeric value for `themePageSize`. |
| `themeCurrentIndex` | `int` | `0` | No | Controls the numeric value for `themeCurrentIndex`. |
| `pickerQuery` | `string` | `""` | No | Stores the string value for `pickerQuery`. |
| `pickerSearchActive` | `bool` | `false` | No | Enables or disables the `pickerSearchActive` state. |
| `pickerHelpVisible` | `bool` | `false` | No | Enables or disables the `pickerHelpVisible` state. |
| `compactHoverLatched` | `bool` | `false` | No | Keeps compact island hover visuals stable while the dashboard closes under a stationary pointer. |
| `kitanaDir` | `string` | `Quickshell.env("KITANA_DIR") \|\| Quickshell.env("HOME") + "/.local/share/kitana"` | No | Stores the Kitana repository path used to call helper commands. |
| `wallpaperDir` | `string` | `Quickshell.env("KITANA_WALLPAPER_DIR") \|\| Quickshell.env("HOME") + "/.config/kitana/wal...` | No | Stores the wallpaper directory used by wallpaper pickers. |
| `currentTime` | `date` | `new Date()` | No | Provides component state or configuration for `currentTime`. |
| `calendarMonth` | `date` | `new Date(currentTime.getFullYear(), currentTime.getMonth(), 1)` | No | Provides component state or configuration for `calendarMonth`. |
| `firstClockTime` | `string` | `"--"` | No | Stores the string value for `firstClockTime`. |
| `firstClockDate` | `string` | `""` | No | Stores the string value for `firstClockDate`. |
| `secondClockTime` | `string` | `"--"` | No | Stores the string value for `secondClockTime`. |
| `secondClockDate` | `string` | `""` | No | Stores the string value for `secondClockDate`. |
| `mediaAudioOverlayOpen` | `bool` | `false` | No | Enables or disables the `mediaAudioOverlayOpen` state. |
| `islandActive` | `readonly bool` | `panelVisible` | No | Read-only. Indicates that the dashboard island is expanded or morphing open. |
| `expandedSurface` | `readonly bool` | computed | No | Switches the island window between compact and full-screen input modes. |
| `focusedScreen` | `readonly var` | computed | No | Maps Hyprland's focused monitor to a Quickshell screen. |
| `activeScreen` | `readonly var` | computed | No | Screen currently used by the collapsed or expanded island. |
| `activeScreenWidth` | `readonly int` | computed | No | Width of `activeScreen`, with a fallback for early startup. |
| `activeScreenHeight` | `readonly int` | computed | No | Height of `activeScreen`, with a fallback for early startup. |
| `collapsedWidth` | `readonly real` | computed | No | Width of the collapsed dashboard island. |
| `collapsedHeight` | `readonly real` | computed | No | Height of the collapsed dashboard island. |
| `collapsedX` | `readonly real` | computed | No | Screen-local x coordinate for the collapsed island. |
| `collapsedY` | `readonly real` | computed | No | Screen-local y coordinate for the collapsed island. |
| `compactX` | `readonly int` | computed | No | Rounded x coordinate used by both the closing card and compact layer-shell margin. |
| `compactY` | `readonly int` | computed | No | Rounded y coordinate used by both the closing card and compact layer-shell margin. |
| `compactWidth` | `readonly int` | computed | No | Rounded width used by both the closing card and compact layer-shell surface. |
| `compactHeight` | `readonly int` | computed | No | Rounded height used by both the closing card and compact layer-shell surface. |
| `expandedWidth` | `readonly real` | computed | No | Width of the expanded dashboard card. |
| `expandedHeight` | `readonly real` | computed | No | Height of the expanded dashboard card. |
| `expandedX` | `readonly real` | computed | No | Screen-local x coordinate for the expanded dashboard card. |
| `expandedTopMargin` | `readonly real` | computed | No | Screen-local top coordinate for the expanded dashboard card. |
| `collapsedRadius` | `readonly real` | computed | No | Radius used by the collapsed island. |
| `expandedRadius` | `readonly real` | `18` | No | Radius used by the expanded dashboard card. |
| `contentOpacity` | `readonly real` | computed | No | Read-only. Fades the expanded dashboard content in after the island grows. |
| `previewOpacity` | `readonly real` | computed | No | Read-only. Fades the collapsed island clock preview out during the morph. |

## Methods

#### lerp(from: real, to: real, progress: real) : real

Interpolates between two numeric values for dashboard island morph geometry.

#### animateTo(progress: real) : void

Starts the island morph animation toward the requested progress value.

#### compactContains(x: real, y: real) : bool

Returns whether a full-screen click landed inside the compact island bounds.

#### setCompactHoverLatched(value: bool) : void

Stores whether compact island hover visuals should stay active during dashboard close handoff.

#### updateCompactHover(x: real, y: real) : void

Updates `compactHoverLatched` from full-screen dashboard pointer coordinates.

#### reopenFromCompact() : void

Reopens the dashboard from its compact island geometry while a close animation is still running.

#### screenForMonitor(monitor: var) : var

Returns the Quickshell screen whose name matches the focused Hyprland monitor.

#### open(tab: string, sourceScreen: var, x: var, y: var, width: var, height: var) : void

Opens the dashboard on the requested screen, or the current focused screen when called through IPC. Width and height are used to match the active collapsed island.

#### close() : void

Closes the component and resets transient state used while visible.

#### toggle(tab: string, sourceScreen: var, x: var, y: var, width: var, height: var) : void

Toggles the component between open and closed states, often preserving or selecting a requested section.

#### focusPanel() : void

Performs component-specific behavior used internally or by parent components.

#### refreshTab() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

#### refreshMedia() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

#### updateMediaVisual() : void

Performs component-specific behavior used internally or by parent components.

#### refreshWeather() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

#### basename(path: string) : string

Performs component-specific behavior used internally or by parent components.

#### fileUrl(path: string) : string

Performs component-specific behavior used internally or by parent components.

#### pathFromFileUrl(path: string) : string

Performs component-specific behavior used internally or by parent components.

#### wallpaperFolderUrl() : string

Performs component-specific behavior used internally or by parent components.

#### refreshWallpaperCache() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

#### applyWallpaper(path: string) : void

Applies the requested user selection by invoking the associated service or Kitana helper command.

#### themeFromLine(line: string) : var

Performs component-specific behavior used internally or by parent components.

#### applyTheme(theme: var) : void

Applies the requested user selection by invoking the associated service or Kitana helper command.

#### resetPickerState() : void

Performs component-specific behavior used internally or by parent components.

#### filteredWallpapers() : var

Returns filtered model data based on the current query or selection state.

#### wallpaperPageCount() : int

Performs component-specific behavior used internally or by parent components.

#### pageItems(page: int, items: var, pageSize: int) : var

Performs component-specific behavior used internally or by parent components.

#### wallpaperPageItems() : var

Performs component-specific behavior used internally or by parent components.

#### shiftWallpaperPage(delta: int) : void

Performs component-specific behavior used internally or by parent components.

#### filteredThemes() : var

Returns filtered model data based on the current query or selection state.

#### themePageCount() : int

Performs component-specific behavior used internally or by parent components.

#### themePageItems() : var

Performs component-specific behavior used internally or by parent components.

#### shiftThemePage(delta: int) : void

Performs component-specific behavior used internally or by parent components.

#### movePickerSelection(delta: int) : void

Updates keyboard selection or page state used by navigation.

#### refreshPickerFilter() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

#### applyCurrentPickerItem() : void

Applies the requested user selection by invoking the associated service or Kitana helper command.

#### handleKey(event: var) : void

Performs component-specific behavior used internally or by parent components.

#### tempValue(day: var, keyC: string, keyF: string) : string

Performs component-specific behavior used internally or by parent components.

#### windValue(condition: var) : string

Performs component-specific behavior used internally or by parent components.

#### forecastDays() : var

Performs component-specific behavior used internally or by parent components.

#### weatherCodeDescription(code: int) : string

Performs component-specific behavior used internally or by parent components.

#### openMeteoDays(data: var) : var

Performs component-specific behavior used internally or by parent components.

#### refreshExtendedForecast(data: var) : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

#### daysInMonth(month: date) : int

Performs component-specific behavior used internally or by parent components.

#### calendarDay(slot: int) : int

Performs component-specific behavior used internally or by parent components.

#### isToday(day: int) : bool

Returns a boolean answer for the requested condition.

#### shiftMonth(delta: int) : void

Performs component-specific behavior used internally or by parent components.

#### dayOfYear(date: date) : int

Performs component-specific behavior used internally or by parent components.

#### daysInYear(date: date) : int

Performs component-specific behavior used internally or by parent components.

#### isoWeek(date: date) : int

Returns a boolean answer for the requested condition.

#### refreshWorldClocks() : void

Refreshes data used by the component. Side effects may include starting a process, updating service state, or repopulating a model.

## Inter-Component Interactions

External components bind this component through its declared properties and call its public functions where exposed.

Reads from or calls service singletons: `Services.MediaService`, `Services.SystemStatus`.

Starts external commands through Quickshell process helpers or `Process` objects.

Exposes IPC targets: `kitana-dashboard`.
