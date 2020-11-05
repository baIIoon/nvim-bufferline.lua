local M = {}

local vim,api = vim,vim.api
local highlights = require'bufferline/highlights'
local helpers = require'bufferline/helpers'
local Buffer = require'bufferline/buffers'.Buffer
local Buffers = require'bufferline/buffers'.Buffers
local devicons_loaded = require'bufferline/buffers'.devicons_loaded
local utils = require "bufferline/utils"
local colors = require "bufferline/colors"
-- string.len counts number of bytes and so the unicode icons are counted
-- larger than their display width. So we use nvim's strwidth
local strwidth = vim.fn.strwidth

---------------------------------------------------------------------------//
-- Constants
---------------------------------------------------------------------------//
local padding = " "

local superscript_numbers = {
  [0] = '⁰',
  [1] = '¹',
  [2] = '²',
  [3] = '³',
  [4] = '⁴',
  [5] = '⁵',
  [6] = '⁶',
  [7] = '⁷',
  [8] = '⁸',
  [9] = '⁹',
  [10] = '¹⁰',
  [11] = '¹¹',
  [12] = '¹²',
  [13] = '¹³',
  [14] = '¹⁴',
  [15] = '¹⁵',
  [16] = '¹⁶',
  [17] = '¹⁷',
  [18] = '¹⁸',
  [19] = '¹⁹',
  [20] = '²⁰'
}

local get_defaults
local bufferline, get_buffers_by_mode, get_valid_buffers, is_valid
local render_buffer, make_clickable, close_button, get_buffer_highlight, truncate_filename, get_tabs, render_tab, tab_click_component
local render, render_close, get_sections, truncate, get_marker_size, render_trunc_marker
local get_number_prefix, highlight_icon

-- TODO: Delete
-- 📛 Get plugin configuration variables {{{
-- Ideally this plugin should generate a beautiful tabline a little similar
-- to what you would get on other editors. The aim is that the default should
-- be so nice it's what anyone using this plugin sticks with. It should ideally
-- work across any well designed colorscheme deriving colors automagically.
function get_defaults()
  -- TODO add a fallback argument for get_hex
  local comment_fg = colors.get_hex('Comment', 'fg')
  local normal_fg = colors.get_hex('Normal', 'fg')
  local normal_bg = colors.get_hex('Normal', 'bg')
  local string_fg = colors.get_hex('String', 'fg')
  local tabline_sel_bg = colors.get_hex('TabLineSel', 'bg')
  if not tabline_sel_bg == "none" then
    tabline_sel_bg = colors.get_hex('WildMenu', 'bg')
  end

  -- If the colorscheme is bright we shouldn't do as much shading
  -- as this makes light color schemes harder to read
  local is_bright_background = colors.color_is_bright(normal_bg)
  local separator_shading = is_bright_background and -20 or -45
  local tabline_fill_shading = is_bright_background and -15 or -30
  local background_shading = is_bright_background and -12 or -25

  local tabline_fill_color = M.shade_color(normal_bg, tabline_fill_shading)
  local separator_background_color = M.shade_color(normal_bg, separator_shading)
  local background_color = M.shade_color(normal_bg, background_shading)

  return {
    options = {
      view = "default",
      numbers = "none",
      number_style = "superscript",
      close_icon = "",
      separator_style = 'thin',
      tab_size = 18,
      max_name_length = 18,
      mappings = false,
      show_buffer_close_icons = true,
      enforce_regular_tabs = false,
    };
    highlights = {
      bufferline_tab = {
        guifg = comment_fg,
        guibg = normal_bg,
      };
      bufferline_tab_selected = {
        guifg = comment_fg,
        guibg = tabline_sel_bg,
      };
      bufferline_tab_close = {
        guifg = comment_fg,
        guibg = background_color
      };
      bufferline_fill = {
        guifg = comment_fg,
        guibg = tabline_fill_color,
      };
      bufferline_background = {
        guifg = comment_fg,
        guibg = background_color,
      };
      bufferline_buffer_inactive = {
        guifg = comment_fg,
        guibg = normal_bg,
      };
      bufferline_modified = {
        guifg = string_fg,
        guibg = background_color,
      };
      bufferline_modified_inactive = {
        guifg = string_fg,
        guibg = normal_bg
      };
      bufferline_modified_selected = {
        guifg = string_fg,
        guibg = normal_bg
      };
      bufferline_separator = {
        guifg = separator_background_color,
        guibg = background_color,
      };
      bufferline_selected_indicator = {
        guifg = tabline_sel_bg,
        guibg = normal_bg,
      };
      bufferline_selected = {
        guifg = normal_fg,
        guibg = normal_bg,
        gui = "bold,italic",
      };
    }
  }
end
-- }}}





-- 📛 DATA
-- TODO: Highlight file type icons if possible
-- @see https://github.com/weirongxu/coc-explorer/blob/59bd41f8fffdc871fbd77ac443548426bd31d2c3/src/icons.nerdfont.json#L2
-- @param preferences table<string, string>
-- @return string
function M.bufferline(preferences) -- {{{
  -- DON'T NEED THIS NOW FOR VIM-BUFFET so only care about [get_valid_buffers()].
  local buf_nums, current_mode = M.get_buffers_by_mode(preferences.options.view)
  preferences.options.view = current_mode

  -- print(vim.inspect(buf_nums))

  local buffers = {}
  for i, buf_id in ipairs(buf_nums) do
      local name =  vim.fn.bufname(buf_id)
      local buf = Buffer:new {path = name, id = buf_id, ordinal = i}
      local render_fn, length = render_buffer(preferences, buf, 0)
      buf.length = length
      buf.component = render_fn
      buffers[i] = buf
  end

  local tabs = get_tabs()

  return render(buffers, tabs, preferences.options.close_icon)
end
-- }}}


-- 📛 DATA > [listed_buf]
-- Get buffer based on mode.
-- TODO: A function to handle "multiwindow" mode
-- If [mode] == "multiwindow" it will calculate before returning
-- get_valid_buffers().
-- Show only relevant buffers depending on the layout of the current tabpage:
--  1. In tabs with only one window all buffers are listed
--  2. In tabs with more than one window, only the buffers that are
--     being displayed are listed.
--- @param mode string | nil
function M.get_buffers_by_mode(mode) -- {{{
--[[
  show only relevant buffers depending on the layout of the current tabpage:
    - In tabs with only one window all buffers are listed.
    - In tabs with more than one window, only the buffers that are being displayed are listed.
--]]
  if mode == "multiwindow" then
    local current_tab = vim.fn.tabpagenr()
    local is_single_tab = vim.fn.tabpagenr('$') == 1
    local number_of_tab_wins = vim.fn.tabpagewinnr(current_tab, '$')
    local valid_wins = 0
    -- Check that the window contains a listed buffer, if the buffre isn't
    -- listed we shouldn't be hiding the remaining buffers because of it
    -- FIXME this is sending an invalid buf_nr to is_valid buf
    for i=1,number_of_tab_wins do
      local buf_nr = vim.fn.winbufnr(i)
      if is_valid(buf_nr) then
        valid_wins = valid_wins + 1
      end
    end
    if valid_wins > 1 and not is_single_tab then
      -- TODO filter out duplicates because currently I don't know
      -- how to make it clear which buffer relates to which window
      -- buffers don't have an identifier to say which buffer they are in
      local unique = helpers.filter_duplicates(vim.fn.tabpagebuflist())
      return get_valid_buffers(unique), mode
    end
  end
  return get_valid_buffers(), nil
end
-- }}}

-- Get valid buffers from nvim_list_bufs
-- TODO: Buffers class will calculate and return this
--- @param bufs table | nil
function get_valid_buffers(bufs) -- {{{
  local buf_nums = bufs or api.nvim_list_bufs()
  local valid_bufs = {}

  -- NOTE: In lua in order to iterate an array, indices should
  -- not contain gaps otherwise "ipairs" will stop at the first gap
  -- i.e the indices should be contiguous
  local count = 0
  for _,buf in ipairs(buf_nums) do
    if is_valid(buf) then
      count = count + 1
      valid_bufs[count] = buf
    end
  end
  return valid_bufs
end
-- }}}

-- The provided api nvim_is_buf_loaded filters out all hidden buffers
function is_valid(buf_num) -- {{{
  if not buf_num or buf_num < 1 then return false end
  local listed = vim.fn.getbufvar(buf_num, "&buflisted") == 1
  local exists = api.nvim_buf_is_valid(buf_num)
  return listed and exists
end
-- }}}

--- 📛 Data > components(fn), length
-- Calculate and return buffer component to render tabline?
-- Data looped is preserved for render()
-- TODO: Refactor
--[[
 In order to get the accurate character width of a buffer tab
 each buffer's length is manually calculated to avoid accidentally
 incorporating highlight strings into the buffer tab count
 e.g. %#HighlightName%filename.js should be 11 but strwidth will
 include the highlight in the count
 TODO
 Workout a function either using vim's regex or lua's to remove
 a highlight string. For example:
 -----------------------------------
  [WIP]
 -----------------------------------
 function get_actual_length(component)
  local formatted = string.gsub(component, '%%#.*#', '')
  return strwidth(formatted)
 end
--]]
--- @param preferences table
--- @param buffer Buffer
--- @param diagnostic_count number
--- @return function | number
function render_buffer(preferences, buffer, diagnostic_count) -- {{{
  -- print(vim.inspect(buffer))

  local options = preferences.options
  local buf_highlight, m_highlight, buffer_colors = get_buffer_highlight(
    buffer,
    preferences.highlights
  )
  local length = 0
  local is_current = buffer:is_current()
  local is_visible = buffer:visible()
  local is_modified = buffer.modifiable and buffer.modified

  local modified_icon = helpers.get_plugin_variable("modified_icon", "●")
  local modified_section = modified_icon..padding
  local m_size = strwidth(modified_section)
  local m_padding = string.rep(padding, m_size)

  local icon_size = strwidth(buffer.icon)
  local padding_size = strwidth(padding) * 2
  local max_file_size = options.max_name_length
  -- if we are enforcing regular tab size then all tabs will try and fit
  -- into the maximum tab size. If not we enforce a minimum tab size
  -- and allow tabs to be larger then the max otherwise
  if options.enforce_regular_tabs then
  -- estimate the maximum allowed size of a filename given that it will be
  -- padded an prefixed with a file icon
    max_file_size = options.tab_size - m_size - icon_size - padding_size
  end

  local filename = truncate_filename(buffer.filename, max_file_size)
  local component = padding..filename..padding
  length = length + strwidth(component)

  if buffer.icon then
    local icon_highlight = highlight_icon(buffer, buffer_colors)
    component = icon_highlight..buf_highlight..component
    length = length + strwidth(buffer.icon)
  end

  if not options.show_buffer_close_icons then
    -- If the buffer is modified add an icon, if it isn't pad
    -- the buffer so it doesn't "jump" when it becomes modified i.e. due
    -- to the sudden addition of a new character
    local suffix = is_modified and m_highlight..modified_section or m_padding
    component = m_padding..component..suffix
    length = length + (m_size * 2)
  end
  -- pad each tab smaller than the max tab size to make it consistent
  local difference = options.tab_size - length
  if difference > 0 then
    local pad = string.rep(padding, math.floor((difference / 2)))
    component = pad .. component .. pad
    length = length + strwidth(pad) * 2
  end

  if options.numbers ~= "none" then
    local number_prefix = get_number_prefix(
      buffer,
      options.numbers,
      options.number_style
    )
    local number_component = number_prefix .. padding
    component = number_component  .. component
    length = length + strwidth(number_component)
  end

  component = make_clickable(options.mode, component, buffer.id)

  if is_current then
    -- U+2590 ▐ Right half block, this character is right aligned so the
    -- background highlight doesn't appear in th middle
    -- alternatives:  right aligned => ▕ ▐ ,  left aligned => ▍
    local indicator_symbol = '▎'
    local indicator = highlights.indicator .. indicator_symbol .. '%*'

    length = length + strwidth(indicator_symbol)
    component = indicator .. buf_highlight .. component
  else
    -- since all non-current buffers do not have an indicator they need
    -- to be padded to make up the difference in size
    length = length + strwidth(padding)
    component = buf_highlight .. padding .. component
  end

  if diagnostic_count > 0 then
    local diagnostic_section = diagnostic_count..padding
    component = component..highlights.diagnostic..diagnostic_section
    length = length + strwidth(diagnostic_section)
  end

  if options.show_buffer_close_icons then
    local close_btn, size = close_button(buffer.id)
    local suffix = is_modified and m_highlight..modified_section or close_btn
    component = component .. buf_highlight .. suffix
    length = length + size
  end

  -- Use: https://en.wikipedia.org/wiki/Block_Elements
  local separator_component
  if options.separator_style == 'thick' then
    separator_component = (is_visible or is_current) and "▌" or "▐"-- "▍" "░"
  else
    separator_component = (is_visible or is_current) and "▏" or "▕"
  end

  local separator = highlights.separator..separator_component

  -- NOTE: the component is wrapped in an item -> %(content) so
  -- vim counts each item as one rather than all of its individual
  -- sub-components. Vim only allows a maximum of 80 items in a tabline
  -- so it is important that these are correctly group as one
  local buffer_component = "%("..component.."%)"

  -- We increment the buffer length by the separator although the final
  -- buffer will not have a separator so we are technically off by 1
  length = length + strwidth(separator_component)

  -- We return a function from render buffer as we do not yet have access to
  -- information regarding which buffers will actually be rendered

  --- @param index number
  --- @param num_of_bufs number
  --- @returns string
  local render_fn  = function (index, num_of_bufs)
    if index < num_of_bufs then
      buffer_component =  buffer_component .. separator
    end
    return buffer_component
  end

  return render_fn, length
end
-- }}}

--- @param mode string | nil
--- @param item string
--- @param buf_num number
function make_clickable(mode, item, buf_num) -- {{{
  if not vim.fn.has('tablineat') then return item end
  -- v:lua does not support function references in vimscript so
  -- the only way to implement this is using autoload viml functions
  if mode == "multiwindow" then
    return "%"..buf_num.."@nvim_bufferline#handle_win_click@"..item
  else
    return "%"..buf_num.."@nvim_bufferline#handle_click@"..item
  end
end
-- }}}

--- Close Button.
-- @param buf_id number
function close_button(buf_id) -- {{{
  local symbol = ""..padding
  local size = strwidth(symbol)
  return "%" .. buf_id .. "@nvim_bufferline#handle_close_buffer@".. symbol, size
end
-- }}}


function get_buffer_highlight(buffer, user_highlights) -- {{{
  local h = highlights
  local c = user_highlights

  if buffer:is_current() then
    return h.selected, h.modified_selected, c.bufferline_selected
  elseif buffer:visible() then
    return h.inactive, h.modified_inactive, c.bufferline_buffer_inactive
  else
    return h.background, h.modified, c.bufferline_background
  end
end
-- }}}

--- @param buffer Buffer
--- @param background table
--- @return string
function highlight_icon(buffer, background) -- {{{
  local icon = buffer.icon
  local hl = buffer.icon_highlight

  if not icon or icon == "" then return "" end
  if not hl or hl == "" then return icon end

  local hl_override = "Bufferline"..hl
  -- local hl_override = hl

  if background then
    local fg = colors.get_hex(hl, 'fg')
    if buffer:is_current() or buffer:visible() then
      hl_override = hl_override .. "Selected"
    end
    colors.set_highlight(hl_override, { guibg = background.guibg, guifg = fg })
  end
  return "%#"..hl_override.."#"..icon.."%*"
end
-- }}}

function get_number_prefix(buffer, mode, style) -- {{{
  local n = mode == "ordinal" and buffer.ordinal or buffer.id
  local num = style == "superscript" and superscript_numbers[n] or n .. "."
  return num
end
-- }}}

function truncate_filename(filename, word_limit) -- {{{
  local trunc_symbol = '…' -- '...'
  local too_long = string.len(filename) > word_limit
  if not too_long then
    return filename
  end
  -- truncate nicely by seeing if we can drop the extension first
  -- to make things fit if not then truncate abruptly
  local without_prefix = vim.fn.fnamemodify(filename, ":t:r")
  if string.len(without_prefix) < word_limit then
    return without_prefix .. trunc_symbol
  else
    return string.sub(filename, 0, word_limit - 1) .. trunc_symbol
  end
end
-- }}}

-- Tabs class
function get_tabs() -- {{{
  local all_tabs = {}
  local tabs = vim.fn.gettabinfo()
  local current_tab = vim.fn.tabpagenr()

  -- use ordinals to ensure a contiguous keys in the table i.e. an array
  -- rather than an object
  -- GOOD = {1: thing, 2: thing} BAD: {1: thing, [5]: thing}
  for i,tab in ipairs(tabs) do
    local is_active_tab = current_tab == tab.tabnr
    local component, length = render_tab(tab, is_active_tab)
    all_tabs[i] = {
      component = component,
      length = length,
      id = tab.tabnr,
      windows = tab.windows,
    }
  end
  return all_tabs
end
-- }}}

function render_tab(tab, is_active) -- {{{
  local hl = is_active and highlights.tab_selected or highlights.tab
  local name = padding..tab.tabnr..padding
  local length = strwidth(name)
  return hl .. tab_click_component(tab.tabnr) .. name, length
end
-- }}}

function tab_click_component(num) -- {{{
  return "%"..num.."T"
end
-- }}}





--- 📛 Get render (TABLINE) data: truncation
-- @param buffers Buffers
-- @param tabs table, TODO: Tabs class
--   @field id number
--   @field length number
--   @field windows table list of open windows
--   {
--       component = "%#BufferLineTabSelected#%1T 1 ",
--       id = 1,
--       length = 3,
--       windows = { 1000 }
--   }
function render(buffers, tabs, close_icon) -- {{{
  local right_align = "%="
  local tab_components = ""
  local close_component, close_length = render_close(close_icon)
  local tabs_length = close_length

  -- Add the length of the tabs + close components to total length
  if table.getn(tabs) > 1 then
    for _,t in pairs(tabs) do
      if not vim.tbl_isempty(t) then
        tabs_length = tabs_length + t.length
        tab_components = tab_components .. t.component
      end
    end
  end

  -- TODO: Use CONFIG > Characters class
  -- Icons from https://fontawesome.com/cheatsheet
  local left_trunc_icon = helpers.get_plugin_variable("left_trunc_marker", "")
  local right_trunc_icon = helpers.get_plugin_variable("right_trunc_marker", "")

  -- Measure the surrounding trunc items: padding + count + padding + icon + padding
  local left_element_size = strwidth(padding..padding..left_trunc_icon..padding..padding)
  local right_element_size = strwidth(padding..padding..right_trunc_icon..padding)

  local available_width = vim.o.columns - tabs_length - close_length
  local before, current, after = get_sections(buffers)

  -- print(vim.inspect(get_sections(buffers)))
  -- print(vim.inspect({["before"] = before}))
  -- print(vim.inspect({["current"] = current}))
  -- print(vim.inspect({["after"] = after}))

  local line, marker = truncate(
    before,
    current,
    after,
    available_width,
    {
      left_count = 0,
      right_count = 0,
      left_element_size = left_element_size,
      right_element_size = right_element_size,
    }
  )
  -- Line
  -- %(%#BufferLineBackground# %11@nvim_bufferline#handle_click@5.   %#BufferLineBackground#
  -- .gitignore   %#BufferLineBackground#%11@nvim_bufferline#handle_close_buffer@ %)%#BufferL
  -- ineSeparator#▕%(%#BufferLineSelectedIndicator#▎%*%#BufferLineSelected#%12@nvim_bufferline
  -- #handle_click@6.    %#BufferLineSelected# [No Name]    %#BufferLineSelected#%12@nvim_buf
  -- ferline#handle_close_buffer@ %)
  -- %(%#BufferLineSelectedIndicator#▎%*%#BufferLineSelected#%11@nvim_bufferline#handle_click@
  -- 5.   %#BufferLineSelected# .gitignore   %#BufferLineSelected#%11@nvim_bufferline#handle_
  -- close_buffer@ %)%#BufferLineSeparator#▏%(%#BufferLineBackground# %12@nvim_bufferline#han
  -- dle_click@6.    %#BufferLineBackground# [No Name]    %#BufferLineBackground#%12@nvim_buf
  -- ferline#handle_close_buffer@ %)
  -- %(%#BufferLineSelectedIndicator#▎%*%#BufferLineSelected#%9@nvim_bufferline#handle_click@4
  -- . %#BufferLineSelected# .vintrc[1].yaml %#BufferLineSelected#%9@nvim_bufferline#handle_c
  -- lose_buffer@ %)%#BufferLineSeparator#▏%(%#BufferLineBackground# %11@nvim_bufferline#hand
  -- le_click@5.   %#BufferLineBackground# .gitignore   %#BufferLineBackground#%11@nvim_buffe
  -- rline#handle_close_buffer@ %)

  -- Marker
  -- {
  --   left_count = 3,
  --   left_element_size = 5,
  --   right_count = 3,
  --   right_element_size = 4
  -- }

  if marker.left_count > 0 then
    local icon = render_trunc_marker(marker.left_count, left_trunc_icon)
    line = highlights.background..icon..padding..line
  end
  if marker.right_count > 0 then
    local icon = render_trunc_marker(marker.right_count, right_trunc_icon)
    line = line..highlights.background..icon
  end

  -- print(line..highlights.fill..right_align..tab_components..highlights.close..close_component)
  return line..highlights.fill..right_align..tab_components..highlights.close..close_component
end
-- }}}

function render_close(icon) -- >> Render() {{{
  local component = padding .. icon .. padding
  return component, strwidth(component)
end
-- }}}

function get_sections(buffers) -- {{{
  local current = Buffers:new()
  local before = Buffers:new()
  local after = Buffers:new()

  for _,buf in ipairs(buffers) do
    if buf:is_current() then
      current:insert(buf)
    -- We haven't reached the current buffer yet
    elseif current.length == 0 then
      before:insert(buf)
    else
      after:insert(buf)
    end
  end
  return before, current, after
end
-- }}}

-- PREREQUISITE: active buffer always remains in view
-- 1. Find amount of available space in the window
-- 2. Find the amount of space the bufferline will take up
-- 3. If the bufferline will be too long remove one tab from the before or after
-- section
-- 4. Re-check the size, if still too long truncate recursively till it fits
-- 5. Add the number of truncated buffers as an indicator
function truncate(before, current, after, available_width, marker) -- {{{
  local line = ""
  local left_trunc_marker = get_marker_size(marker.left_count, marker.left_element_size)
  local right_trunc_marker = get_marker_size(marker.right_count, marker.right_element_size)
  local markers_length = left_trunc_marker + right_trunc_marker
  local total_length = before.length + current.length + after.length + markers_length

  if available_width >= total_length then
    -- Merge all the buffers and render the components
    local buffers = helpers.array_concat(
      before.buffers,
      current.buffers,
      after.buffers
    )
    for index,buf in ipairs(buffers) do
      line = line .. buf.component(index, table.getn(buffers))
    end
    return line, marker
  -- if we aren't even able to fit the current buffer into the
  -- available space that means the window is really narrow
  -- so don't show anything
  elseif available_width < current.length then
    return "", marker
  else
    if before.length >= after.length then
      before:drop(1)
      marker.left_count = marker.left_count + 1
    else
      after:drop(#after.buffers)
      marker.right_count = marker.right_count + 1
    end
    -- drop the markers if the window is too narrow
    -- this assumes we have dropped both before and after
    -- sections since if the space available is this small
    -- we have likely removed these
    if (current.length + markers_length) > available_width then
      marker.left_count = 0
      marker.right_count = 0
    end
    return truncate(before, current, after, available_width, marker), marker
  end
end
-- }}}


function get_marker_size(count, element_size) -- {{{
  return count > 0 and strwidth(count) + element_size or 0
end
-- }}}

function render_trunc_marker(count, icon) -- {{{
  return highlights.fill..padding..count..padding..icon..padding
end
-- }}}





















return M
