-- Hyprland Lua config entrypoint for hypr
-- Split into modules for easier editing.

local modules = {
  "modules.env",
  "modules.monitors",
  "modules.input",
  "modules.decorations",
  "modules.layout",
  "modules.windowrules",
  "modules.misc",
  "modules.autostart",
  "modules.binds",
}

for _, module in ipairs(modules) do
  require(module)
end
