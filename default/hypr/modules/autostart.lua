-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Example:
hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP")
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP")
  hl.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-workspaces")
  hl.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-wallpaper --restore")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("swaync")
  hl.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-quickshell")
    -- hl.exec_cmd("systemctl --user start hypridle.service")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("sh -c 'killall -wq vicinae-server 2>/dev/null; vicinae server --replace'")
end)
