local M = {}

M.order = {
  "catppuccin-mocha",
  "rose-pine",
  "tokyo-night",
  "dracula",
  "kanagawa-dragon",
  "cyberdream",
}

local fields = {
  "crust0",
  "crust1",
  "mantle0",
  "mantle1",
  "base0",
  "base1",
  "surface0",
  "surface1",
  "overlay0",
  "overlay1",
  "subtext0",
  "subtext1",
  "text0",
  "text1",
  "accent0",
  "accent1",
  "info0",
  "success0",
  "warning0",
  "danger0",
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

function M.resolve(theme, key)
  local source = theme.kitana and theme.kitana[key]
  if not source then
    error("missing kitana mapping: " .. theme.slug .. "." .. key)
  end

  if type(source) == "string" and source:match("^#%x+$") and (#source == 7 or #source == 9) then
    return source
  end

  local value = theme.colors and theme.colors[source]
  if not value then
    error("missing theme color: " .. theme.slug .. ".colors." .. source)
  end

  return value
end

function M.raw(theme)
  local values = {}
  for _, field in ipairs(fields) do
    values[field] = M.resolve(theme, field)
  end
  return values
end

function M.preview(theme)
  local raw = M.raw(theme)
  return {
    background = raw.base0,
    surface = raw.base1,
    surface_alt = raw.surface1,
    foreground = raw.text0,
    muted = raw.subtext0,
    accent = raw.accent0,
    accent_text = raw.crust0,
    info = raw.info0,
    success = raw.success0,
    warning = raw.warning0,
    danger = raw.danger0,
  }
end

function M.resolve_any(theme, source)
  if type(source) == "string" and source:match("^#%x+$") and (#source == 7 or #source == 9) then
    return source
  end

  local raw = M.raw(theme)
  if raw[source] then
    return raw[source]
  end

  local value = theme.colors and theme.colors[source]
  if value then
    return value
  end

  error("missing theme color reference: " .. theme.slug .. "." .. tostring(source))
end

function M.hypr(theme)
  local hypr = theme.kitana and theme.kitana.hypr or {}

  return {
    border_active = M.resolve_any(theme, hypr.border_active or hypr.window_border or "accent0"),
    border_inactive = M.resolve_any(theme, hypr.border_inactive or "surface1"),
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

function M.print_env(theme)
  local preview = M.preview(theme)
  local hypr = M.hypr(theme)

  print("slug=" .. shell_quote(theme.slug))
  print("name=" .. shell_quote(theme.name))
  for _, field in ipairs(fields) do
    print(field .. "=" .. shell_quote(M.resolve(theme, field)))
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
  io.stderr:write("Usage: lua lib/kitana-theme.lua [list|env|find] [THEME]\n")
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
