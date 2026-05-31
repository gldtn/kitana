return {
  slug = "dracula",
  name = "Dracula",

  colors = {
    background = "#282a36",
    current_line = "#44475a",
    foreground = "#f8f8f2",
    comment = "#6272a4",
    cyan = "#8be9fd",
    green = "#50fa7b",
    orange = "#ffb86c",
    pink = "#ff79c6",
    purple = "#bd93f9",
    red = "#ff5555",
    yellow = "#f1fa8c",
    selection = "#44475a",
    surface = "#343746",
    muted = "#b6b6c8",
  },

  kitana = {
    crust0 = "background",
    crust1 = "background",
    mantle0 = "background",
    mantle1 = "surface",
    base0 = "background",
    base1 = "surface",
    surface0 = "surface",
    surface1 = "current_line",
    overlay0 = "current_line",
    overlay1 = "muted",
    subtext0 = "muted",
    subtext1 = "foreground",
    text0 = "foreground",
    text1 = "comment",
    accent0 = "purple",
    accent1 = "pink",
    warning0 = "yellow",
    danger0 = "red",

    hypr = {
      border_active = "accent0",
      border_inactive = "current_line",
    },
  },

  ghostty = {
    theme = "Dracula",
  },

  zed = {
    source_url = "https://raw.githubusercontent.com/dracula/zed/main/themes/dracula.json",
    source_file = "vendor/zed/dracula.json",
    theme_name = "Dracula Solid",
  },
}
