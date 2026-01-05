-- Supermaven AI completion
return {
  "supermaven-inc/supermaven-nvim",
  lazy = false,
  config = function()
    -- remove lsp mapping tht uses <Tab> for completion
    -- ensure lsp completion is done with Enter only
    vim.api.nvim_set_keymap("i", "<Tab>", "<C-n>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("i", "<S-Tab>", "<C-p>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("i", "<C-j>", "<C-n>", { noremap = true, silent = true })

    require("supermaven-nvim").setup {
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      -- ignore_filetypes = { cpp = true }, -- or { "cpp", }
      color = {
        -- suggestion_color = "#00ff00",
        -- cterm = 244,
      },
      log_level = "off", -- set to "off" to disable logging completely
      disable_inline_completion = false, -- disables inline completion for use with cmp
      disable_keymaps = false, -- disables built in keymaps for more manual control
      condition = function()
        return false
      end,
    }
  end,
}
