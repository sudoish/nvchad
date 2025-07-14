return {
  'stevearc/oil.nvim',
  opts = {
    skip_confirm_for_simple_edits = true,
  },
  event = 'BufEnter',
  -- Optional dependencies
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  config = function()
    require('oil').setup()
    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    vim.keymap.set('n', '_', '<CMD>Oil .<CR>', { desc = 'Open root directory' })
  end,
}
