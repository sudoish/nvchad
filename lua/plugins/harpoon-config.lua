return {
  {
    'ThePrimeagen/harpoon',
    event = 'BufRead',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      -- REQUIRED
      harpoon:setup {}
      -- REQUIRED

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end)
      vim.keymap.set('n', '<leader>e', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      for i = 1, 9 do
        vim.keymap.set('n', '<leader>' .. i, function()
          harpoon:list():select(i)
        end)
      end

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<S-h>', function()
        harpoon:list():prev()
      end)
      vim.keymap.set('n', '<S-l>', function()
        harpoon:list():next()
      end)
    end,
  },
}
