-- Kitana managed SDDM Hyprland greeter compositor config.
-- SDDM starts the greeter after the compositor is ready.

local function shell_quote(value)
  return "'" .. tostring(value or ""):gsub("'", "'\\''") .. "'"
end

local function read_first_line(path)
  local file = io.open(path, "r")
  if not file then
    return ""
  end

  local line = file:read("*l") or ""
  file:close()
  return line:gsub("^%s+", ""):gsub("%s+$", "")
end

local function lua_quote(value)
  return string.format("%q", tostring(value or ""))
end

local function focus_dispatch(selector)
  return "hyprctl dispatch " .. shell_quote("hl.dsp.focus({ monitor = " .. lua_quote(selector) .. " })")
end

local focus_monitor = read_first_line("/var/lib/kitana/sddm/focus-monitor")

hl.config({
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
  },

  animations = {
    enabled = false,
  },
})

if focus_monitor ~= "" then
  local command = "sleep 0.4; " .. focus_dispatch(focus_monitor)
    .. "; sleep 0.8; " .. focus_dispatch(focus_monitor)

  hl.exec_cmd("sh -lc " .. shell_quote(command))
end
