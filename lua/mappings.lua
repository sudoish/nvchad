require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<Leader>q", ":bd<cr>", { desc = "Close buffer" })

local function save_buffer()
  -- if file is .str, .strdl, or .strudel execute strudel command
  local filetypes = { "str", "strdl", "strudel" }
  if vim.tbl_contains(filetypes, vim.bo.filetype) then
    vim.cmd "StrudelExecute"
  end
  -- save file
  vim.cmd "w"
end

map("n", "<Leader>fs", save_buffer, { desc = "Save file" })

map("t", "<esc>", "<C-\\><C-n>")

-- Search mappings
map("n", "<leader>sf", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>sg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
