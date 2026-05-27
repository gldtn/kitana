---------------------
---- MY PROGRAMS ----
---------------------

local launcher = "vicinae toggle"
local browser = "brave"
local editor = "nvim"
local guiEditor = "zeditor"
local terminal = "ghostty"
local fileManager = "nautilus --new-window"
local passwordManager = "1password"
local activityManager = "btop"
-- TODO: the following need a web apps launcher to work, see Omarchy web app launcher
local webappLauncher = "~/.local/share/kitana/bin/webapp-launch"
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
hl.bind(mod .. " + E", hl.dsp.exec_cmd(editor), { description = "Editor" })
hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser), { description = "Browser" })
hl.bind(mod .. " + G", hl.dsp.exec_cmd(guiEditor), { description = "Gui editor" })
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(terminal), { description = "Terminal" })
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd(launcher), { description = "Launcher" })
hl.bind(mod .. " + F", hl.dsp.exec_cmd(fileManager), { description = "File manager" })
hl.bind(mod .. " + A", hl.dsp.exec_cmd(activityManager), { description = "Activity manager" })
hl.bind(mod .. " + SLASH", hl.dsp.exec_cmd(passwordManager), { description = "Password manager" })

-- Web apps & others
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd(emailClient))
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd(chatClient))
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd(iptvClient))
hl.bind(mod .. " + SHIFT + M", hl.dsp.exec_cmd(musicClient))

hl.bind(mod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Window split/pseudo
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + X", hl.dsp.layout("togglesplit"), { description = "Toggle split" })

-- Window float
hl.bind(mod .. " + CTRL + SHIFT + F", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle float" })
hl.bind(mod .. " + CTRL + T", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_float.sh"), { description = "Toggle float and center" })

-- Fullscreen window
hl.bind(mod .. " + CTRL + M", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Full width" })
hl.bind(mod .. " + CTRL + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Force full screen" })

-- Focus and Swap windows
local directions = {
  H = "left",
  J = "down",
  K = "up",
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

hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- stylua: ignore
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
-- Brightness
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
