# Quickshell Settings

## Component Overview

Kitana is a Quickshell desktop shell for Hyprland. This singleton owns durable Quickshell user settings backed by `~/.local/state/kitana/quickshell-settings.json`.

## Project Structure and Dependencies

Source file: `Services/QuickshellSettings.qml`.

Qt and Quickshell imports: `import QtQuick`, `import Quickshell`, `import Quickshell.Io`.

Referenced by: `Services/UiPreferences.qml`, `Dashboard/DashboardPanel.qml`, and dashboard tabs through the panel API.

## Settings Schema

```json
{
  "preferences": {
    "layoutPillDisplayMode": "compact"
  },
  "bar": {
    "panelHeight": 0,
    "pillHeight": 0,
    "topMargin": -1,
    "pillRadius": -1
  },
  "dashboard": {
    "weather": {
      "location": "Attleboro, MA",
      "units": "F",
      "hideLocation": false
    },
    "worldClocks": [
      {
        "label": "Eastern",
        "timezone": "America/New_York"
      },
      {
        "label": "Brasilia",
        "timezone": "America/Sao_Paulo"
      }
    ]
  }
}
```

## Role

Use this service for user-facing settings that should survive a full Quickshell restart. Keep regenerated or fetched data, such as weather responses, in separate cache files.
