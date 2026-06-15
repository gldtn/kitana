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
		quickshell = {
			foreground = "text",
			foregroundStrong = "subtle",
			foregroundMuted = "subtle",
			foregroundSubtle = "subtle",
			foregroundDisabled = "subtle",
			foregroundInverted = "surface",

			accent = "rose",
			accentStrong = "foam",
			onAccent = "surface",
			accentBackground = "rose",
			accentSelectedBackground = "rose",

			background = "base",
			surface = "surface",
			surfaceContainer = "surface",
			surfaceCard = "overlay",
			surfaceControl = "border1",
			surfaceSubtle = "highlight_med",
			surfaceHover = "highlight_med",
			surfacePressed = "highlight_med",
			surfaceActive = "rose",
			surfaceSelected = "rose",
			surfaceFloating = "base",
			surfaceFloatingStrong = "overlay",

			border = "border1",
			borderMuted = "highlight_high",
			borderStrong = "highlight_med",
			borderFocus = "rose",

			info = "foam",
			success = "pine",
			warning = "gold",
			danger = "love",
			infoBackground = "foam",
			successBackground = "pine",
			warningBackground = "gold",
			dangerBackground = "love",

			iconPrimary = "text",
			iconSecondary = "subtle",
			iconMuted = "subtle",
			iconSubtle = "subtle",
			iconAccent = "rose",
			iconOnAccent = "surface",
			iconInverse = "surface",
			iconBrand = "rose",
			iconDisabled = "subtle",
			iconDanger = "love",

			scrim = "highlight_low",
			scrimSoft = "highlight_low",
			imageOverlay = "highlight_low",
			shadow = "#000000",
		},

		hypr = {
			border_active = "accent",
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
