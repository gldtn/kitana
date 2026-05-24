---------------
---- INPUT ----
---------------

hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Alt + Space
    kb_layout = "us,us",
    kb_variant = ",intl",
    kb_model = "",
    kb_options = "grp:alt_space_toggle",
    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,
    -- Start with numlock on by default
    numlock_by_default = true,
    -- Follow Mouse Cursor
    follow_mouse = 1,
    sensitivity = 0,

    touchpad = {
      natural_scroll = false,
    },
  },
})

hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})
