-- Custom option configuration

local o = vim.o

o.relativenumber = true
o.foldmethod = "indent"
o.foldlevel = 99

o.scrolloff = 8
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true

vim.opt.list = true

-- vim.g.noshowmode = true
-- vim.g.noruler = true
-- vim.opt.laststatus = 0
vim.g.noshowcmd = true
vim.opt.cmdheight = 0
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.o.termguicolors = true
vim.opt.relativenumber = true
vim.opt.wrap = true

-- Avante plugin options
-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3

-- set rtp^="/Users/thiagopacheco/.opam/default/share/ocp-indent/vim"
vim.opt.rtp:append "/Users/thiagopacheco/.opam/default/share/ocp-indent/vim"

return {}
