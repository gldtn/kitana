# Dashboard Panel

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This component belongs to the dashboard panel shell and dashboard-wide state area.

DashboardPanel is a layer-shell panel window in the Dashboard module.

## Project Structure and Dependencies

Source file: `Dashboard/DashboardPanel.qml`.

Qt and Quickshell imports: `import QtQuick`, `import QtQuick.Layouts`, `import Qt.labs.folderlistmodel`, `import Quickshell`, `import Quickshell.Io`, `import Quickshell.Wayland`.

Project imports: `import ".."`, `import "../custom" as Custom`, `import "../Services" as Services`, `import "./Components" as Dashboard`, `import "./Tabs" as Tabs`.

Referenced or instantiated by: `shell.qml`.

## Component Hierarchy and Role

The root type is `PanelWindow`. The component composes child QML items, Kitana design tokens, and Quickshell services to provide its role in the shell.

## Properties

| Property | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `panelSelf` | `readonly var` | `root` | No | Read-only. Provides component state or configuration for `panelSelf`. |
| `panelVisible` | `bool` | `false` | No | Tracks whether the panel window should be visible. |
| `revealProgress` | `real` | `0` | No | Controls the numeric value for `revealProgress`. |
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
| `kitanaDir` | `string` | `Quickshell.env("KITANA_DIR") \|\| Quickshell.env("HOME") + "/.local/share/kitana"` | No | Stores the Kitana repository path used to call helper commands. |
| `wallpaperDir` | `string` | `Quickshell.env("KITANA_WALLPAPER_DIR") \|\| Quickshell.env("HOME") + "/.config/kitana/wal...` | No | Stores the wallpaper directory used by wallpaper pickers. |
| `currentTime` | `date` | `new Date()` | No | Provides component state or configuration for `currentTime`. |
| `calendarMonth` | `date` | `new Date(currentTime.getFullYear(), currentTime.getMonth(), 1)` | No | Provides component state or configuration for `calendarMonth`. |
| `firstClockTime` | `string` | `"--"` | No | Stores the string value for `firstClockTime`. |
| `firstClockDate` | `string` | `""` | No | Stores the string value for `firstClockDate`. |
| `secondClockTime` | `string` | `"--"` | No | Stores the string value for `secondClockTime`. |
| `secondClockDate` | `string` | `""` | No | Stores the string value for `secondClockDate`. |
| `cavaLevels` | `var` | `[1, 2, 3, 2, 1, 3, 4, 3, 2, 1, 2, 3, 2, 1, 2, 4, 3, 2, 1, 2, 3, 5, 4, 2, 1, 2, 3, 2, 1,...` | No | Provides component state or configuration for `cavaLevels`. |
| `mediaVisualStep` | `int` | `0` | No | Controls the numeric value for `mediaVisualStep`. |
| `mediaAudioOverlayOpen` | `bool` | `false` | No | Enables or disables the `mediaAudioOverlayOpen` state. |
| `mediaPlaying` | `readonly bool` | `Services.MediaService.playing` | No | Read-only. Enables or disables the `mediaPlaying` state. |

## Methods

#### open(tab: string) : void

Opens the component or switches it to the requested section/tab. Side effects usually include focus changes, state reset, or data refresh.

#### close() : void

Closes the component and resets transient state used while visible.

#### toggle(tab: string) : void

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
