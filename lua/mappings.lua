require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- Smart navigation: Vim splits -> tmux panes -> tmux windows
local function navigate(direction)
  print("navigate called: " .. direction)

  local vim_dir = ({ h = "h", j = "j", k = "k", l = "l" })[direction]
  local tmux_pane_dir = ({ h = "L", j = "D", k = "U", l = "R" })[direction]
  local tmux_edge_check = ({ h = "left", j = "bottom", k = "top", l = "right" })[direction]
  local tmux_window_cmd = ({ h = "previous-window", l = "next-window" })[direction]

  -- Try Vim split navigation first
  local current_win = vim.fn.winnr()
  vim.cmd("wincmd " .. vim_dir)
  if vim.fn.winnr() ~= current_win then
    print("moved to vim split")
    return
  end

  -- Check if we're inside tmux
  print("TMUX env: " .. tostring(vim.env.TMUX))
  if not vim.env.TMUX then
    print("not in tmux, returning")
    return
  end

  -- Check if there's a tmux pane in that direction
  local at_edge = vim.fn.trim(vim.fn.system("tmux display-message -p '#{pane_at_" .. tmux_edge_check .. "}'"))
  print("at_edge=[" .. at_edge .. "] dir=" .. direction)
  if at_edge == "0" then
    vim.fn.system("tmux select-pane -" .. tmux_pane_dir)
  elseif tmux_window_cmd then
    vim.fn.jobstart({ "tmux", tmux_window_cmd }, { detach = true })
  end
end

map("n", "<C-h>", function() navigate("h") end, { desc = "Navigate left" })
map("n", "<C-l>", function() navigate("l") end, { desc = "Navigate right" })
map("n", "<C-k>", function() navigate("k") end, { desc = "Navigate up" })
map("n", "<C-j>", function() navigate("j") end, { desc = "Navigate down" })

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
