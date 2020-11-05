-----------------------------------------------------------------------------
--                              Utility classes                            --
-----------------------------------------------------------------------------

local utils = {}

local api = vim.api

local Color = {}
function Color:new()
end

--- Create augroup.
-- @see https://teukka.tech/luanvim.html
local function nvim_create_augroups(definitions) -- {{{
  for group_name, definition in pairs(definitions) do
    vim.cmd('augroup '..group_name)
    vim.cmd('autocmd!')
    for _,def in pairs(definition) do
      local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
      vim.cmd(command)
    end
    vim.cmd('augroup END')
  end
end
-- }}}

--- Highlight class, helps to handle Vim highlight
local Highlight = {}

--- Static method
function Highlight:get_hex(hl_name, part, fallback)
  if not fallback then fallback = "none" end
  local id = vim.fn.hlID(hl_name)
  local color = vim.fn.synIDattr(id, part)
  -- if we can't find the color we default to none
  if not color or color == "" then return fallback else return color end
end

function Highlight:__table_size(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

--- Static method
function Highlight:set_highlight(name, hl)
  if hl and self:table_size(hl) > 0 then
    local cmd = "highlight! "..name
    if hl.gui and hl.gui ~= "" then
      cmd = cmd.." ".."gui="..hl.gui
    end
    if hl.guifg and hl.guifg ~= "" then
      cmd = cmd.." ".."guifg="..hl.guifg
    end
    if hl.guibg and hl.guibg ~= "" then
      cmd = cmd.." ".."guibg="..hl.guibg
    end
    -- TODO using api here as it warns of an error if setting highlight fails
    local success, err = pcall(api.nvim_command, cmd)
    if not success then
      api.nvim_err_writeln(
        "Failed setting "..name.." highlight, something isn't configured correctly".."\n"..err
      )
    end
  end
end


--- Hex Color class.
-- @param hex string eg: "#ff8800"
local HexColor = {} -- {{{

function HexColor:new(hex)
  local hexcolor = {}
  hexcolor.hex = hex
  self.__index = self
  return setmetatable(hexcolor, self)
end


function HexColor:__to_rgb()
  local r = tonumber(string.sub(self.hex, 2,3), 16)
  local g = tonumber(string.sub(self.hex, 4,5), 16)
  local b = tonumber(string.sub(self.hex, 6), 16)
  return {r, g, b}
end

-- Lighten or darken the color.
-- @param percent number positive for lightening and vice versa
-- @see https://stackoverflow.com/questions/5560248/programmatically-lighten-or-darken-a-hex-color-or-rgb-and-blend-colors
function HexColor:shade_color(percent)
  local r,g,b = unpack(self:__to_rgb())

  -- If any of the colors are missing return "NONE" i.e. no highlight
  if not r or not g or not b then return "NONE" end

  r = math.floor(tonumber(r * (100 + percent) / 100))
  g = math.floor(tonumber(g * (100 + percent) / 100))
  b = math.floor(tonumber(b * (100 + percent) / 100))

  r = r < 255 and r or 255
  g = g < 255 and g or 255
  b = b < 255 and b or 255

  -- See: https://stackoverflow.com/questions/37796287/convert-decimal-to-hex-in-lua-4
  r = string.format("%x", r)
  g = string.format("%x", g)
  b = string.format("%x", b)

  local rr = string.len(r) == 1 and "0" .. r or r
  local gg = string.len(g) == 1 and "0" .. g or g
  local bb = string.len(b) == 1 and "0" .. b or b

  return "#"..rr..gg..bb
end

--- Determine whether to use black or white text
-- @see https://stackoverflow.com/a/1855903/837964
-- @see https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color
function HexColor:is_bright()
  if not self.hex then
    return false
  end
  local r,g,b = unpack(self:__to_rgb())
  -- If any of the colors are missing return false
  if not r or not g or not b then return false end
  -- Counting the perceptive luminance - human eye favors green color
  local luminance = (0.299*r + 0.587*g + 0.114*b)/255
  if luminance > 0.5 then
    return true -- Bright colors, black font
  else
    return false -- Dark colors, white font
  end
end
-- }}}

--- Color class.
-- @field hex string eg: "#ffffff"
local Color = {}

function Color:new(hex) -- {{{
  self.__index = self
  return setmetatable({
    hex = hex
  }, self)
end
-- }}}

function Color:__to_rgb() -- {{{
  local r = tonumber(string.sub(self.hex, 2,3), 16)
  local g = tonumber(string.sub(self.hex, 4,5), 16)
  local b = tonumber(string.sub(self.hex, 6), 16)
  return {r, g, b}
end
-- }}}

--- If right then use black or white text
-- @see https://stackoverflow.com/a/1855903/837964
-- @see https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color
function Color:is_bright() -- {{{
  -- Counting the perceptive luminance - human eye favors green color.
  local r,g,b = unpack(self:__to_rgb())

  if not r or not g or not b then return false end

  local luminance = (0.299*r + 0.587*g + 0.114*b)/255
  if luminance > 0.5 then return true end
  return false
end
-- }}}

--- Lighten or darken the color.
-- @param percent number positive for lightening and vice versa
-- @see https://stackoverflow.com/questions/5560248/programmatically-lighten-or-darken-a-hex-color-or-rgb-and-blend-colors
function Color:shade_color(percent) -- {{{
  local r, g, b = unpack(self:__to_rgb())

  -- If any of the colors are missing return "NONE" i.e. no highlight
  if not r or not g or not b then return "NONE" end

  r = math.floor(tonumber(r * (100 + percent) / 100))
  g = math.floor(tonumber(g * (100 + percent) / 100))
  b = math.floor(tonumber(b * (100 + percent) / 100))

  r = r < 255 and r or 255
  g = g < 255 and g or 255
  b = b < 255 and b or 255

  -- see:
  -- https://stackoverflow.com/questions/37796287/convert-decimal-to-hex-in-lua-4
  r = string.format("%x", r)
  g = string.format("%x", g)
  b = string.format("%x", b)

  local rr = string.len(r) == 1 and "0" .. r or r
  local gg = string.len(g) == 1 and "0" .. g or g
  local bb = string.len(b) == 1 and "0" .. b or b

  return "#"..rr..gg..bb
end
-- }}}


utils.nvim_create_augroups = nvim_create_augroups
utils.Highlight = Highlight
utils.Color = Color

return utils
