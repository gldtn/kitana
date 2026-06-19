local json = require("kitana-json")

local M = {}

local ORDER = {
  "catppuccin-mocha",
  "rose-pine",
  "tokyo-night",
  "dracula",
  "kanagawa-dragon",
  "cyberdream",
}

local ROLES = {
  "fgPrimary",
  "fgSecondary",
  "fgTertiary",
  "fgOnPrimary",
  "fgAccent",
  "bgPrimary",
  "bgSecondary",
  "bgTertiary",
  "bgOnPrimary",
  "bgAccent",
  "borderDark",
  "borderLight",
  "borderFaint",
  "borderHeavy",
  "borderAccent",
  "info",
  "success",
  "warning",
  "error",
  "scrimPrimary",
  "scrimSecondary",
  "scrimTertiary",
  "subtleAccent",
  "subtlePrimary",
  "subtleSecondary",
  "subtleTertiary",
}

local ICON_DEFAULTS = {
  primary = "fgPrimary",
  secondary = "fgSecondary",
  muted = "fgTertiary",
  subtle = "fgTertiary",
  accent = "fgAccent",
  onAccent = "fgOnPrimary",
  inverse = "bgOnPrimary",
  brand = "fgAccent",
  disabled = { ref = "fgTertiary", alpha = 0.5 },
  danger = "error",
}

local function home_dir()
  return os.getenv("HOME") or ""
end

local function kitana_dir()
  return os.getenv("KITANA_DIR") or (home_dir() .. "/.local/share/kitana")
end

local function theme_dir()
  return kitana_dir() .. "/themes"
end

local function live_theme_path()
  return home_dir() .. "/.config/quickshell/kitana/Theme/current.json"
end

local function shell_quote(value)
  return "'" .. tostring(value or ""):gsub("'", "'\\''") .. "'"
end

local function read_file(path)
  local file, error_message = io.open(path, "rb")
  if not file then
    return nil, error_message
  end
  local data = file:read("*a")
  file:close()
  return data
end

local function write_file(path, data)
  local file, error_message = io.open(path, "wb")
  if not file then
    return nil, error_message
  end
  file:write(data)
  file:close()
  return true
end

local function basename(path)
  return path:match("([^/]+)$") or path
end

local function stem(path)
  return basename(path):gsub("%.jsonc$", ""):gsub("%.json$", "")
end

local function theme_file(slug)
  for _, extension in ipairs({ "jsonc", "json" }) do
    local path = theme_dir() .. "/" .. slug .. "." .. extension
    local file = io.open(path, "rb")
    if file then
      file:close()
      return path
    end
  end
  return nil
end

local function clamp(value, min, max)
  value = tonumber(value)
  if not value then
    error("color ratio must be a number", 3)
  end
  if value < min then
    return min
  end
  if value > max then
    return max
  end
  return value
end

local function is_hex(value)
  return type(value) == "string" and (value:match("^#%x%x%x%x%x%x$") ~= nil or value:match("^#%x%x%x%x%x%x%x%x$") ~= nil)
end

local function color_channel(color)
  return tostring(color or "#000000"):gsub("^#", ""):sub(-6)
end

local function hex_channel(value)
  return string.format("%02x", math.floor(value + 0.5))
end

local function channels(color)
  local value = color_channel(color)
  return tonumber(value:sub(1, 2), 16), tonumber(value:sub(3, 4), 16), tonumber(value:sub(5, 6), 16)
end

function M.mix_color(from, to, ratio)
  ratio = clamp(ratio, 0, 1)
  local fr, fg, fb = channels(from)
  local tr, tg, tb = channels(to)
  local inverse = 1 - ratio

  return "#"
    .. hex_channel(fr * inverse + tr * ratio)
    .. hex_channel(fg * inverse + tg * ratio)
    .. hex_channel(fb * inverse + tb * ratio)
end

function M.lighten_color(color, ratio)
  return M.mix_color(color, "#ffffff", ratio)
end

function M.darken_color(color, ratio)
  return M.mix_color(color, "#000000", ratio)
end

function M.alpha_color(color, opacity)
  local value = tonumber(opacity)
  if not value then
    error("alpha must be a number", 2)
  end
  if value > 1 then
    value = value / 100
  end
  value = clamp(value, 0, 1)
  return "#" .. hex_channel(value * 255) .. color_channel(color)
end

local function sorted_paths(paths)
  table.sort(paths)
  return paths
end

local function theme_paths()
  local paths = {}
  local known = {}

  for _, slug in ipairs(ORDER) do
    local path = theme_file(slug)
    if path then
      paths[#paths + 1] = path
      known[slug] = true
    end
  end

  local command = "find " .. shell_quote(theme_dir()) .. " -maxdepth 1 -type f \\( -name '*.jsonc' -o -name '*.json' \\) ! -name '_*'"
  local handle = io.popen(command)
  if handle then
    local extras = {}
    for path in handle:lines() do
      local name = stem(path)
      if not known[name] then
        known[name] = true
        extras[#extras + 1] = path
      end
    end
    handle:close()
    for _, path in ipairs(sorted_paths(extras)) do
      paths[#paths + 1] = path
    end
  end

  return paths
end

local function load_path(path)
  local data, error_message = read_file(path)
  if not data then
    error(error_message, 0)
  end

  local theme = json.decode_jsonc(data)
  theme._path = path
  theme.slug = theme.slug or stem(path)
  theme.name = theme.name or theme.slug
  theme.mode = theme.mode or "dark"
  theme.colors = theme.colors or {}
  theme.palette = theme.palette or {}
  theme.icons = theme.icons or {}
  return theme
end

function M.load(slug)
  return load_path(theme_file(slug) or (theme_dir() .. "/" .. slug .. ".jsonc"))
end

function M.find(requested)
  local needle = tostring(requested or ""):lower()
  for _, path in ipairs(theme_paths()) do
    local theme = load_path(path)
    if needle == tostring(theme.slug):lower() or needle == tostring(theme.name):lower() then
      return theme
    end
  end
  return nil
end

local function resolve_value(theme, value, fallback, seen)
  seen = seen or {}

  if type(value) == "table" then
    local ref = value.ref or value.role or value.color or value.from
    local base = resolve_value(theme, ref, fallback, seen)

    if value.mix ~= nil then
      base = M.mix_color(base, resolve_value(theme, value.mix, fallback, seen), value.ratio or 0.5)
    end
    if value.lighten ~= nil then
      base = M.lighten_color(base, value.lighten)
    end
    if value.darken ~= nil then
      base = M.darken_color(base, value.darken)
    end
    if value.alpha ~= nil then
      base = M.alpha_color(base, value.alpha)
    end

    return base
  end

  if is_hex(value) then
    return value
  end

  if type(value) ~= "string" or value == "" then
    if fallback ~= nil then
      return fallback
    end
    error("invalid color reference: " .. tostring(value), 2)
  end

  if theme.colors[value] ~= nil then
    local key = "colors." .. value
    if seen[key] then
      error("cyclic color reference in " .. theme.slug .. ": " .. value, 2)
    end
    seen[key] = true
    return resolve_value(theme, theme.colors[value], fallback, seen)
  end

  if theme.palette[value] ~= nil then
    local key = "palette." .. value
    if seen[key] then
      error("cyclic palette reference in " .. theme.slug .. ": " .. value, 2)
    end
    seen[key] = true
    return resolve_value(theme, theme.palette[value], fallback, seen)
  end

  if fallback ~= nil then
    return fallback
  end
  error("missing color reference in " .. theme.slug .. ": " .. value, 2)
end

function M.resolve_value(theme, value, fallback)
  return resolve_value(theme, value, fallback, {})
end

function M.resolve(theme, role, fallback)
  return resolve_value(theme, theme.palette[role], fallback or "#ff00ff", {})
end

local function resolve_icon(theme, tone, fallback)
  local value = theme.icons[tone] or ICON_DEFAULTS[tone]
  return resolve_value(theme, value, fallback, {})
end

local function resolved_roles(theme)
  local values = {}
  for _, role in ipairs(ROLES) do
    values[role] = M.resolve(theme, role)
  end

  values.iconPrimary = resolve_icon(theme, "primary", values.fgPrimary)
  values.iconSecondary = resolve_icon(theme, "secondary", values.fgSecondary)
  values.iconMuted = resolve_icon(theme, "muted", values.fgTertiary)
  values.iconSubtle = resolve_icon(theme, "subtle", values.fgTertiary)
  values.iconAccent = resolve_icon(theme, "accent", values.fgAccent)
  values.iconOnAccent = resolve_icon(theme, "onAccent", values.fgOnPrimary)
  values.iconInverse = resolve_icon(theme, "inverse", values.bgOnPrimary)
  values.iconBrand = resolve_icon(theme, "brand", values.fgAccent)
  values.iconDisabled = resolve_icon(theme, "disabled", M.alpha_color(values.fgTertiary, 0.5))
  values.iconDanger = resolve_icon(theme, "danger", values.error)
  return values
end

local function preview(theme)
  local values = resolved_roles(theme)
  return {
    background = values.bgPrimary,
    surface = values.bgSecondary,
    surface_alt = values.bgTertiary,
    foreground = values.fgPrimary,
    muted = values.fgSecondary,
    accent = values.bgAccent,
    accent_text = values.fgOnPrimary,
    warning = values.warning,
    danger = values.error,
  }
end

local function print_list()
  for _, path in ipairs(theme_paths()) do
    local theme = load_path(path)
    local data = preview(theme)
    local fields = {
      theme.slug,
      theme.name,
      data.background,
      data.surface,
      data.surface_alt,
      data.foreground,
      data.muted,
      data.accent,
      data.accent_text,
      data.warning,
      data.danger,
    }
    print(table.concat(fields, "|"))
  end
end

local function print_env(theme)
  local values = resolved_roles(theme)
  local data = preview(theme)
  local hypr = theme.hypr or {}
  local ghostty = theme.ghostty or {}
  local zed = theme.zed or {}
  local neovim = theme.neovim or {}

  local env = {
    slug = theme.slug,
    name = theme.name,
    mode = theme.mode,
    background = data.background,
    surface = data.surface,
    surface_alt = data.surface_alt,
    foreground = data.foreground,
    muted = data.muted,
    accent = data.accent,
    accent_text = data.accent_text,
    info = values.info,
    success = values.success,
    warning = values.warning,
    danger = values.error,
    base0 = values.bgPrimary,
    base1 = values.bgSecondary,
    surface0 = values.bgTertiary,
    surface1 = values.borderHeavy,
    text0 = values.fgPrimary,
    text1 = values.fgSecondary,
    subtext0 = values.fgTertiary,
    accent0 = values.bgAccent,
    accent1 = values.success,
    warning0 = values.warning,
    danger0 = values.error,
    ghostty_theme = ghostty.theme or "",
    ghostty_source_file = ghostty.source_file or "",
    zed_source_url = zed.source_url or "",
    zed_source_file = zed.source_file or "",
    zed_theme_name = zed.theme_name or theme.name,
    neovim_colorscheme = neovim.colorscheme or "",
    hypr_border_active = M.resolve_value(theme, hypr.border_active or "borderAccent"),
    hypr_border_inactive = M.resolve_value(theme, hypr.border_inactive or "borderHeavy"),
  }

  local order = {
    "slug",
    "name",
    "mode",
    "background",
    "surface",
    "surface_alt",
    "foreground",
    "muted",
    "accent",
    "accent_text",
    "info",
    "success",
    "warning",
    "danger",
    "base0",
    "base1",
    "surface0",
    "surface1",
    "text0",
    "text1",
    "subtext0",
    "accent0",
    "accent1",
    "warning0",
    "danger0",
    "ghostty_theme",
    "ghostty_source_file",
    "zed_source_url",
    "zed_source_file",
    "zed_theme_name",
    "neovim_colorscheme",
    "hypr_border_active",
    "hypr_border_inactive",
  }

  for _, key in ipairs(order) do
    print(key .. "=" .. shell_quote(env[key]))
  end
end

local function copy_current(theme)
  local target = live_theme_path()
  local target_dir = target:match("^(.*)/[^/]+$")
  os.execute("mkdir -p " .. shell_quote(target_dir))

  local tmp = target:gsub("([^/]+)$", ".%1.tmp")
  local source_path = theme._path
  theme._path = nil
  local data = json.encode(theme, { indent = "  " }) .. "\n"
  theme._path = source_path

  local ok, write_error = write_file(tmp, data)
  if not ok then
    error(write_error, 0)
  end
  assert(os.rename(tmp, target))
end

local function validate_theme(theme)
  local errors = {}

  for _, role in ipairs(ROLES) do
    if theme.palette[role] == nil then
      errors[#errors + 1] = "missing palette role: " .. role
    else
      local ok, result = pcall(M.resolve, theme, role)
      if not ok then
        errors[#errors + 1] = result
      end
    end
  end

  for name in pairs(theme.colors) do
    local ok, result = pcall(M.resolve_value, theme, name)
    if not ok then
      errors[#errors + 1] = result
    end
  end

  local tones = {}
  for tone in pairs(ICON_DEFAULTS) do
    tones[tone] = true
  end
  for tone in pairs(theme.icons or {}) do
    tones[tone] = true
  end
  for tone in pairs(tones) do
    local ok, result = pcall(resolve_icon, theme, tone, M.resolve(theme, "fgPrimary"))
    if not ok then
      errors[#errors + 1] = result
    end
  end

  return errors
end

local function validate_all()
  local ok = true
  for _, path in ipairs(theme_paths()) do
    local theme = load_path(path)
    local errors = validate_theme(theme)
    if #errors > 0 then
      ok = false
      io.stderr:write(path .. ":\n")
      for _, error_message in ipairs(errors) do
        io.stderr:write("  " .. error_message .. "\n")
      end
    end
  end
  return ok
end

local function usage()
  io.stderr:write("Usage: kitana-theme.lua [list|env|find|path|apply|validate|self-test] [THEME]\n")
end

local function self_test()
  assert(M.mix_color("#000000", "#ffffff", 0.5) == "#808080")
  assert(M.lighten_color("#000000", 0.25) == "#404040")
  assert(M.darken_color("#ffffff", 0.25) == "#bfbfbf")
end

local function main(args)
  local command = args[1] or ""
  local requested = args[2] or ""

  if command == "list" then
    print_list()
    return 0
  elseif command == "validate" then
    return validate_all() and 0 or 1
  elseif command == "self-test" then
    self_test()
    return 0
  end

  local theme = M.find(requested)
  if not theme then
    return 1
  end

  if command == "env" then
    print_env(theme)
  elseif command == "find" then
    print(theme.slug)
  elseif command == "path" then
    print(theme._path)
  elseif command == "apply" then
    copy_current(theme)
  else
    usage()
    return 2
  end

  return 0
end

M.main = main

if arg and arg[0] and arg[0]:match("kitana%-theme%.lua$") then
  os.exit(main(arg))
end

return M
