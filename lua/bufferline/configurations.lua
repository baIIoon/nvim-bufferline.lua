-----------------------------------------------------------------------------
--                        Plugin configuration variables                   --
-----------------------------------------------------------------------------

local config = {}

local vim, api = vim, vim.api
-- local colors = require "bufferline/colors"
local utils = require("bufferline/utils")
local Color = utils.Color

local has_devicons, web_devicons = pcall(require, 'nvim-web-devicons')
if has_devicons then web_devicons.setup() end

-- Declare classes
local Option, Character, Highlight

--- Get plugin configuration variables
-- @param user_cfg table User configuration variables
local function get_config_var(user_cfg) -- {{{
  return {
    options = Option:new(user_cfg['options']),
    characters = Character:new(user_cfg['characters']),
    highlights = Highlight:new(user_cfg['highlights']),
  }
end
-- }}}

--- Set highlights: Plugin and Devicons
local function set_highlights() -- {{{
  function _G.__setup_bufferline_colors()
    local user_colors = _G._CONFIG.highlights
    Highlight.set_highlight('BufferLineTab', user_colors.bufferline_tab)
    Highlight.set_highlight('BufferLineTabSelected', user_colors.bufferline_tab_selected)
    Highlight.set_highlight('BufferLineTabClose', user_colors.bufferline_tab_close)
    Highlight.set_highlight('BufferLineFill', user_colors.bufferline_fill)
    Highlight.set_highlight('BufferLineBackground', user_colors.bufferline_background)
    Highlight.set_highlight('BufferLineInactive', user_colors.bufferline_buffer_inactive)
    Highlight.set_highlight('BufferLineSelected', user_colors.bufferline_selected)
    Highlight.set_highlight('BufferLineSelectedIndicator', user_colors.bufferline_selected_indicator)
    Highlight.set_highlight('BufferLineModified', user_colors.bufferline_modified)
    Highlight.set_highlight('BufferLineModifiedSelected', user_colors.bufferline_modified_selected)
    Highlight.set_highlight('BufferLineModifiedInactive', user_colors.bufferline_modified_inactive)
    Highlight.set_highlight('BufferLineSeparator', user_colors.bufferline_separator)
  end

  local autocommands = {
    {"VimEnter", "*", [[lua __setup_bufferline_colors()]]};
    {"ColorScheme", "*", [[lua __setup_bufferline_colors()]]};
  }

  if has_devicons then
    table.insert(autocommands, {"ColorScheme", "*", [[lua require'nvim-web-devicons'.setup()]]})
  end

  utils.nvim_create_augroups({ BufferlineColors = autocommands })
end
-- }}}

--- Option class
-- @field always_show_tabline boolean show if there's more than one buffer(tab) open
Option = {}

--- Create new instance of Option class
-- @param opt table holding data used during creation
function Option:new(opt) -- {{{
  opt = opt or {}
  opt.view = "default" -- "multiwindow", TODO: "default" => ""
  opt.numbers = opt["numbers"] or "none" -- "ordinal", "buffer_id",
  opt.number_style = opt["number_style"] or "superscript" -- ""
  opt.close_icon = "" -- TODO: Delete
  opt.separator_style = 'thin' -- "thick"
  opt.tab_size = 18
  opt.max_name_length = 18
  opt.mappings = opt["mappings"] or false
  opt.show_buffer_close_icons = true
  opt.enforce_regular_tabs = false

  self.__index = self
  return setmetatable(opt, self)
end
-- }}}

--- Character class
Character = {}

function Character:new(c) -- {{{
  c = c or {}

  self.__index = self
  return setmetatable({
    new_buffer = "*",
    tab = "#",
    separator = "",
    modified = "+",
    left_trunc = "<",
    right_trunc = ">",
  }, self)
end
-- }}}

--- Highlight class
Highlight = {}
-- TODO: Highlights based on Colorscheme, ideally this plugin should
-- generate a beautiful tabline a little similar
-- to what you would get on other editors. The aim is that the default should
-- be so nice it's what anyone using this plugin sticks with. It should ideally
-- work across any well designed colorscheme deriving colors automagically
function Highlight:new(hl) -- {{{
  hl = hl or {}
  self.__index = self

  local comment_fg = Highlight.get_hex('Comment', 'fg')
  local normal_fg = Highlight.get_hex('Normal', 'fg')
  local normal_bg = Highlight.get_hex('Normal', 'bg')
  local string_fg = Highlight.get_hex('String', 'fg')
  local tabline_sel_bg = Highlight.get_hex('TabLineSel', 'bg')
  if not tabline_sel_bg == "none" then
    tabline_sel_bg = Highlight.get_hex('WildMenu', 'bg')
  end

  -- If the colorscheme is bright we shouldn't do as much shading
  -- as this makes light color schemes harder to read
  local is_bright_background = Color:new(normal_bg):is_bright()
  local separator_shading = is_bright_background and -20 or -45
  local tabline_fill_shading = is_bright_background and -15 or -30
  local background_shading = is_bright_background and -12 or -25

  local tabline_fill_color = Color:new(normal_bg):shade_color(tabline_fill_shading)
  local separator_background_color = Color:new(normal_bg):shade_color(separator_shading)
  local background_color = Color:new(normal_bg):shade_color(background_shading)

  -- TODO: Hl class & deep_merge
  local hls = {
    bufferline_tab = hl.bufferline_tab or {
      guifg = comment_fg,
      guibg = normal_bg,
    },
    bufferline_tab_selected = hl.bufferline_tab_selected or {
      guifg = comment_fg,
      guibg = tabline_sel_bg,
    },
    bufferline_tab_close = hl.bufferline_tab_close or {
      guifg = comment_fg,
      guibg = background_color
    },
    bufferline_fill = hl.bufferline_fill or {
      guifg = comment_fg,
      guibg = tabline_fill_color,
    },
    bufferline_background = hl.bufferline_background or {
      guifg = comment_fg,
      guibg = background_color,
    },
    bufferline_buffer_inactive = hl.bufferline_buffer_inactive or {
      guifg = comment_fg,
      guibg = normal_bg,
    },
    bufferline_selected = hl.bufferline_selected or {
      guifg = normal_fg,
      guibg = normal_bg,
      gui = "bold,italic",
    },
    bufferline_selected_indicator = hl.bufferline_selected_indicator or {
      guifg = tabline_sel_bg,
      guibg = normal_bg,
    },
    bufferline_modified = hl.bufferline_modified or {
      guifg = string_fg,
      guibg = background_color,
    },
    bufferline_modified_selected = hl.bufferline_modified_selected or {
      guifg = string_fg,
      guibg = normal_bg
    },
    bufferline_modified_inactive = hl.bufferline_modified_inactive or {
      guifg = string_fg,
      guibg = normal_bg
    },
    bufferline_separator = hl.bufferline_separator or {
      guifg = separator_background_color,
      guibg = background_color,
    },
  }

  -- Set highlights {{{
  function _G.__setup_bufferline_colors()
    -- local user_colors = _G._CONFIG.highlights
    Highlight.set_highlight('BufferLineTab', hls.bufferline_tab)
    Highlight.set_highlight('BufferLineTabSelected', hls.bufferline_tab_selected)
    Highlight.set_highlight('BufferLineTabClose', hls.bufferline_tab_close)
    Highlight.set_highlight('BufferLineFill', hls.bufferline_fill)
    Highlight.set_highlight('BufferLineBackground', hls.bufferline_background)
    Highlight.set_highlight('BufferLineInactive', hls.bufferline_buffer_inactive)
    Highlight.set_highlight('BufferLineSelected', hls.bufferline_selected)
    Highlight.set_highlight('BufferLineSelectedIndicator', hls.bufferline_selected_indicator)
    Highlight.set_highlight('BufferLineModified', hls.bufferline_modified)
    Highlight.set_highlight('BufferLineModifiedSelected', hls.bufferline_modified_selected)
    Highlight.set_highlight('BufferLineModifiedInactive', hls.bufferline_modified_inactive)
    Highlight.set_highlight('BufferLineSeparator', hls.bufferline_separator)
  end

  local autocommands = {
    {"VimEnter", "*", [[lua __setup_bufferline_colors()]]};
    {"ColorScheme", "*", [[lua __setup_bufferline_colors()]]};
  }

  if has_devicons then
    table.insert(autocommands, {"ColorScheme", "*", [[lua require'nvim-web-devicons'.setup()]]})
  end

  utils.nvim_create_augroups({ BufferlineColors = autocommands })
  -- }}}

  setmetatable(hls, self)
  return hls
end
-- }}}

function Highlight.get_hex(hl_name, part, fallback) -- {{{
  if not fallback then fallback = "none" end
  local id = vim.fn.hlID(hl_name)
  local color = vim.fn.synIDattr(id, part)
  -- if we can't find the color we default to none
  if not color or color == "" then return fallback else return color end
end
-- }}}

function Highlight.set_hls() -- {{{
  function _G.__setup_bufferline_colors()
    local user_colors = _G._CONFIG.highlights
    Highlight.set_highlight('BufferLineTab', user_colors.bufferline_tab)
    Highlight.set_highlight('BufferLineTabSelected', user_colors.bufferline_tab_selected)
    Highlight.set_highlight('BufferLineTabClose', user_colors.bufferline_tab_close)
    Highlight.set_highlight('BufferLineFill', user_colors.bufferline_fill)
    Highlight.set_highlight('BufferLineBackground', user_colors.bufferline_background)
    Highlight.set_highlight('BufferLineInactive', user_colors.bufferline_buffer_inactive)
    Highlight.set_highlight('BufferLineSelected', user_colors.bufferline_selected)
    Highlight.set_highlight('BufferLineSelectedIndicator', user_colors.bufferline_selected_indicator)
    Highlight.set_highlight('BufferLineModified', user_colors.bufferline_modified)
    Highlight.set_highlight('BufferLineModifiedSelected', user_colors.bufferline_modified_selected)
    Highlight.set_highlight('BufferLineModifiedInactive', user_colors.bufferline_modified_inactive)
    Highlight.set_highlight('BufferLineSeparator', user_colors.bufferline_separator)
  end

  local autocommands = {
    {"VimEnter", "*", [[lua __setup_bufferline_colors()]]};
    {"ColorScheme", "*", [[lua __setup_bufferline_colors()]]};
  }

  if has_devicons then
    table.insert(autocommands, {"ColorScheme", "*", [[lua require'nvim-web-devicons'.setup()]]})
  end

  utils.nvim_create_augroups({ BufferlineColors = autocommands })
end
-- }}}

function Highlight.set_highlight(name, hl) -- {{{
  local function table_size(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
  end

  if hl and table_size(hl) > 0 then
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
-- }}}

function config.setup(opts)
  opts = opts or {}

  -- NOTE: the plural.
  config.options = Option:new(opts.options)
  config.character = Character:new(opts.character)
  config.highlights = Highlight:new(opts.highlights)
end

config.has_devicons = has_devicons
-- config.get_config_var = get_config_var
-- config.set_highlights = set_highlights

return config
