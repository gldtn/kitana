-- Kitana managed Hyprland Lua entrypoint
-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

local home = os.getenv("HOME")
local kitana_dir = os.getenv("KITANA_DIR") or (home .. "/.local/share/kitana")

package.path = home .. "/.config/?.lua;" .. kitana_dir .. "/?.lua;" .. package.path

-- Kitana defaults. Do not edit these directly.
-- Order matters: base session settings first, then layout/rules, then startup/binds.
local default_modules = {
  "env",
  "monitors",
  "input",
  "decorations",
  "layout",
  "rules",
  "misc",
  "autostart",
  "binds",
}

local default_app_modules = {
  "system",
  "1password",
  "bitwarden",
}

for _, module in ipairs(default_modules) do
  require("default.hypr.modules." .. module)
end

for _, module in ipairs(default_app_modules) do
  require("default.hypr.apps." .. module)
end

-- Local overrides and extensions.
-- To override a default module, require the module on the list below and
-- create the module in ~/.config/hypr/custom/.. See examples;
require("hypr.custom.monitors")
require("hypr.custom.input")
require("hypr.custom.binds")
