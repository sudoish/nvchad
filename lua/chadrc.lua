-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "tokyonight",
  transparency = true,

  -- Force transparency for common groups still setting bg
  hl_override = {
    Normal = { bg = "NONE" },
    NormalNC = { bg = "NONE" },
    NormalFloat = { bg = "NONE" },
    FloatBorder = { bg = "NONE" },
    SignColumn = { bg = "NONE" },
    LineNr = { bg = "NONE" },
    CursorLine = { bg = "NONE" },
    CursorLineNr = { bg = "NONE" },
    Folded = { bg = "NONE" },
    EndOfBuffer = { bg = "NONE" },
    WinSeparator = { bg = "NONE" },
    VertSplit = { bg = "NONE" },

    -- statusline/tabline
    StatusLine = { bg = "NONE" },
    StatusLineNC = { bg = "NONE" },
    TabLine = { bg = "NONE" },
    TabLineFill = { bg = "NONE" },
    TabLineSel = { bg = "NONE" },

    -- popup/menu
    Pmenu = { bg = "NONE" },
    PmenuSel = { bg = "NONE" },

    -- Telescope
    TelescopeNormal = { bg = "NONE" },
    TelescopeBorder = { bg = "NONE" },

    -- Trees/sidebars (NvChad often uses nvim-tree)
    NvimTreeNormal = { bg = "NONE" },
    NvimTreeEndOfBuffer = { bg = "NONE" },
  },
}

M.nvdash = { load_on_startup = true }
M.ui = {
  tabufline = {
    enabled = false,
  },
}

return M
