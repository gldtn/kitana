local M = {}

local direct_fields = {
  { qml = "foreground", env = "foreground" },
  { qml = "foregroundStrong", env = "foregroundStrong" },
  { qml = "foregroundMuted", env = "foregroundMuted" },
  { qml = "foregroundSubtle", env = "foregroundSubtle" },
  { qml = "foregroundInverted", env = "foregroundInverted" },
  { qml = "accent", env = "accent" },
  { qml = "accentStrong", env = "accentStrong" },
  { qml = "foregroundOnAccent", env = "onAccent" },
  { qml = "background", env = "background" },
  { qml = "surface", env = "surface" },
  { qml = "surfaceContainer", env = "surfaceContainer" },
  { qml = "surfaceCard", env = "surfaceCard" },
  { qml = "surfaceControl", env = "surfaceControl" },
  { qml = "surfaceSubtle", env = "surfaceSubtle" },
  { qml = "surfaceHover", env = "surfaceHover" },
  { qml = "surfacePressed", env = "surfacePressed" },
  { qml = "surfaceActive", env = "surfaceActive" },
  { qml = "surfaceSelected", env = "surfaceSelected" },
  { qml = "surfaceFloating", env = "surfaceFloating" },
  { qml = "surfaceFloatingStrong", env = "surfaceFloatingStrong" },
  { qml = "border", env = "border" },
  { qml = "borderSubtle", env = "borderSubtle" },
  { qml = "borderMuted", env = "borderMuted" },
  { qml = "borderStrong", env = "borderStrong" },
  { qml = "borderFocus", env = "borderFocus" },
  { qml = "info", env = "info" },
  { qml = "success", env = "success" },
  { qml = "warning", env = "warning" },
  { qml = "danger", env = "danger" },
  { qml = "iconPrimary", env = "iconPrimary" },
  { qml = "iconSecondary", env = "iconSecondary" },
  { qml = "iconMuted", env = "iconMuted" },
  { qml = "iconSubtle", env = "iconSubtle" },
  { qml = "iconAccent", env = "iconAccent" },
  { qml = "iconOnAccent", env = "iconOnAccent" },
  { qml = "iconInverse", env = "iconInverse" },
  { qml = "iconBrand", env = "iconBrand" },
  { qml = "iconDanger", env = "iconDanger" },
}

local alpha_fields = {
  { qml = "iconDisabled", env = "iconDisabled" },
}

M.direct_fields = direct_fields
M.alpha_fields = alpha_fields

local function read_file(path)
  local file = assert(io.open(path, "r"))
  local content = file:read("*a")
  file:close()
  return content
end

local function write_file(path, content)
  local file = assert(io.open(path, "w"))
  file:write(content)
  file:close()
end

local function normalize_color(value, role)
  if value == nil or value == "" then
    error("missing Quickshell color value: " .. role)
  end

  return "#" .. tostring(value):gsub("^#", "")
end

function M.env_roles()
  local roles = {}
  local seen = {}

  local function add(role)
    if not seen[role] then
      table.insert(roles, role)
      seen[role] = true
    end
  end

  for _, field in ipairs(direct_fields) do
    add(field.env)
  end

  for _, field in ipairs(alpha_fields) do
    add(field.env)
  end

  return roles
end

function M.render(template_path, target_path, lookup)
  local content = read_file(template_path)

  for _, field in ipairs(direct_fields) do
    local value = normalize_color(lookup(field.env), field.env)
    local pattern = "(readonly%s+property%s+color%s+" .. field.qml .. "%s*:%s*\")[^\"]*(\")"
    local replacement = "%1" .. value .. "%2"
    local count
    content, count = content:gsub(pattern, replacement, 1)
    if count ~= 1 then
      error("missing Colors.qml color field: " .. field.qml)
    end
  end

  for _, field in ipairs(alpha_fields) do
    local value = normalize_color(lookup(field.env), field.env)
    local pattern = "(readonly%s+property%s+color%s+" .. field.qml .. "%s*:%s*withAlpha%s*%(%s*\")[^\"]*(\")"
    local replacement = "%1" .. value .. "%2"
    local count
    content, count = content:gsub(pattern, replacement, 1)
    if count ~= 1 then
      error("missing Colors.qml alpha color field: " .. field.qml)
    end
  end

  write_file(target_path, content)
end

function M.render_from_env(template_path, target_path)
  M.render(template_path, target_path, function(role)
    return os.getenv(role)
  end)
end

local function usage()
  io.stderr:write("Usage: lua lib/kitana-quickshell-colors.lua TEMPLATE TARGET\n")
end

if arg and arg[0] and arg[0]:match("kitana%-quickshell%-colors%.lua$") then
  if not arg[1] or not arg[2] then
    usage()
    os.exit(2)
  end

  M.render_from_env(arg[1], arg[2])
end

return M
