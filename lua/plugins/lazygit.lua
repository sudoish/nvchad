return {
  "kdheepak/lazygit.nvim",
  lazy = true,
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- optional for floating window border decoration
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
  },
  config = function()
    local function lazygit_cancel()
      local curr_buf = vim.api.nvim_get_current_buf()
      local curr_buf_name = vim.api.nvim_buf_get_name(curr_buf)

      print("curr_buf_name: ", curr_buf_name)
    end

    -- Cancel lazygit action with <esc>
    vim.keymap.set("i", "<C-W>", lazygit_cancel, { desc = "Cancel lazygit action" })
  end,
}
