vim.keymap.set('n', '<leader>on', ':ObsidianNew<CR>', { desc = 'Create new note' })
vim.keymap.set('n', '<leader>oo', ':ObsidianOpen<CR>', { desc = 'Open note' })
-- Obsidian links
vim.keymap.set('n', '<leader>olf', ':ObsidianFollowLink<CR>', { desc = 'Follow obsidian link' })
vim.keymap.set('n', '<leader>olb', ':ObsidianBacklinks<CR>', { desc = 'Get references' })
vim.keymap.set('n', '<leader>or', ':ObsidianRename<CR>', { desc = 'Rename note' })
vim.keymap.set('n', '<leader>od', ':ObsidianToday<CR>', { desc = 'Open daily note' })
vim.keymap.set('n', '<leader>os', ':ObsidianSearch<CR>', { desc = 'Search note' })
vim.keymap.set('n', '<leader>ot', ':ObsidianTemplate<CR>', { desc = 'Use template' })

return {
    'epwalsh/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = false,
    ft = 'markdown',
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
        -- Required.
        'nvim-lua/plenary.nvim',

        -- see below for full list of optional dependencies 👇
    },
    opts = {
        workspaces = {
            {
                name = 'personal',
                path = '~/personal',
            },
            -- {
            --   name = "work",
            --   path = "~/vaults/work",
            -- },
        },
    },
}
