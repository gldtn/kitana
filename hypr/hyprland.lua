-- Hyprland Lua config entrypoint for Kitana defaults.
-- User overrides live in ~/.config/hypr/modules/<module>.lua.

local home = os.getenv("HOME")
local kitana_dir = os.getenv("KITANA_DIR") or (home .. "/.local/share/kitana")

local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end

  return false
end

local function load_module(path)
  local chunk, err = loadfile(path)
  if not chunk then
    error(err)
  end

  chunk()
end

local modules = {
  "env",
  "monitors",
  "input",
  "decorations",
  "layout",
  "windowrules",
  "misc",
  "autostart",
  "binds",
}

for _, module in ipairs(modules) do
  local user_path = home .. "/.config/hypr/modules/" .. module .. ".lua"
  local default_path = kitana_dir .. "/hypr/modules/" .. module .. ".lua"

  if file_exists(user_path) then
    load_module(user_path)
  else
    load_module(default_path)
  end
end
