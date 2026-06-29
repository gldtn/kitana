---------------------
---- MY PROGRAMS ----
---------------------

local launcher = "${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-launcher"
local browser = "${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-browser"
local editor = "ghostty -e nvim"
local guiEditor = "zeditor"
local terminal = "ghostty"
local fileManager = "nautilus --new-window"
local passwordManager = "${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-password-manager"
local activityManager = "ghostty -e btop"
local webappLauncher = "~/.local/share/kitana/bin/kitana-webapp-launch"
local emailClient = webappLauncher .. " https://app.hey.com HEY"
local chatClient = webappLauncher .. " https://web.whatsapp.com WhatsApp"
-- NOTE: these are not web apps
local iptvClient = "open_tv" -- this must be with an underscore
local musicClient = "youtube-music-desktop-app"

local bind = hl.bind

---------------------
---- KEYBINDINGS ----
---------------------

-- Set modifier
local mod = "SUPER" -- Sets "Windows" key as main modifier

-- Gracefully close window
bind(mod .. " + Q", hl.dsp.window.close(), { description = "Close active window" })

-- Launch programs
bind(mod .. " + C", hl.dsp.exec_cmd(editor), { description = "Editor" })
bind(mod .. " + B", hl.dsp.exec_cmd(browser), { description = "Browser" })
bind(mod .. " + G", hl.dsp.exec_cmd(guiEditor), { description = "Gui editor" })
bind(mod .. " + RETURN", hl.dsp.exec_cmd(terminal), { description = "Terminal" })
bind(mod .. " + D", hl.dsp.exec_cmd(launcher), { description = "Launcher" })
bind(mod .. " + E", hl.dsp.exec_cmd(fileManager), { description = "File manager" })
bind(mod .. " + A", hl.dsp.exec_cmd(activityManager), { description = "Activity manager" })
bind(mod .. " + SLASH", hl.dsp.exec_cmd(passwordManager), { description = "Password manager" })

-- Web apps & others
bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd(emailClient), { description = "Email client" })
bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd(chatClient), { description = "Chat client" })
bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd(iptvClient), { description = "IPTV client" })
bind(mod .. " + SHIFT + M", hl.dsp.exec_cmd(musicClient), { description = "Music client" })

-- Hyprland control
bind(mod .. " + CTRL + L", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-lock"), { description = "Lock session" })
bind(mod .. " + ESCAPE", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-session toggle"), { description = "Session menu" })
bind(mod .. " + CTRL + Z", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"), { description = "Exit Hyprland" })

-- Quickshell control
bind(mod .. " + K", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-shortcuts open"), { description = "Shortcuts" })
bind(mod .. " + CTRL + B", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-bar toggle"), { description = "Toggle Quickshell bar" })
bind(mod .. " + CTRL + D", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-dashboard toggle datetime"), { description = "Dashboard" })
bind(mod .. " + PERIOD", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-settings toggle bar"), { description = "Settings panel" })
bind("PRINT", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-screenshot toggle"), { description = "Screenshot menu" })
bind(mod .. " + CTRL + T", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-theme-grid"), { description = "Theme chooser" })
bind(mod .. " + CTRL + W", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-wallpaper-grid"), { description = "Wallpaper chooser" })
bind(mod .. " + CTRL + R", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-quickshell --restart"), { description = "Restart Quickshell" })
bind(mod .. " + COMMA", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-control-panel toggle notifications"), { description = "Control panel" })
bind(mod .. " + SHIFT + COMMA", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-notifications clear"), { description = "Dismiss all notifications" })

-- hyprland layout manipulation
bind(mod .. " + TAB", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-hyprland-workspace-layout-toggle"), { description = "Toggle current workspace layout" })
bind(mod .. " + LEFT", hl.dsp.layout("focus l"), { description = "Scroll active workspace backward" })
bind(mod .. " + RIGHT", hl.dsp.layout("focus r"), { description = "Scroll active workspace forward" })

-- Screenshot
bind(mod .. " + CTRL + SHIFT + P", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-screenshot output"), { description = "Screenshot monitor" })
bind(mod .. " + CTRL + SHIFT + W", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-screenshot window"), { description = "Screenshot window" })
bind(mod .. " + CTRL + SHIFT + R", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-screenshot region"), { description = "Screenshot region" })
bind(mod .. " + CTRL + SHIFT + C", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-screenshot region --clipboard-only"), { description = "Screenshot region (clipboard)" })

-- Window split/pseudo/float
bind(mod .. " + P", hl.dsp.window.pseudo(), { description = "Toggle pseudo" })
bind(mod .. " + X", hl.dsp.layout("togglesplit"), { description = "Toggle split" })
bind(mod .. " + F", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/default/hypr/scripts/toggle_float.sh"), { description = "Toggle float and center" })
bind(mod .. "+ SHIFT + F", function()
  hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
  hl.dispatch(hl.dsp.window.pin())
end)

-- Fullscreen window
bind(mod .. " + CTRL + M", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Full width" })
bind(mod .. " + CTRL + SHIFT + M", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Force full screen" })

-- Minimize window
bind(mod .. " + M", function()
  hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
  hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
  hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
  hl.dispatch(hl.dsp.window.move({ workspace = "special:minimize" }))
  hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
end, { description = "Minimize window" })

-- Focus and Swap windows
local directions = {
  H = "left",
  J = "down",
  K = "up",
  L = "right",
}

for key, dir in pairs(directions) do
  bind(mod .. " + " .. key, hl.dsp.focus({ direction = dir }), { description = "Focus " .. dir })

  bind(mod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = dir }), { description = "Swap " .. dir })
end

-- Window workspace management
for i = 1, 10 do
  local key = i % 10
  bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }), { description = "Go to workspace " .. i })
  bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = "Move window to workspace " .. i })
  bind(mod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i, follow = false }), { description = "Move window to workspace " .. i .. " (silent)" })
end

bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"), { description = "Toggle magic workspace" })
bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Move window to magic workspace" })

bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Drag window" })
bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Next audio track" })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Pause audio" })
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/Pause audio" })
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Previous audio track" })
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-osd volume-up"), { locked = true, repeating = true, description = "Raise volume" })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-osd volume-down"), { locked = true, repeating = true, description = "Lower volume" })
bind("XF86AudioMute", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-osd volume-mute"), { locked = true, repeating = true, description = "Mute volume" })
bind("XF86AudioMicMute", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-osd mic-mute"), { locked = true, repeating = true, description = "Mute microphone" })
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-osd brightness-up"), { locked = true, repeating = true, description = "Raise brightness" })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-osd brightness-down"), { locked = true, repeating = true, description = "Lower brightness" })
