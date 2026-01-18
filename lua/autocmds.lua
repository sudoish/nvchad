require "nvchad.autocmds"

-- Enforce transparent backgrounds after any colorscheme load
local function set_transparent()
  local groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "SignColumn",
    "LineNr",
    "CursorLine",
    "CursorLineNr",
    "Folded",
    "EndOfBuffer",
    "WinSeparator",
    "VertSplit",
    "StatusLine",
    "StatusLineNC",
    "TabLine",
    "TabLineFill",
    "TabLineSel",
    "Pmenu",
    "PmenuSel",
    "TelescopeNormal",
    "TelescopeBorder",
    "NvimTreeNormal",
    "NvimTreeEndOfBuffer",
  }
  for _, g in ipairs(groups) do
    pcall(vim.api.nvim_set_hl, 0, g, { bg = "NONE" })
  end
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("TransparentBG", { clear = true }),
  callback = set_transparent,
})

-- Detect .tidal files as Haskell for LSP support
-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   pattern = "*.tidal",
--   callback = function()
--     vim.bo.filetype = "haskell"
--   end,
-- })

-- Restore last opened file per project
require("project-last-file").setup()

return {}
