--------------------------------
---- SYSTEM APPLICATION RULES ----
--------------------------------

-- Tag app groups first, then apply shared behavior to those tags. This keeps
-- per-app rules small while making common behavior easy to extend.

hl.window_rule({
  name   = "floating-window-defaults",
  match  = { tag = "floating-window" },

  float  = true,
  center = true,
  size   = "875 600",
})

hl.window_rule({
  name  = "media-viewers-float",
  match = { class = "^(imv|mpv|vlc|celluloid|Celluloid|io.github.celluloid_player.Celluloid)$" },

  tag   = "+floating-window",
})

hl.window_rule({
  name  = "image-previewers-float",
  match = { class = "^(org.gnome.NautilusPreviewer)$" },

  tag   = "+floating-window",
})

hl.window_rule({
  name  = "utility-apps-float",
  match = { class = "^(org.gnome.Calculator|pavucontrol|blueman-manager|nm-connection-editor|com.gabm.satty)$" },

  tag   = "+floating-window",
})

hl.window_rule({
  name  = "file-dialogs-float",
  match = {
    class = "^(xdg-desktop-portal-gtk|org.gnome.Nautilus|zenity)$",
    title = "^(Open.*Files?|Open [Ff]older.*|Save.*Files?|Save.*As|Save|All Files|Choose.*|.*wants to (open|save).*)$",
  },

  tag   = "+floating-window",
})
