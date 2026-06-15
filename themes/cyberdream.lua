local color = require("themes.helpers.color")

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
		-- custom colors
		bg_pop = color.lighten("#21202e", 0.06),
		border_mantle = color.lighten("#3c4048", 0.06),
	},

	kitana = {
		quickshell = {
			foreground = "fg",
			foregroundStrong = "fg",
			foregroundMuted = "grey",
			foregroundSubtle = "grey",
			foregroundDisabled = "grey",
			foregroundInverted = "bg",

			accent = "orange",
			accentStrong = "cyan",
			onAccent = "bg",
			accentBackground = "orange",
			accentSelectedBackground = "orange",

			background = "bg",
			surface = "bg",
			surfaceContainer = "bg_alt",
			surfaceCard = "bg_alt",
			surfaceControl = "bg",
			surfaceSubtle = "bg_highlight",
			surfaceHover = "bg_highlight",
			surfacePressed = "bg_highlight",
			surfaceActive = "orange",
			surfaceSelected = "orange",
			surfaceFloating = "bg",
			surfaceFloatingStrong = "bg_alt",

			border = color.darken("#3c4048", 0.03),
			borderMuted = color.lighten("#1e2124", 0.08),
			borderStrong = color.darken("#7b8496", 0.1),
			borderFocus = "orange",

			info = "blue",
			success = "green",
			warning = "yellow",
			danger = "red",
			infoBackground = "blue",
			successBackground = "green",
			warningBackground = "yellow",
			dangerBackground = "red",

			iconPrimary = "fg",
			iconSecondary = "fg",
			iconMuted = "grey",
			iconSubtle = "grey",
			iconAccent = "orange",
			iconOnAccent = "bg",
			iconInverse = "bg",
			iconBrand = "orange",
			iconDisabled = "grey",
			iconDanger = "red",

			scrim = "bg_alt",
			scrimSoft = "bg_alt",
			imageOverlay = "bg_alt",
			shadow = "#000000",
		},

		hypr = {
			border_active = "accent",
			border_inactive = "borderStrong",
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
