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

-- Claude Code hooks user commands
local claude_hooks = require "ai-tools.claude-hooks"

vim.api.nvim_create_user_command("ClaudeHooksSetup", function()
  claude_hooks.setup()
end, { desc = "Setup Claude Code hooks" })

vim.api.nvim_create_user_command("ClaudeHooksCleanup", function()
  claude_hooks.cleanup()
end, { desc = "Remove Claude Code hooks" })

vim.api.nvim_create_user_command("ClaudeHooksStatus", function()
  if claude_hooks.check_configured() then
    vim.notify("Claude Code hooks are configured", vim.log.levels.INFO)
  else
    vim.notify("Claude Code hooks are not configured", vim.log.levels.WARN)
  end
end, { desc = "Check Claude Code hooks status" })

return {}
