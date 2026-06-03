-- Kitana managed SDDM Hyprland greeter compositor config.
-- SDDM starts the greeter after the compositor is ready.

hl.config({
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
  },

  animations = {
    enabled = false,
  },
})
