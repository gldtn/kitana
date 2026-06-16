local color = require("themes.helpers.color")

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
		border1 = color.darken("#44475a", 0.06),
		background1 = color.lighten("#282a36", 0.03),
	},

	kitana = {
		quickshell = {
			foreground = "foreground",
			foregroundStrong = "foreground",
			foregroundMuted = "muted",
			foregroundSubtle = "muted",
			foregroundDisabled = "muted",
			foregroundInverted = "background",

			accent = "purple",
			accentStrong = "pink",
			onAccent = "background",
			accentBackground = "purple",
			accentSelectedBackground = "purple",

			background = "background1",
			surface = "surface",
			surfaceContainer = "background",
			surfaceCard = "surface",
			surfaceControl = "border1",
			surfaceSubtle = "current_line",
			surfaceHover = "current_line",
			surfacePressed = "current_line",
			surfaceActive = "purple",
			surfaceSelected = "purple",
			surfaceFloating = "background1",
			surfaceFloatingStrong = "surface",

			border = "border1",
			borderSubtle = "border1",
			borderMuted = "current_line",
			borderStrong = "current_line",
			borderFocus = "purple",

			info = "cyan",
			success = "green",
			warning = "yellow",
			danger = "red",
			infoBackground = "cyan",
			successBackground = "green",
			warningBackground = "yellow",
			dangerBackground = "red",

			iconPrimary = "foreground",
			iconSecondary = "foreground",
			iconMuted = "muted",
			iconSubtle = "muted",
			iconAccent = "purple",
			iconOnAccent = "background",
			iconInverse = "background",
			iconBrand = "purple",
			iconDisabled = "muted",
			iconDanger = "red",

			scrim = "background1",
			scrimSoft = "background1",
			imageOverlay = "background1",
			shadow = "#000000",
		},

		hypr = {
			border_active = "accent",
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
