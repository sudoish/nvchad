-- Move to left split with ctrl h
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left split' })
-- Move to right split with ctrl l
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right split' })
-- Move to top split with ctrl k
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top split' })
-- Move to bottom split with ctrl j
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom split' })

local map = vim.keymap.set

map('n', ';', ':', { desc = 'CMD enter command mode' })
map('i', 'jk', '<ESC>')

-- map("n", "<Leader>m", ":NvimTreeToggle <cr>", { desc = "Open file tree" })

map('n', '<Leader>q', ':q<cr>', { desc = 'Close buffer' })
map('n', '<Leader>fs', ':w<cr>', { desc = 'Save file' })

map('t', '<esc>', '<C-\\><C-n>')

-- Open terminal with leader ;
map('n', '<Leader>;', ':term<cr>i', { desc = 'Open terminal' })

-- Evaluate current file to update neovim with leader x
map('n', '<Leader>x', ':luafile %<cr>', { desc = 'Evaluate current file' })

return {}
