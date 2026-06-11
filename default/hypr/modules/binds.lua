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
-- TODO: the following need a web apps launcher to work, see Omarchy web app launcher
local webappLauncher = "~/.local/share/kitana/bin/kitana-webapp-launch"
local emailClient = webappLauncher .. " https://app.hey.com HEY"
local chatClient = webappLauncher .. " https://web.whatsapp.com WhatsApp"
-- NOTE: these are not web apps
local iptvClient = "open_tv" -- this must be with an underscore
local musicClient = "youtube-music-desktop-app"

---------------------
---- KEYBINDINGS ----
---------------------

-- Set modifier
local mod = "SUPER" -- Sets "Windows" key as main modifier

-- Gracefully close window
hl.bind(mod .. " + Q", hl.dsp.window.close(), { description = "Close active window" })

-- Launch programs
hl.bind(mod .. " + C", hl.dsp.exec_cmd(editor), { description = "Editor" })
hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser), { description = "Browser" })
hl.bind(mod .. " + G", hl.dsp.exec_cmd(guiEditor), { description = "Gui editor" })
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(terminal), { description = "Terminal" })
hl.bind(mod .. " + D", hl.dsp.exec_cmd(launcher), { description = "Launcher" })
hl.bind(mod .. " + E", hl.dsp.exec_cmd(fileManager), { description = "File manager" })
hl.bind(mod .. " + A", hl.dsp.exec_cmd(activityManager), { description = "Activity manager" })
hl.bind(mod .. " + SLASH", hl.dsp.exec_cmd(passwordManager), { description = "Password manager" })

-- Web apps & others
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd(emailClient), { description = "Email client" })
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd(chatClient), { description = "Chat client" })
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd(iptvClient), { description = "IPTV client" })
hl.bind(mod .. " + SHIFT + M", hl.dsp.exec_cmd(musicClient), { description = "Music client" })

-- Hyprland control
hl.bind(mod .. " + CTRL + L", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-lock"), { description = "Lock session" })
hl.bind(
  mod .. " + CTRL + Z",
  hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"),
  { description = "Exit Hyprland" }
)

-- Quickshell control
-- stylua: ignore start
hl.bind(mod .. " + K", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-shortcuts open"), { description = "Shortcuts" })
hl.bind(mod .. " + CTRL + B", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-bar toggle"), { description = "Toggle Quickshell bar" })
hl.bind(mod .. " + CTRL + P", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-screenshot toggle"), { description = "Screenshot menu" })
hl.bind(mod .. " + CTRL + T", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-theme-grid"), { description = "Theme chooser" })
hl.bind(mod .. " + CTRL + W", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-wallpaper-grid"), { description = "Wallpaper chooser" })
hl.bind(mod .. " + CTRL + R", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-quickshell --restart"), { description = "Restart Quickshell" })
hl.bind(mod .. " + COMMA", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-notifications dismissLast"), { description = "Dismiss last notification" })
hl.bind(mod .. " + SHIFT + COMMA", hl.dsp.exec_cmd("quickshell ipc -c kitana call kitana-notifications clear"), { description = "Dismiss all notifications" })
--stylua: ignore end

-- Screenshot
hl.bind(mod .. " + CTRL + SHIFT + P", hl.dsp.exec_cmd("hyprshot -m output"), { description = "Screenshot monitor" })
hl.bind(mod .. " + CTRL + SHIFT + W", hl.dsp.exec_cmd("hyprshot -m window"), { description = "Screenshot window" })
hl.bind(mod .. " + CTRL + SHIFT + R", hl.dsp.exec_cmd("hyprshot -m region"), { description = "Screenshot region" })
hl.bind(mod .. " + CTRL + SHIFT + C", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"), { description = "Screenshot region (clipboard)" })

-- Window split/pseudo/float
hl.bind(mod .. " + P", hl.dsp.window.pseudo(), { description = "Toggle pseudo" })
hl.bind(mod .. " + X", hl.dsp.layout("togglesplit"), { description = "Toggle split" })
-- stylua: ignore
hl.bind( mod .. " + F", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/default/hypr/scripts/toggle_float.sh"), { description = "Toggle float and center" })

-- Fullscreen window
hl.bind(mod .. " + CTRL + M", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Full width" })
hl.bind(mod .. " + CTRL + SHIFT + M", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Force full screen" })

-- Minimize window
hl.bind(mod .. " + M", function()
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
  L = "right",
}

for key, dir in pairs(directions) do
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = dir }), { description = "Focus " .. dir })

  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = dir }), { description = "Swap " .. dir })
end

-- Window workspace management
for i = 1, 10 do
  local key = i % 10
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }), { description = "Go to workspace " .. i })
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = "Move window to workspace " .. i })
  hl.bind(mod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i, follow = false }), { description = "Move window to workspace " .. i .. " (silent)" })
end

hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"), { description = "Toggle magic workspace" })
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Move window to magic workspace" })

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Drag window" })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

-- stylua: ignore start
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Next audio track" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Pause audio" })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/Pause audio" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Previous audio track" })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-osd volume-up"), { locked = true, repeating = true, description = "Raise volume" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-osd volume-down"), { locked = true, repeating = true, description = "Lower volume" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-osd volume-mute"), { locked = true, repeating = true, description = "Mute volume" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-osd mic-mute"), { locked = true, repeating = true, description = "Mute microphone" })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-osd brightness-up"), { locked = true, repeating = true, description = "Raise brightness" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-osd brightness-down"), { locked = true, repeating = true, description = "Lower brightness" })
-- stylua: ignore end
