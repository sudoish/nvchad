-- options
local o = vim.o

vim.g.mapleader = " "

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
vim.o.cmdheight = 1
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
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.o.termguicolors = true
vim.opt.relativenumber = true
vim.opt.wrap = true

vim.g.autoformat_enabled = true
vim.g.cmp_enabled = true
vim.g.diagnostics_mode = 3
vim.g.icons_enabled = true
vim.g.ui_notifications_enabled = true

local vscode = require "vscode"

vim.keymap.set("n", "<leader>fs", function()
  vscode.action "workbench.action.files.save"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>q", function()
  vscode.action "workbench.action.closeActiveEditor"
end, { noremap = true, silent = true })

vim.keymap.set("n", "-", function()
  vscode.action "workbench.files.action.focusFilesExplorer"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<S-h>", function()
  vscode.action "workbench.action.previousEditor"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<S-l>", function()
  vscode.action "workbench.action.nextEditor"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>z", function()
  vscode.action "workbench.action.toggleZenMode"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>;", function()
  vscode.action "workbench.action.createTerminalEditor"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>dd", function()
  vscode.action "editor.action.changeAll"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>tt", function()
  vscode.action "testing.runAtCursor"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>tf", function()
  vscode.action "testing.runCurrentFile"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>d", function()
  vscode.action "testing.debugAtCursor"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>b", function()
  vscode.action "editor.debug.action.toggleBreakpoint"
end, { noremap = true, silent = true })

vim.keymap.set("n", "gd", function()
  vscode.action "editor.action.goToDeclaration"
end, { noremap = true, silent = true })

vim.keymap.set("n", "gb", function()
  vscode.action "workbench.action.navigateBack"
end, { noremap = true, silent = true })

vim.keymap.set("n", "gf", function()
  vscode.action "workbench.action.navigateForward"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>sf", function()
  vscode.action "workbench.action.quickOpen"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>sg", function()
  vscode.action "workbench.action.findInFiles"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>fs", function()
  vscode.action "workbench.action.files.save"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>gs", function()
  vscode.action "gitlens.gitCommands.status"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>gc", function()
  vscode.action "git.commit"
end, { noremap = true, silent = true })

vim.keymap.set("n", "K", function()
  vscode.action "editor.action.showHover"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>pp", function()
  vscode.action "workbench.action.files.openFileFolder"
end, { noremap = true, silent = true })

vim.keymap.set("n", "za", function()
  vscode.action "editor.toggleFold"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>D", function()
  vscode.action "editor.debug.action.showDebugHover"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>lg", function()
  vscode.action "lazygit.openLazygit"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>ps", function()
  vscode.action "projectManager.listProjects"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>pe", function()
  vscode.action "projectManager.editProjects"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>pa", function()
  vscode.action "projectManager.addToWorkspace"
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>rn", function()
  vscode.action "editor.action.rename"
end, { noremap = true, silent = true })

-- open chat with leader + l
vim.keymap.set("n", "<leader>l", function()
  vscode.action "aichat.newchataction"
end, { noremap = true, silent = true })

-- open command edit with leader + k
vim.keymap.set("n", "<leader>k", function()
  vscode.action "aipopup.action.modal.generate"
end, { noremap = true, silent = true })
