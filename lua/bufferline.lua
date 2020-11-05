
-- local colors = require "bufferline/colors"
local vim,api = vim, vim.api
local config = require "bufferline/configurations"
-- local config = require("buffet/config")

-- local buffet = {
--   shade_color = colors.shade_color -- ???
-- }
local buffet = {}

-- local truncate_long

-- THE ROOT OF EVIL
-- TODO then validate user preferences and only set prefs that exists => WHY?
function buffet.setup(prefs) -- {{{

  -- Fuse Default opts with User opts.
  -- Preferences {{{
  -- TODO: Delete
  -- local preferences = get_defaults()
  -- -- Combine user preferences with defaults preferring the user's own settings
  -- -- NOTE this should happen outside any of these inner functions to prevent the
  -- -- value being set within a closure
  -- if prefs and type(prefs) == "table" then
  --   helpers.deep_merge(preferences, prefs)
  -- end
  -- }}}
  -- _G._CONFIG = configurations.get_config_var(prefs)
  -- local preferences = configurations.get_config_var(prefs)
  config.setup(prefs)
  local preferences = config

  -- Augroup highlights {{{
  -- TODO: Delete
  -- function _G.__setup_bufferline_colors()
  --   local user_colors = preferences.highlights
  --   colors.set_highlight('BufferLineFill', user_colors.bufferline_fill)
  --   colors.set_highlight('BufferLineInactive', user_colors.bufferline_buffer_inactive)
  --   colors.set_highlight('BufferLineBackground', user_colors.bufferline_background)
  --   colors.set_highlight('BufferLineSelected', user_colors.bufferline_selected)
  --   colors.set_highlight('BufferLineSelectedIndicator', user_colors.bufferline_selected_indicator)
  --   colors.set_highlight('BufferLineModified', user_colors.bufferline_modified)
  --   colors.set_highlight('BufferLineModifiedSelected', user_colors.bufferline_modified_selected)
  --   colors.set_highlight('BufferLineModifiedInactive', user_colors.bufferline_modified_inactive)
  --   colors.set_highlight('BufferLineTab', user_colors.bufferline_tab)
  --   colors.set_highlight('BufferLineSeparator', user_colors.bufferline_separator)
  --   colors.set_highlight('BufferLineTabSelected', user_colors.bufferline_tab_selected)
  --   colors.set_highlight('BufferLineTabClose', user_colors.bufferline_tab_close)
  -- end
  --
  -- local autocommands = {
  --   {"VimEnter", "*", [[lua __setup_bufferline_colors()]]};
  --   -- {"ColorScheme", "*", [[lua __setup_bufferline_colors()]]};
  --   {"ColorScheme", "*", [[lua __setup_bufferline_colors()]]};
  -- }
  -- if devicons_loaded then
  --   table.insert(autocommands, {"ColorScheme", "*", [[lua require'nvim-web-devicons'.setup()]]})
  -- end
  --
  -- utils.nvim_create_augroups({ BufferlineColors = autocommands })
  -- }}}
  -- configurations.set_highlights()


  -- The user's preferences are passed inside of a closure so they are accessible
  -- inside the globally defined lua function which is passed to the tabline setting
  function _G.buffet_tabline()
    -- print(listed_bufs:current_listed_bufid())
    -- local listed_bufs = require("bufferline/data").ListedBuffer:new()
    -- local x,y,z = truncate_long(listed_bufs, vim.o.columns - 10)
    -- print(x, y, vim.inspect(z))



    -- for _, buf in ipairs(listed_bufs.bufs) do
    --   print(buf:getFilename())
    -- end
    -- print(listed_bufs.curr)

    return require("bufferline/render").bufferline(preferences)
  end

  -- TODO: Put this somewhere else.
  -- Mappings {{{
  -- TODO / idea: consider allowing these mappings to open buffers based on their
  -- visual position i.e. <leader>1 maps to the first visible buffer regardless
  -- of it actual ordinal number i.e. position in the full list or it's actual
  -- buffer id
  if preferences.options.mappings then
    for i=1, 9 do
      api.nvim_set_keymap('n', '<leader>'..i, ':lua require"buffet".go_to_buffer('..i..')<CR>', {
          silent = true, nowait = true, noremap = true
        })
    end
  end
  -- }}}

  vim.o.showtabline = 2
  vim.o.tabline = "%!v:lua.buffet_tabline()"
  -- vim.o.tabline = bufferline(preferences) -- work but not update

end

local function recursive(capacity)
  if capacity >= 10 then
    return 1, 1, {3, 5}
  end

  return recursive(capacity)
end
-- }}}

-- TODO: Use Recursion, return {visible length}.
function truncate_long(listed_bufs, capacity) -- {{{
  local sep_len = 1
  local bufs_length = table.getn(listed_bufs.bufs)
  local total_length = listed_bufs:get_length() + (bufs_length - 1) * sep_len

  -- print("Bufs length: " .. bufs_length)
  -- print("Total length: " .. total_length)
  --jrint("Filename length: " .. string.len(listed_bufs.bufs[1]:getFilename()))

  if capacity >= total_length then
    -- print("Cap: " .. capacity)
    -- print("Total: " .. total_length)
    -- print("ENOUGH")
    return 0, 0, {1, bufs_length}
  end

  if capacity < listed_bufs.bufs[listed_bufs.curr]:getLength() then
    -- print("NOT EVEN 1")
    return 0, 0, {0, 0}
  end

  -- Truncation.
  local left_idx = 1
  local right_idx = bufs_length
  total_length = listed_bufs:get_length(left_idx, right_idx)

  while (capacity <= total_length) do
    if listed_bufs.curr - left_idx > right_idx - listed_bufs.curr then
      print("OOP" .. (listed_bufs.curr - left_idx))
      capacity = capacity - listed_bufs.bufs[left_idx]:getLength() - sep_len
      left_idx = left_idx + 1
    else
      capacity = capacity - listed_bufs.bufs[right_idx]:getLength() - sep_len
      right_idx = right_idx - 1
    end
    total_length = listed_bufs:get_length(left_idx, right_idx)
  end

  local left_count = left_idx - 1
  local right_count = bufs_length - right_idx

  return left_count, right_count, {left_idx, right_idx}
end
-- }}}

-- Mappings
function buffet.go_to_buffer(num) -- {{{
  local buf_nums = require("bufferline/render").get_buffers_by_mode()
  if num <= table.getn(buf_nums) then
    vim.cmd("buffer "..buf_nums[num])
  end
end
-- }}}

function buffet.handle_close_buffer(buf_id) -- {{{
  vim.cmd("bdelete ".. buf_id)
end
-- }}}

function buffet.handle_win_click(id) -- {{{
  local win_id = vim.fn.bufwinid(id)
  vim.fn.win_gotoid(win_id)
end
-- }}}

function buffet.handle_click(id) -- {{{
  if id then
    vim.cmd('buffer '..id)
  end
end
-- }}}

return buffet
