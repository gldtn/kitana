--------------------------------
---- SYSTEM APPLICATION RULES ----
--------------------------------

-- Tag app groups first, then apply shared behavior to those tags. This keeps
-- per-app rules small while making common behavior easy to extend.

hl.window_rule({
  name = "floating-window-defaults",
  match = { tag = "floating-window" },

  float = true,
  center = true,
  size = "875 600",
})

hl.window_rule({
  name = "media-viewers-float",
  match = { class = "^(imv|mpv|vlc|celluloid|Celluloid|io.github.celluloid_player.Celluloid|org.gnome.Papers|org.gnome.Evince)$" },

  tag = "+floating-window",
})

hl.window_rule({
  name = "image-previewers-float",
  match = { class = "^(org.gnome.NautilusPreviewer)$" },

  tag = "+floating-window",
})

hl.window_rule({
  name = "utility-apps-float",
  match = { class = "^(org.gnome.Calculator|org.gnome.seahorse.Application|seahorse|pavucontrol|blueman-manager|nm-connection-editor|com.gabm.satty)$" },

  tag = "+floating-window",
})

hl.window_rule({
  name = "cava-visualizer-pin",
  match = { class = "^io\\.kitana\\.cava$", title = "^cava$" },

  float = true,
  pin = true,
  size = "780 345",
  move = "1772 1088",
})

hl.window_rule({
  name = "kitana-theme-preview-float",
  match = { class = "^org\\.quickshell$", title = "^Kitana Theme Preview$" },

  float = false,
  center = false,
  border_size = 0,
  no_blur = true,
})

hl.window_rule({
  name = "file-dialogs-float",
  match = {
    class = "^(xdg-desktop-portal-gtk|org.gnome.Nautilus|zenity)$",
    title = "^(Open.*Files?|Open [Ff]older.*|Save.*Files?|Save.*As|Save|All Files|Choose.*|.*wants to (open|save).*)$",
  },

  tag = "+floating-window",
})
