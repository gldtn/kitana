local M = {}

M.order = {
  "catppuccin-mocha",
  "rose-pine",
  "tokyo-night",
  "dracula",
  "kanagawa-dragon",
  "cyberdream",
}

local function kitana_dir()
  return os.getenv("KITANA_DIR") or (os.getenv("HOME") .. "/.local/share/kitana")
end

local function ensure_package_path()
  local root = kitana_dir()
  local paths = root .. "/?.lua;" .. root .. "/?/init.lua;"
  if not package.path:find(paths, 1, true) then
    package.path = paths .. package.path
  end
end

ensure_package_path()

local quickshell_roles = require("lib.kitana-quickshell-colors").env_roles()

M.quickshell_roles = quickshell_roles

local function shell_quote(value)
  value = tostring(value or "")
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

function M.load(slug)
  ensure_package_path()

  local path = kitana_dir() .. "/themes/" .. slug .. ".lua"
  local chunk, err = loadfile(path)
  if not chunk then
    error(err)
  end

  local theme = chunk()
  if type(theme) ~= "table" then
    error("theme file did not return a table: " .. path)
  end

  return theme
end

local function is_hex(value)
  return type(value) == "string" and value:match("^#%x+$") and (#value == 7 or #value == 9)
end

function M.resolve_palette(theme, source)
  if is_hex(source) then
    return source
  end

  local value = theme.colors and theme.colors[source]
  if value then
    return value
  end

  error("missing theme color: " .. theme.slug .. ".colors." .. tostring(source))
end

function M.resolve_quickshell(theme, key, seen)
  local quickshell = theme.kitana and theme.kitana.quickshell or {}
  local source = quickshell[key]
  if not source then
    error("missing kitana quickshell mapping: " .. theme.slug .. "." .. key)
  end

  if is_hex(source) or theme.colors and theme.colors[source] then
    return M.resolve_palette(theme, source)
  end

  if quickshell[source] then
    seen = seen or {}
    if seen[source] then
      error("cyclic kitana quickshell mapping: " .. theme.slug .. "." .. key)
    end
    seen[key] = true
    return M.resolve_quickshell(theme, source, seen)
  end

  error("missing theme color reference: " .. theme.slug .. "." .. tostring(source))
end

function M.quickshell(theme)
  local values = {}
  for _, role in ipairs(quickshell_roles) do
    values[role] = M.resolve_quickshell(theme, role)
  end
  return values
end

function M.preview(theme)
  local quickshell = M.quickshell(theme)
  return {
    background = quickshell.background,
    surface = quickshell.surfaceCard,
    surface_alt = quickshell.surfaceSubtle,
    foreground = quickshell.foreground,
    muted = quickshell.foregroundMuted,
    accent = quickshell.accent,
    accent_text = quickshell.onAccent,
    info = quickshell.info,
    success = quickshell.success,
    warning = quickshell.warning,
    danger = quickshell.danger,
  }
end

function M.resolve_any(theme, source)
  if is_hex(source) or theme.colors and theme.colors[source] then
    return M.resolve_palette(theme, source)
  end

  local quickshell = theme.kitana and theme.kitana.quickshell or {}
  if quickshell[source] then
    return M.resolve_quickshell(theme, source)
  end

  error("missing theme color reference: " .. theme.slug .. "." .. tostring(source))
end

function M.hypr(theme)
  local hypr = theme.kitana and theme.kitana.hypr or {}

  return {
    border_active = M.resolve_any(theme, hypr.border_active or hypr.window_border or "accent"),
    border_inactive = M.resolve_any(theme, hypr.border_inactive or "borderStrong"),
  }
end

function M.find(requested)
  for _, slug in ipairs(M.order) do
    local theme = M.load(slug)
    if requested == theme.slug or requested == theme.name then
      return theme
    end
  end

  return nil
end

function M.pipe_line(theme)
  local preview = M.preview(theme)
  local values = {
    theme.slug,
    theme.name,
    preview.background,
    preview.surface,
    preview.surface_alt,
    preview.foreground,
    preview.muted,
    preview.accent,
    preview.accent_text,
    preview.warning,
    preview.danger,
  }
  return table.concat(values, "|")
end

function M.print_quickshell_env(theme)
  local quickshell = M.quickshell(theme)
  for _, role in ipairs(quickshell_roles) do
    print(role .. "=" .. shell_quote(quickshell[role]))
  end
end

function M.print_env(theme)
  local preview = M.preview(theme)
  local hypr = M.hypr(theme)

  print("slug=" .. shell_quote(theme.slug))
  print("name=" .. shell_quote(theme.name))
  local quickshell = M.quickshell(theme)
  for _, role in ipairs(quickshell_roles) do
    print(role .. "=" .. shell_quote(quickshell[role]))
  end
  for key, value in pairs(preview) do
    print(key .. "=" .. shell_quote(value))
  end
  if theme.ghostty and theme.ghostty.theme then
    print("ghostty_theme=" .. shell_quote(theme.ghostty.theme))
  else
    print("ghostty_theme=''")
  end
  if theme.ghostty and theme.ghostty.source_file then
    print("ghostty_source_file=" .. shell_quote(theme.ghostty.source_file))
  else
    print("ghostty_source_file=''")
  end
  if theme.zed then
    print("zed_source_url=" .. shell_quote(theme.zed.source_url or ""))
    print("zed_source_file=" .. shell_quote(theme.zed.source_file or ""))
    print("zed_theme_name=" .. shell_quote(theme.zed.theme_name or theme.name))
  else
    print("zed_source_url=''")
    print("zed_source_file=''")
    print("zed_theme_name=''")
  end
  if theme.neovim then
    print("neovim_colorscheme=" .. shell_quote(theme.neovim.colorscheme or ""))
  else
    print("neovim_colorscheme=''")
  end
  print("hypr_border_active=" .. shell_quote(hypr.border_active))
  print("hypr_border_inactive=" .. shell_quote(hypr.border_inactive))
end

local function usage()
  io.stderr:write("Usage: lua lib/kitana-theme.lua [list|env|quickshell-env|find] [THEME]\n")
end

if arg and arg[0] and arg[0]:match("kitana%-theme%.lua$") then
  local command = arg[1]

  if command == "list" then
    for _, slug in ipairs(M.order) do
      print(M.pipe_line(M.load(slug)))
    end
  elseif command == "env" then
    local theme = M.find(arg[2] or "")
    if not theme then
      os.exit(1)
    end
    M.print_env(theme)
  elseif command == "quickshell-env" then
    local theme = M.find(arg[2] or "")
    if not theme then
      os.exit(1)
    end
    M.print_quickshell_env(theme)
  elseif command == "find" then
    local theme = M.find(arg[2] or "")
    if not theme then
      os.exit(1)
    end
    print(theme.slug)
  else
    usage()
    os.exit(2)
  end
end

return M
