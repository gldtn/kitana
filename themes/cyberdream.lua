return {
  slug = "cyberdream",
  name = "Cyberdream",

  colors = {
    bg = "#16181a",
    bg_alt = "#1e2124",
    bg_highlight = "#3c4048",
    fg = "#ffffff",
    grey = "#7b8496",
    blue = "#5ea1ff",
    green = "#5eff6c",
    cyan = "#5ef1ff",
    red = "#ff6e5e",
    yellow = "#f1ff5e",
    magenta = "#ff5ef1",
    pink = "#ff5ea0",
    orange = "#ffbd5e",
    purple = "#bd5eff",
  },

  kitana = {
    crust0 = "bg",
    crust1 = "bg_alt",
    mantle0 = "bg",
    mantle1 = "bg_highlight",
    base0 = "bg",
    base1 = "bg_alt",
    surface0 = "bg_alt",
    surface1 = "bg_highlight",
    overlay0 = "bg_highlight",
    overlay1 = "grey",
    subtext0 = "grey",
    subtext1 = "fg",
    text0 = "fg",
    text1 = "fg",
    accent0 = "orange",
    accent1 = "cyan",
    info0 = "blue",
    success0 = "green",
    warning0 = "yellow",
    danger0 = "red",

    hypr = {
      border_active = "accent0",
      border_inactive = "surface1",
    },
  },

  ghostty = {
    source_file = "vendor/ghostty/cyberdream",
  },

  zed = {
    source_url = "https://raw.githubusercontent.com/scottmckendry/cyberdream.nvim/main/extras/zed/cyberdream.json",
    source_file = "vendor/zed/cyberdream.json",
    theme_name = "Cyberdream dark",
  },

  neovim = {
    colorscheme = "cyberdream",
  },
}
