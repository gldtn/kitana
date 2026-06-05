--------------------------------
---- HYPRLAND BLUR PROFILES ----
--------------------------------

-- Reference profiles for theme-specific blur choices. The default decorations
-- module uses balanced unless a theme sets kitana_theme.blur_profile.

return {
  balanced = {
    enabled    = true,
    size       = 4,
    passes     = 2,
    vibrancy   = 0.1696,
    brightness = 0.75,
    contrast   = 0.85,
  },

  aesthetic = {
    enabled    = true,
    size       = 8,
    passes     = 4,
    vibrancy   = 0.1696,
    special    = true,
    brightness = 0.65,
    contrast   = 0.75,
  },
}
