-- Augment Code AI
return {
  "augmentcode/augment.vim",
  lazy = false,
  config = function()
    local map = vim.api.nvim_set_keymap

    -- map leader aa to trigger augment code
    map("n", "<leader>aa", ":Augment chat-toggle<CR>", { noremap = true, silent = true })
  end,
}
