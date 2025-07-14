return {
  {
    'tpope/vim-fugitive',
    lazy = false,
    config = function()
      -- Git remaps
      vim.keymap.set('n', '<leader>gs', ':G<CR>', { desc = 'Git status' })
      vim.keymap.set('n', '<leader>ga', ':G add %<CR>', { desc = 'Git add current file' })
      vim.keymap.set('n', '<leader>gA', ':G add .<CR>', { desc = 'Git add all files' })
      vim.keymap.set('n', '<leader>gc', ':G commit --no-verify<CR>', { desc = 'Git commit' })

      local function pre_commit_check()
        local cmd = 'pre-commit'

        -- Run pre-commit hook on a split buffer bottom
        vim.cmd 'belowright vsplit'
        vim.cmd('terminal ' .. cmd)
      end

      -- Verify precommit hooks with pre-commit cmd
      vim.keymap.set('n', '<leader>gv', pre_commit_check, { desc = 'Git verify' })
      -- Push to current branch
      vim.keymap.set('n', '<leader>gp', ':G push origin HEAD<CR>', { desc = 'Git push' })
      vim.keymap.set('n', '<leader>gd', ':G diff<CR>', { desc = 'Git diff' })
      vim.keymap.set('n', '<leader>gl', ':G log<CR>', { desc = 'Git log' })
      vim.keymap.set('n', '<leader>gf', ':G fetch<CR>', { desc = 'Git fetch' })
      vim.keymap.set('n', '<leader>gF', ':G pull', { desc = 'Git pull' })
      vim.keymap.set('n', '<leader>gS', ':G stash<CR>', { desc = 'Git stash' })

      -- Create and checkout branch
      vim.keymap.set('n', '<leader>gbn', ':G checkout -b ', { desc = 'Git create and checkout branch' })
      vim.keymap.set('n', '<leader>gbc', ':G checkout ', { desc = 'Git checkout branch' })
      vim.keymap.set('n', '<leader>gbl', ':G branch -l<CR>', { desc = 'Git list branches' })
      vim.keymap.set('n', '<leader>gbb', ':G blame<CR>', { desc = 'Git blame' })
    end,
  },
  {
    'f-person/git-blame.nvim',
    event = 'BufRead',
    config = function()
      vim.cmd 'highlight default link gitblame SpecialComment'
      require('gitblame').setup { enabled = false }
    end,
  },
}
