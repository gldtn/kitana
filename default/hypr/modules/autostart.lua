-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

local function sync_workspaces()
  hl.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-workspaces")
end

-- Example:
hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP")
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP")
  sync_workspaces()
  hl.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-wallpaper --restore")
  hl.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-wallpaper-watch")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-quickshell start")
  hl.exec_cmd("hypridle")
end)

hl.on("config.reloaded", sync_workspaces)
