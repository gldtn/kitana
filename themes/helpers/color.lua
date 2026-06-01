local M = {}

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

local function normalize(hex)
  if type(hex) ~= "string" then
    error("color must be a string", 3)
  end

  local value = hex:lower():match("^#?(%x%x%x%x%x%x)$")
  if not value then
    error("color must be #rrggbb or rrggbb: " .. hex, 3)
  end

  return value
end

local function channels(hex)
  local value = normalize(hex)
  return tonumber(value:sub(1, 2), 16), tonumber(value:sub(3, 4), 16), tonumber(value:sub(5, 6), 16)
end

local function hex_channel(value)
  return string.format("%02x", math.floor(value + 0.5))
end

function M.strip(hex)
  return normalize(hex)
end

function M.alpha(hex, alpha)
  if type(alpha) ~= "string" or not alpha:match("^%x%x$") then
    error("alpha must be a two-digit hex string", 2)
  end

  return "#" .. alpha:lower() .. normalize(hex)
end

function M.mix(from, to, ratio)
  ratio = clamp(ratio, 0, 1)

  local fr, fg, fb = channels(from)
  local tr, tg, tb = channels(to)
  local inverse = 1 - ratio

  return "#"
    .. hex_channel(fr * inverse + tr * ratio)
    .. hex_channel(fg * inverse + tg * ratio)
    .. hex_channel(fb * inverse + tb * ratio)
end

function M.lighten(hex, ratio)
  return M.mix(hex, "#ffffff", ratio)
end

function M.darken(hex, ratio)
  return M.mix(hex, "#000000", ratio)
end

return M
