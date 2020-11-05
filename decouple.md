# ✌  Contributing

✅ 😰


## 🎨 User Interface
### 1. Config
- Plugin's Options
- Characters (icons)
- Highlights

### 2. Data (buffers, tabs)
#### Component
#### Current listed buffer
#### Identical filename
FUNCTION handle identical filename
  IN: buffers
  COUNT identical filenames
  REMEMBER them as key
  SET buffers[key] = count
  OUT: buffers
END

### 3. Tabline
#### Truncation
FUNCTION truncate process
  IN: tabs, buffers

END

#### Separators


## 🔩 Functionalities
### Vimscripts
Keep using buffet#bwipe, buffet#bonly.

### Lua
Rewrite buffet#bswitch because it's related to the data.






## Table of contents
- [Learning Resources](#learning-resources)
- [Environment](#environment)
- [`vim-buffet`](#vim-buffet)
- [`nvim-bufferline.lua`](#nvim-bufferline.lua)
- [Flow](#flow)



## Learning Resources
- `:h status-line`, `:h statusline`, `:h tabline`, `:h setting-tabline`,
- [The Last Statusline for Vim](https://medium.com/hackernoon/the-last-statusline-for-vim-a613048959b2) - *he also includes some other resources*
Sign column, side column, remember for both statusline and tabline, nvim_lines_count?



## Environment
Uncommnet local plugin then Save (do not recache), then test it somewhere else.



## `vim-buffet`
```vim
%1T%#BuffetTab# 🥑 %#BuffetTabLeftTrunc# %T%#BuffetLeftTrunc# < 1 %#BuffetLeftTruncBuffer# %4@SwitchToBuffer@%#BuffetBuffer# 2 themes.dart %#BuffetBufferBuffer#›%T%5@SwitchToBuffer@%#BuffetBuffer# 3 bitrise.yml %#BuffetBufferBuffer#›%T%7@SwitchToBuffer@%#BuffetBuffer# 4 modules.linter.dart %#BuffetBufferCurrentBuffer# %T%9@SwitchToBuffer@%#BuffetCurrentBuffer# 5 test_registration.yaml %#BuffetCurrentBufferEnd# %T%#BuffetBuffer#
```
### Bugs
- [ ] Tab cycle (gt) is wrong order



### `nvim-bufferline.lua`
```vim
%#BufferLineBackground#%#BufferLineFill# 4   %(%#BufferLineBackground# %11@nvim_bufferline#handle_click@5.    %#BufferlineMdDevIcon#%*%#BufferLineBackground# buffet.md    %#BufferLineBackground#%11@nvim_bufferline#handle_close_buffer@ %)%#BufferLineSeparator#▕%(%#BufferLineSelectedIndicator#▎%*%#BufferLineSelected#%13@nvim_bufferline#handle_click@6. %#BufferlineMdDevIconSelected#%*%#BufferLineSelected# vim.md     %#BufferLineSelected#%13@nvim_bufferline#handle_close_buffer@ %)%#BufferLineSeparator#▏%(%#BufferLineBackground# %14@nvim_bufferline#handle_click@7.    %#BufferlineDefaultDevIcon#%*%#BufferLineBackground# [No Name]    %#BufferLineBackground#%14@nvim_bufferline#handle_close_buffer@ %)%#BufferLineBackground#%#BufferLineFill# 1  %#BufferLineFill#%=%#BufferLineTab#%1T 1 %#BufferLineTab#%2T 2 %#BufferLineTabSelected#%3T 3 %#BufferLineTabClose#%999X 
```

```vim
%(%#BufferLineBackground# %1@nvim_bufferline#handle_click@%#BufferLineBackground# bufferline_with_m… %#BufferLineBackground#%1@nvim_bufferline#handle_close_buffer@ %)%#BufferLineSeparator#▕%(%#BufferLineBackground# %4@nvim_bufferline#handle_click@  %#BufferLineBackground# helpers.lua   %#BufferLineBackground#%4@nvim_bufferline#handle_close_buffer@ %)%#BufferLineSeparator#▕%(%#BufferLineBackground# %6@nvim_bufferline#handle_click@  %#BufferLineBackground# .gitignore   %#BufferLineBackground#%6@nvim_bufferline#handle_close_buffer@ %)%#BufferLineSeparator#▕%(%#BufferLineSelectedIndicator#▎%*%#BufferLineSelected#%7@nvim_bufferline#handle_click@   %#BufferLineSelected# [No Name]    %#BufferLineSelected#%7@nvim_bufferline#handle_close_buffer@ %)%#BufferLineFill#%=%#BufferLineTab#%1T 1 %#BufferLineTabSelected#%2T 2 %#BufferLineTabClose#%999X 
```
```
> %(%#BufferLineBackground# %1@nvim_bufferline#handle_click@%#BufferLineBackground# bufferline_with_m… %#BufferLineBackground#%1@nvim_bufferline#handle_close_buffer@ %)
> %#BufferLineSeparator#▕
> %(%#BufferLineBackground# %4@nvim_bufferline#handle_click@  %#BufferLineBackground# helpers.lua   %#BufferLineBackground#%4@nvim_bufferline#handle_close_buffer@ %)
> %#BufferLineSeparator#▕
> %(%#BufferLineBackground# %6@nvim_bufferline#handle_click@  %#BufferLineBackground# .gitignore   %#BufferLineBackground#%6@nvim_bufferline#handle_close_buffer@ %)
> %#BufferLineSeparator#▕
> %(%#BufferLineSelectedIndicator#▎%*%#BufferLineSelected#%7@nvim_bufferline#handle_click@   %#BufferLineSelected# [No Name]    %#BufferLineSelected#%7@nvim_bufferline#handle_close_buffer@ %)
> %#BufferLineFill#%
> =%#BufferLineTab#%1T 1 %#BufferLineTabSelected#%2T 2 %#BufferLineTabClose#%999X 
```


## 1. Successfully render
1. Prefenrences (options), default + user
Characters (icons), highlights, options, devicons, etc
2. Buffers data (classes)
  - List of buffer data like name, icon, etc
  - vim-buffet > buffet#update()
  - nvim.bufferline.lua > bufferline(), render_buffer()
  - Buffer class
  - Buffers class OR function that render a valid list of Buffer
  - [LATER] mode
3. Handle identical filename ([Buffers] => [Buffers](processed))
4. Handle long buffer items (truncation)
5. Render

## 2. [LATER] Functionalities - still using the old VimL one

## 3. Refactor
Code structure, styleguide, design patterns, etc

## 4. Rewrite functionalities in Lua
- Bswitch, Bw[!], Bonly[!], Bcycle, etc

## 5. Implement bufferline's features & Github's project manager
- Mode
- Filename length limited

## 6. Implement my idea features
- Tab mapping like `coc-explorer`

## 7. Search & learn more from other buffer plugins




## Buffers - nvim.bufferline.lua
{
    buftype = "",
    component = <function 1>,
    extension = "json_bak",
    filename = "coc-settings.json_bak",
    icon = "",
    id = 1,
    length = 25,
    modifiable = true,
    modified = false,
    ordinal = 1,
    path = "coc-settings.json_bak",
    <metatable> = <1>{
      __index = <table 1>,
      is_current = <function 2>,
      new = <function 3>,
      visible = <function 4>
    }
  }, {
    buftype = "",
    component = <function 5>,
    extension = "json",
    filename = "coc-settings.json",
    icon = "",
    id = 4,
    length = 27,
    modifiable = true,
    modified = false,
    ordinal = 2,
    path = "coc-settings.json",
    <metatable> = <table 1>
  }, {
    buftype = "",
    component = <function 6>,
    extension = "",
    filename = ".netrwhist",
    icon = "",
    id = 6,
    length = 24,
    modifiable = true,
    modified = false,
    ordinal = 3,
    path = ".netrwhist",
    <metatable> = <table 1>
  }, {
    buftype = "",
    component = <function 7>,
    extension = "",
    filename = ".gitignore",
    icon = "",
    id = 8,
    length = 24,
    modifiable = true,
    modified = false,
    ordinal = 4,
    path = ".gitignore",
    <metatable> = <table 1>
  }, {
    buftype = "",
    component = <function 8>,
    extension = "vim",
    filename = "init.vim",
    icon = "",
    id = 10,
    length = 24,
    modifiable = true,
    modified = false,
    ordinal = 5,
    path = "init.vim",
    <metatable> = <table 1>
  }, {
    buftype = "",
    component = <function 9>,
    extension = "",
    filename = "[No Name]",
    icon = "",
    id = 11,
    length = 25,
    modifiable = true,
    modified = false,
    ordinal = 6,
    path = "[No Name]",
    <metatable> = <table 1>
  }, {
    buftype = "",
    component = <function 10>,
    extension = "",
    filename = "[No Name]",
    icon = "",
    id = 12,
    length = 25,
    modifiable = true,
    modified = false,
    ordinal = 7,
    path = "[No Name]",
    <metatable> = <table 1>
  } 
}


## Tabs
{ 
  {  
    component = "%#BufferLineTab#%1T 1 ",                                                                      
    id = 1,
    length = 3,
    windows = { 1000 }
  }, {
    component = "%#BufferLineTab#%2T 2 ",
    id = 2,
    length = 3,
    windows = { 1001 }
  }, {
    component = "%#BufferLineTab#%3T 3 ",
    id = 3,
    length = 3,
    windows = { 1002 }
  }, {
    component = "%#BufferLineTab#%4T 4 ",
    id = 4,
    length = 3,
    windows = { 1003 }
  }, {
    component = "%#BufferLineTabSelected#%5T 5 ",
    id = 5,
    length = 3,
    windows = { 1004 }
  } 
}


## Render
{
   before = {
    buffers = { {
        buftype = "",
        component = <function 1>,
        extension = "json",
        filename = "coc-settings.json",
        icon = "",
        id = 1,
        length = 27,
        modifiable = true,
        modified = false,
        ordinal = 1,
        path = "coc-settings.json",
        <metatable> = <1>{
          __index = <table 1>,
          is_current = <function 2>,
          new = <function 3>,
          visible = <function 4>
        }
      }, {
        buftype = "",
        component = <function 5>,
        extension = "json_bak",
        filename = "coc-settings.json_bak",
        icon = "",
        id = 4,
        length = 25,
        modifiable = true,
        modified = false,
        ordinal = 2,
        path = "coc-settings.json_bak",
        <metatable> = <table 1>
      }, {
        buftype = "",
        component = <function 6>,
        extension = "",
        filename = ".netrwhist",
        icon = "",
        id = 6,
        length = 24,        
        modifiable = true,
        modified = false,
        ordinal = 3,
        path = ".netrwhist",
        <metatable> = <table 1>
      }, {
        buftype = "",
        component = <function 7>,
        extension = "yaml",
        filename = ".vintrc[1].yaml",
        icon = "",
        id = 8,
        length = 25,
        modifiable = true,
        modified = false,
        ordinal = 4,
        path = ".vintrc[1].yaml",
        <metatable> = <table 1>
      } },
    length = 101,
    <metatable> = <2>{
      __add = <function 8>,
      __index = <table 2>,
      drop = <function 9>,
      insert = <function 10>,
      new = <function 11>
    }
  }
 },
 {
  current = {
    buffers = { {
        buftype = "",
        component = <function 1>,
        extension = "",
        filename = ".gitignore",
        icon = "",
        id = 10,
        length = 24,
        modifiable = true,
        modified = false,
        ordinal = 5,
        path = ".gitignore",
        <metatable> = <1>{
          __index = <table 1>,
          is_current = <function 2>,
          new = <function 3>,
          visible = <function 4>
        }
      } },
    length = 24,
    <metatable> = <2>{
      __add = <function 5>,
      __index = <table 2>,
      drop = <function 6>,
      insert = <function 7>,
      new = <function 8>
    }
  }
 }, 
 {
   after = {
    buffers = { {
        buftype = "",
        component = <function 1>,
        extension = "vim",
        filename = "init.vim",
        icon = "",
        id = 12,
        length = 24,
        modifiable = true,
        modified = false,
        ordinal = 6,
        path = "init.vim",
        <metatable> = <1>{
          __index = <table 1>,
          is_current = <function 2>,
          new = <function 3>,
          visible = <function 4>
        }
      }, {
        buftype = "",
        component = <function 5>,
        extension = "",
        filename = "[No Name]",
        icon = "",
        id = 13,
        length = 25,
        modifiable = true,
        modified = false,
        ordinal = 7,
        path = "[No Name]",
        <metatable> = <table 1>
      }, {
        buftype = "",
        component = <function 6>,
        extension = "",
        filename = "[No Name]",
        icon = "",
        id = 14,
        length = 25,
        modifiable = true,
        modified = false,
        ordinal = 8,
        path = "[No Name]",
        <metatable> = <table 1>
      } },
    length = 74,
    <metatable> = <2>{
      __add = <function 7>,
      __index = <table 2>,
      drop = <function 8>,
      insert = <function 9>,
      new = <function 10>
    }
  }
}

# ✌  Mechanism





# Vim Buffet
## Table of contents
- [🔩 `plugin/buffet.vim`](#--pluginbuffet.vim)
- [📦 `autoload/buffet.vim`](#)
- [UI](#)

## 🔩 `plugin/buffet.vim`
- Configuration variables
- Buffet highlights

```vim
BuffetCurrentBuffer xxx ctermfg=8 ctermbg=2 guifg=#000000 guibg=#00FF00
                   links to Function
BuffetActiveBuffer xxx ctermfg=2 ctermbg=10 guifg=#00FF00 guibg=#999999
                   links to StatusLineNC
BuffetBuffer   xxx ctermfg=8 ctermbg=10 guifg=#000000 guibg=#999999
                   links to Visual
BuffetModCurrentBuffer xxx links to BuffetCurrentBuffer
BuffetModActiveBuffer xxx links to BuffetActiveBuffer
BuffetModBuffer xxx links to BuffetBuffer
BuffetTrunc    xxx cterm=bold ctermfg=8 ctermbg=11 guifg=#000000 guibg=#999999
BuffetTab      xxx ctermfg=8 ctermbg=4 guifg=#000000 guibg=#0000FF
                   links to Keyword
BuffetLeftTrunc xxx links to BuffetTrunc
BuffetRightTrunc xxx links to BuffetTrunc
BuffetEnd      xxx links to BuffetBuffer
BuffetModCurrentBufferModCurrentBuffer xxx links to BuffetModCurrentBuffer
BuffetModCurrentBufferModBuffer xxx guibg=#253340
BuffetModCurrentBufferBuffer xxx guibg=#253340
BuffetModCurrentBufferEnd xxx guibg=#253340
BuffetModCurrentBufferModActiveBuffer xxx guibg=#14191f
BuffetModCurrentBufferTab xxx links to BuffetModCurrentBuffer
BuffetModCurrentBufferActiveBuffer xxx guibg=#14191f
BuffetModCurrentBufferRightTrunc xxx guibg=#999999
BuffetModCurrentBufferCurrentBuffer xxx links to BuffetModCurrentBuffer
BuffetModBufferModCurrentBuffer xxx guifg=#253340
BuffetModBufferModBuffer xxx links to BuffetModBuffer
BuffetModBufferBuffer xxx links to BuffetModBuffer
BuffetModBufferEnd xxx links to BuffetModBuffer
BuffetModBufferModActiveBuffer xxx guifg=#253340 guibg=#14191f
BuffetModBufferTab xxx guifg=#253340
BuffetModBufferActiveBuffer xxx guifg=#253340 guibg=#14191f
BuffetModBufferRightTrunc xxx guifg=#253340 guibg=#999999
BuffetModBufferCurrentBuffer xxx guifg=#253340
BuffetLeftTruncModBuffer xxx guifg=#999999 guibg=#253340
BuffetLeftTruncActiveBuffer xxx guifg=#999999 guibg=#14191f
BuffetLeftTruncCurrentBuffer xxx guifg=#999999
BuffetLeftTruncBuffer xxx guifg=#999999 guibg=#253340
BuffetBufferModCurrentBuffer xxx guifg=#253340
BuffetBufferModBuffer xxx links to BuffetBuffer
BuffetBufferBuffer xxx links to BuffetBuffer
BuffetBufferEnd xxx links to BuffetBuffer
BuffetBufferModActiveBuffer xxx guifg=#253340 guibg=#14191f
BuffetBufferTab xxx guifg=#253340
BuffetBufferActiveBuffer xxx guifg=#253340 guibg=#14191f
BuffetBufferRightTrunc xxx guifg=#253340 guibg=#999999
BuffetBufferCurrentBuffer xxx guifg=#253340
BuffetModActiveBufferModCurrentBuffer xxx guifg=#14191f
BuffetModActiveBufferModBuffer xxx guifg=#14191f guibg=#253340
BuffetModActiveBufferBuffer xxx guifg=#14191f guibg=#253340
BuffetModActiveBufferEnd xxx guifg=#14191f guibg=#253340
BuffetModActiveBufferModActiveBuffer xxx links to BuffetModActiveBuffer
BuffetModActiveBufferTab xxx guifg=#14191f
BuffetModActiveBufferActiveBuffer xxx links to BuffetModActiveBuffer
BuffetModActiveBufferRightTrunc xxx guifg=#14191f guibg=#999999
BuffetModActiveBufferCurrentBuffer xxx guifg=#14191f
BuffetTabModCurrentBuffer xxx links to BuffetTab
BuffetTabModBuffer xxx guibg=#253340
BuffetTabLeftTrunc xxx guibg=#999999
BuffetTabActiveBuffer xxx guibg=#14191f
BuffetTabEnd   xxx guibg=#253340
BuffetTabModActiveBuffer xxx guibg=#14191f
BuffetTabTab   xxx links to BuffetTab
BuffetTabCurrentBuffer xxx links to BuffetTab
BuffetTabBuffer xxx guibg=#253340
BuffetActiveBufferModCurrentBuffer xxx guifg=#14191f
BuffetActiveBufferModBuffer xxx guifg=#14191f guibg=#253340
BuffetActiveBufferBuffer xxx guifg=#14191f guibg=#253340
BuffetActiveBufferEnd xxx guifg=#14191f guibg=#253340
BuffetActiveBufferModActiveBuffer xxx links to BuffetActiveBuffer
BuffetActiveBufferTab xxx guifg=#14191f
BuffetActiveBufferActiveBuffer xxx links to BuffetActiveBuffer
BuffetActiveBufferRightTrunc xxx guifg=#14191f guibg=#999999
BuffetActiveBufferCurrentBuffer xxx guifg=#14191f
BuffetRightTruncEnd xxx guifg=#999999 guibg=#253340
BuffetRightTruncTab xxx guifg=#999999
BuffetCurrentBufferModCurrentBuffer xxx links to BuffetCurrentBuffer
BuffetCurrentBufferModBuffer xxx guibg=#253340
BuffetCurrentBufferBuffer xxx guibg=#253340
BuffetCurrentBufferEnd xxx guibg=#253340
BuffetCurrentBufferModActiveBuffer xxx guibg=#14191f
BuffetCurrentBufferTab xxx links to BuffetCurrentBuffer
BuffetCurrentBufferActiveBuffer xxx guibg=#14191f
BuffetCurrentBufferRightTrunc xxx guibg=#999999
BuffetCurrentBufferCurrentBuffer xxx links to BuffetCurrentBuffer

{
  "ModCurrentBuffer": {
    "ModCurrentBuffer": "›",
    "ModBuffer": "›",
    "Buffer": "›",
    "End": "›",
    "ModActiveBuffer": "›",
    "Tab": "›",
    "ActiveBuffer": "›",
    "RightTrunc": "›",
    "CurrentBuffer": "›"
  },
  "ModBuffer": {
    "ModCurrentBuffer": "›",
    "ModBuffer": "›",
    "Buffer": "›",
    "End": "›",
    "ModActiveBuffer": "›",
    "Tab": "›",
    "ActiveBuffer": "›",
    "RightTrunc": "›",
    "CurrentBuffer": "›"
  },
  "LeftTrunc": {
    "ModBuffer": "›",
    "ActiveBuffer": "›",
    "CurrentBuffer": "›",
    "Buffer": "›"
  },
  "Buffer": {
    "ModCurrentBuffer": "›",
    "ModBuffer": "›",
    "Buffer": "›",
    "End": "›",
    "ModActiveBuffer": "›",
    "Tab": "›",
    "ActiveBuffer": "›",
    "RightTrunc": "›",
    "CurrentBuffer": "›"
  },
  "ModActiveBuffer": {
    "ModCurrentBuffer": "›",
    "ModBuffer": "›",
    "Buffer": "›",
    "End": "›",
    "ModActiveBuffer": "›",
    "Tab": "›",
    "ActiveBuffer": "›",
    "RightTrunc": "›",
    "CurrentBuffer": "›"
  },
  "Tab": {
    "ModCurrentBuffer": "›",
    "ModBuffer": "›",
    "LeftTrunc": "›",
    "ActiveBuffer": "›",
    "End": "›",
    "ModActiveBuffer": "›",
    "Tab": "›",
    "CurrentBuffer": "›",
    "Buffer": "›"
  },
  "ActiveBuffer": {
    "ModCurrentBuffer": "›",
    "ModBuffer": "›",
    "Buffer": "›",
    "End": "›",
    "ModActiveBuffer": "›",
    "Tab": "›",
    "ActiveBuffer": "›",
    "RightTrunc": "›",
    "CurrentBuffer": "›"
  },
  "RightTrunc": {
    "End": "›",
    "Tab": "›"
  },
  "CurrentBuffer": {
    "ModCurrentBuffer": "›",
    "ModBuffer": "›",
    "Buffer": "›",
    "End": "›",
    "ModActiveBuffer": "›",
    "Tab": "›",
    "ActiveBuffer": "›",
    "RightTrunc": "›",
    "CurrentBuffer": "›"
  }
}
```

## 📦 autoload/buffet.vim
Basically contains functions to calculate the tabline format.

- Tab icon 1️⃣ :one:, checkout Symbols in Github emoji, :u5272: :aries:

## Perfomance considers
- ```vim
let s:buffer = [
  {
    ... data
  },
  {},
]
```
- Instead of looping, checking and skipping, I would use check the unlisted buffers than the buflisted('$') will be added into `s:buffers` without worring about that the data will be wrong (I tested it)

## UI
- Bold Index
