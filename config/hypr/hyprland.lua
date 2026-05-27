-- Kitana managed Hyprland Lua entrypoint
-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

local home = os.getenv("HOME")
local kitana_dir = os.getenv("KITANA_DIR") or (home .. "/.local/share/kitana")

package.path = home .. "/.config/?.lua;" .. kitana_dir .. "/?.lua;" .. package.path

-- Kitana defaults. Do not edit these directly.
require("default.hypr.modules.env")
require("default.hypr.modules.monitors")
require("default.hypr.modules.input")
require("default.hypr.modules.decorations")
require("default.hypr.modules.layout")
require("default.hypr.modules.windowrules")
require("default.hypr.modules.misc")
require("default.hypr.modules.autostart")
require("default.hypr.modules.binds")

-- Local overrides and extensions.
-- To override a default module, require the module on the list below and
-- create the module in ~/.config/hypr/custom/.. See examples;
require("hypr.custom.monitors")
require("hypr.custom.binds")
