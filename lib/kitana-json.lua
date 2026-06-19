local M = {}

local Parser = {}
Parser.__index = Parser

local function decode_error(parser, message)
  error(string.format("JSON parse error at byte %d: %s", parser.index, message), 0)
end

local function is_space(char)
  return char == " " or char == "\t" or char == "\n" or char == "\r"
end

local function is_digit(char)
  return char and char:match("%d") ~= nil
end

function Parser:new(text)
  return setmetatable({ text = text, index = 1, length = #text }, self)
end

function Parser:peek()
  return self.text:sub(self.index, self.index)
end

function Parser:skip_space()
  while self.index <= self.length and is_space(self:peek()) do
    self.index = self.index + 1
  end
end

function Parser:consume(expected)
  if self.text:sub(self.index, self.index + #expected - 1) ~= expected then
    decode_error(self, "expected " .. expected)
  end
  self.index = self.index + #expected
end

function Parser:parse_string()
  if self:peek() ~= '"' then
    decode_error(self, "expected string")
  end

  self.index = self.index + 1
  local chunks = {}

  while self.index <= self.length do
    local char = self:peek()

    if char == '"' then
      self.index = self.index + 1
      return table.concat(chunks)
    end

    if char == "\\" then
      self.index = self.index + 1
      local escaped = self:peek()
      local replacements = {
        ['"'] = '"',
        ["\\"] = "\\",
        ["/"] = "/",
        b = "\b",
        f = "\f",
        n = "\n",
        r = "\r",
        t = "\t",
      }

      if replacements[escaped] then
        chunks[#chunks + 1] = replacements[escaped]
        self.index = self.index + 1
      elseif escaped == "u" then
        local hex = self.text:sub(self.index + 1, self.index + 4)
        if not hex:match("^%x%x%x%x$") then
          decode_error(self, "invalid unicode escape")
        end
        local codepoint = tonumber(hex, 16)
        if codepoint < 128 then
          chunks[#chunks + 1] = string.char(codepoint)
        elseif utf8 and utf8.char then
          chunks[#chunks + 1] = utf8.char(codepoint)
        else
          decode_error(self, "non-ascii unicode escape is unsupported")
        end
        self.index = self.index + 5
      else
        decode_error(self, "invalid escape")
      end
    else
      chunks[#chunks + 1] = char
      self.index = self.index + 1
    end
  end

  decode_error(self, "unterminated string")
end

function Parser:parse_number()
  local start = self.index

  if self:peek() == "-" then
    self.index = self.index + 1
  end

  if self:peek() == "0" then
    self.index = self.index + 1
  elseif is_digit(self:peek()) then
    while is_digit(self:peek()) do
      self.index = self.index + 1
    end
  else
    decode_error(self, "invalid number")
  end

  if self:peek() == "." then
    self.index = self.index + 1
    if not is_digit(self:peek()) then
      decode_error(self, "invalid number fraction")
    end
    while is_digit(self:peek()) do
      self.index = self.index + 1
    end
  end

  local exponent = self:peek()
  if exponent == "e" or exponent == "E" then
    self.index = self.index + 1
    local sign = self:peek()
    if sign == "+" or sign == "-" then
      self.index = self.index + 1
    end
    if not is_digit(self:peek()) then
      decode_error(self, "invalid number exponent")
    end
    while is_digit(self:peek()) do
      self.index = self.index + 1
    end
  end

  return tonumber(self.text:sub(start, self.index - 1))
end

function Parser:parse_array()
  self.index = self.index + 1
  local result = {}

  self:skip_space()
  if self:peek() == "]" then
    self.index = self.index + 1
    return result
  end

  while true do
    result[#result + 1] = self:parse_value()
    self:skip_space()

    local char = self:peek()
    if char == "]" then
      self.index = self.index + 1
      return result
    elseif char == "," then
      self.index = self.index + 1
      self:skip_space()
      if self:peek() == "]" then
        self.index = self.index + 1
        return result
      end
    else
      decode_error(self, "expected , or ]")
    end
  end
end

function Parser:parse_object()
  self.index = self.index + 1
  local result = {}

  self:skip_space()
  if self:peek() == "}" then
    self.index = self.index + 1
    return result
  end

  while true do
    self:skip_space()
    local key = self:parse_string()
    self:skip_space()
    if self:peek() ~= ":" then
      decode_error(self, "expected :")
    end
    self.index = self.index + 1
    result[key] = self:parse_value()
    self:skip_space()

    local char = self:peek()
    if char == "}" then
      self.index = self.index + 1
      return result
    elseif char == "," then
      self.index = self.index + 1
      self:skip_space()
      if self:peek() == "}" then
        self.index = self.index + 1
        return result
      end
    else
      decode_error(self, "expected , or }")
    end
  end
end

function Parser:parse_value()
  self:skip_space()
  local char = self:peek()

  if char == '"' then
    return self:parse_string()
  elseif char == "{" then
    return self:parse_object()
  elseif char == "[" then
    return self:parse_array()
  elseif char == "-" or is_digit(char) then
    return self:parse_number()
  elseif self.text:sub(self.index, self.index + 3) == "true" then
    self.index = self.index + 4
    return true
  elseif self.text:sub(self.index, self.index + 4) == "false" then
    self.index = self.index + 5
    return false
  elseif self.text:sub(self.index, self.index + 3) == "null" then
    self.index = self.index + 4
    return nil
  end

  decode_error(self, "unexpected value")
end

function M.decode(text)
  local parser = Parser:new(text)
  local value = parser:parse_value()
  parser:skip_space()

  if parser.index <= parser.length then
    decode_error(parser, "trailing data")
  end

  return value
end

function M.strip_jsonc(text)
  local result = {}
  local index = 1
  local length = #text
  local in_string = false
  local escaped = false

  while index <= length do
    local char = text:sub(index, index)
    local next_char = text:sub(index + 1, index + 1)

    if in_string then
      result[#result + 1] = char
      if escaped then
        escaped = false
      elseif char == "\\" then
        escaped = true
      elseif char == '"' then
        in_string = false
      end
      index = index + 1
    elseif char == '"' then
      in_string = true
      result[#result + 1] = char
      index = index + 1
    elseif char == "/" and next_char == "/" then
      index = index + 2
      while index <= length do
        char = text:sub(index, index)
        if char == "\n" or char == "\r" then
          break
        end
        index = index + 1
      end
    elseif char == "/" and next_char == "*" then
      index = index + 2
      while index <= length - 1 do
        char = text:sub(index, index)
        next_char = text:sub(index + 1, index + 1)
        if char == "*" and next_char == "/" then
          index = index + 2
          break
        end
        if char == "\n" or char == "\r" then
          result[#result + 1] = char
        end
        index = index + 1
      end
    else
      result[#result + 1] = char
      index = index + 1
    end
  end

  return table.concat(result)
end

function M.decode_jsonc(text)
  return M.decode(M.strip_jsonc(text))
end

local function encode_string(value)
  local escaped = value:gsub('[%z\1-\31\\"]', function(char)
    local replacements = {
      ['"'] = '\\"',
      ["\\"] = "\\\\",
      ["\b"] = "\\b",
      ["\f"] = "\\f",
      ["\n"] = "\\n",
      ["\r"] = "\\r",
      ["\t"] = "\\t",
    }
    return replacements[char] or string.format("\\u%04x", char:byte())
  end)

  return '"' .. escaped .. '"'
end

local function is_array(value)
  local count = 0
  local max = 0

  for key in pairs(value) do
    if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
      return false
    end
    count = count + 1
    if key > max then
      max = key
    end
  end

  return count > 0 and count == max
end

local function sorted_keys(value)
  local keys = {}
  for key in pairs(value) do
    keys[#keys + 1] = key
  end
  table.sort(keys, function(a, b)
    return tostring(a) < tostring(b)
  end)
  return keys
end

local function encode_value(value, indent, level)
  local value_type = type(value)

  if value_type == "nil" then
    return "null"
  elseif value_type == "boolean" then
    return value and "true" or "false"
  elseif value_type == "number" then
    if value ~= value or value == math.huge or value == -math.huge then
      error("cannot encode non-finite number", 2)
    end
    return string.format("%.17g", value)
  elseif value_type == "string" then
    return encode_string(value)
  elseif value_type ~= "table" then
    error("cannot encode " .. value_type, 2)
  end

  local next_indent = indent and (level + 1) or 0
  local pad = indent and string.rep(indent, next_indent) or ""
  local close_pad = indent and string.rep(indent, level) or ""
  local separator = indent and ",\n" or ","
  local colon = indent and ": " or ":"

  if is_array(value) then
    local parts = {}
    for index = 1, #value do
      parts[#parts + 1] = pad .. encode_value(value[index], indent, next_indent)
    end
    if #parts == 0 then
      return "[]"
    end
    return "[\n" .. table.concat(parts, separator) .. "\n" .. close_pad .. "]"
  end

  local keys = sorted_keys(value)
  if #keys == 0 then
    return "{}"
  end

  local parts = {}
  for _, key in ipairs(keys) do
    parts[#parts + 1] = pad .. encode_string(tostring(key)) .. colon .. encode_value(value[key], indent, next_indent)
  end

  return "{\n" .. table.concat(parts, separator) .. "\n" .. close_pad .. "}"
end

function M.encode(value, options)
  options = options or {}
  return encode_value(value, options.indent, 0)
end

return M
