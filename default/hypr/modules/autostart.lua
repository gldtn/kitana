-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Example:
hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP")
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP")
  hl.exec_cmd("sh -c '[ -f ~/.config/hypr/hyprpaper.conf ] && { pkill -x hyprpaper 2>/dev/null || true; hyprpaper; }'")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("swaync")
  hl.exec_cmd("waybar")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("sh -c 'killall -wq vicinae-server 2>/dev/null; vicinae server --replace'")
end)
