require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<Leader>q", ":q<cr>", { desc = "Close buffer" })
map("n", "<Leader>fs", ":w<cr>", { desc = "Save file" })

map("t", "<esc>", "<C-\\><C-n>")

-- Search mappings
map("n", "<leader>sf", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>sg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
