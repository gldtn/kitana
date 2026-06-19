--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
  -- Ignore maximize requests from all apps. You'll probably like this.
  name           = "suppress-maximize-events",
  match          = { class = ".*" },

  suppress_event = "maximize",
})

hl.window_rule({
  -- Fix some dragging issues with XWayland
  name     = "fix-xwayland-drags",
  match    = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },

  no_focus = true,
})

hl.layer_rule({
  -- Avoid compositor effects on transient menu/tray/popup layers.
  name         = "quiet-menu-tray-popup-layers",
  match        = { class = "quickshell", title = ".*(menu|tray|popup).*" },

  no_anim      = true,
  ignore_alpha = 0,
})

hl.layer_rule({
  -- Blur only Kitana Quickshell overlay surfaces that opt into it.
  name         = "kitana-quickshell-blur",
  match        = { namespace = "^qs-blurred-panel$" },

  blur         = true,
  ignore_alpha = 0.18,
})
