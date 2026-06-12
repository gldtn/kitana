local color = require("themes.helpers.color")

return {
	slug = "rose-pine",
	name = "Rose Pine",

	colors = {
		base = "#191724",
		surface = "#1f1d2e",
		overlay = "#26233a",
		muted = "#6e6a86",
		subtle = "#908caa",
		text = "#e0def4",
		love = "#eb6f92",
		gold = "#f6c177",
		rose = "#ebbcba",
		pine = "#31748f",
		foam = "#9ccfd8",
		iris = "#c4a7e7",
		highlight_low = "#21202e",
		highlight_med = "#403d52",
		highlight_high = "#524f67",
		border0 = color.darken("#21202e", 0.06),
		border1 = color.lighten("#21202e", 0.06),
	},

	kitana = {
		crust0 = "surface", -- panelContainerBackground
		crust1 = "highlight_low",
		mantle0 = "surface", -- panelBackground
		mantle1 = "highlight_med",
		base0 = "base",
		base1 = "overlay",
		surface0 = "border1", -- panelBorder
		surface1 = "highlight_med",
		overlay0 = "highlight_high",
		overlay1 = "subtle",
		subtext0 = "subtle",
		subtext1 = "text",
		text0 = "text",
		text1 = "subtle",
		accent0 = "rose",
		accent1 = "foam",
		info0 = "foam",
		success0 = "pine",
		warning0 = "gold",
		danger0 = "love",

		hypr = {
			border_active = "accent0",
			border_inactive = "highlight_med",
		},
	},

	ghostty = {
		theme = "Rose Pine",
	},

	zed = {
		source_url = "https://raw.githubusercontent.com/rose-pine/zed/main/themes/rose-pine.json",
		source_file = "vendor/zed/rose-pine.json",
		theme_name = "Rosé Pine",
	},
}
