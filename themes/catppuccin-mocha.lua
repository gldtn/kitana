return {
	slug = "catppuccin-mocha",
	name = "Catppuccin Mocha",

	colors = {
		rosewater = "#f5e0dc",
		flamingo = "#f2cdcd",
		pink = "#f5c2e7",
		mauve = "#cba6f7",
		red = "#f38ba8",
		maroon = "#eba0ac",
		peach = "#fab387",
		yellow = "#f9e2af",
		green = "#a6e3a1",
		teal = "#94e2d5",
		sky = "#89dceb",
		sapphire = "#74c7ec",
		blue = "#89b4fa",
		lavender = "#b4befe",
		text = "#cdd6f4",
		subtext1 = "#bac2de",
		subtext0 = "#a6adc8",
		overlay2 = "#9399b2",
		overlay1 = "#7f849c",
		overlay0 = "#6c7086",
		surface2 = "#585b70",
		surface1 = "#45475a",
		surface0 = "#313244",
		base = "#1e1e2e",
		mantle = "#181825",
		crust = "#11111b",
	},

	kitana = {
		quickshell = {
			foreground = "text",
			foregroundStrong = "rosewater",
			foregroundMuted = "overlay2",
			foregroundSubtle = "overlay2",
			foregroundInverted = "mantle",

			accent = "mauve",
			accentStrong = "lavender",
			onAccent = "mantle",

			background = "base",
			surface = "mantle",
			surfaceContainer = "mantle",
			surfaceCard = "surface0",
			surfaceControl = "base",
			surfaceSubtle = "surface1",
			surfaceHover = "surface1",
			surfacePressed = "surface1",
			surfaceActive = "mauve",
			surfaceSelected = "mauve",
			surfaceFloating = "base",
			surfaceFloatingStrong = "surface0",

			border = "surface0",
			borderSubtle = "surface0",
			borderMuted = "surface1",
			borderStrong = "surface1",
			borderFocus = "mauve",

			info = "blue",
			success = "green",
			warning = "yellow",
			danger = "red",

			iconPrimary = "text",
			iconSecondary = "rosewater",
			iconMuted = "overlay2",
			iconSubtle = "overlay2",
			iconAccent = "mauve",
			iconOnAccent = "mantle",
			iconInverse = "mantle",
			iconBrand = "mauve",
			iconDisabled = "overlay2",
			iconDanger = "red",
		},

		hypr = {
			border_active = "accent",
			border_inactive = "borderStrong",
		},
	},

	ghostty = {
		theme = "Catppuccin Mocha",
	},

	zed = {
		source_url = "https://raw.githubusercontent.com/catppuccin/zed/main/themes/catppuccin-mauve.json",
		source_file = "vendor/zed/catppuccin-mocha.json",
		theme_name = "Catppuccin Mocha",
	},

	neovim = {
		colorscheme = "catppuccin",
	},
}
