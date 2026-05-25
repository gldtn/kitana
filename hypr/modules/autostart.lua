-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Example:
hl.on("hyprland.start", function()
  hl.exec_cmd("[ -f ~/.config/hypr/hyprpaper.conf ] && hyprpaper")
  hl.exec_cmd("swaync")
  hl.exec_cmd("waybar")
  hl.exec_cmd("vicinae server")
end)
