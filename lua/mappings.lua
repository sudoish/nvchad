require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- Smart navigation: Vim splits -> tmux panes -> tmux windows
local function navigate(direction)
  local vim_dir = ({ h = "h", j = "j", k = "k", l = "l" })[direction]
  local tmux_pane_dir = ({ h = "L", j = "D", k = "U", l = "R" })[direction]
  local tmux_edge_check = ({ h = "left", j = "bottom", k = "top", l = "right" })[direction]
  local tmux_window_cmd = ({ h = "previous-window", l = "next-window" })[direction]

  -- Try Vim split navigation first
  local current_win = vim.fn.winnr()
  vim.cmd("wincmd " .. vim_dir)
  if vim.fn.winnr() ~= current_win then
    return
  end

  -- Check if we're inside tmux
  if not vim.env.TMUX then
    return
  end

  -- Check if there's a tmux pane in that direction
  local at_edge = vim.fn.trim(vim.fn.system("tmux display-message -p '#{pane_at_" .. tmux_edge_check .. "}'"))
  if at_edge == "0" then
    vim.fn.system("tmux select-pane -" .. tmux_pane_dir)
  elseif tmux_window_cmd then
    -- Handle tmux window navigation with wrap-around
    if direction == "h" then
      -- For left navigation, go to previous window with wrap-around
      vim.fn.system "tmux select-window -t -1"
    elseif direction == "l" then
      -- For right navigation, go to next window with wrap-around
      vim.fn.system "tmux select-window -t +1"
    end
  end
end

map("n", "<C-h>", function()
  navigate "h"
end, { desc = "Navigate left" })
map("n", "<C-l>", function()
  navigate "l"
end, { desc = "Navigate right" })
map("n", "<C-k>", function()
  navigate "k"
end, { desc = "Navigate up" })
map("n", "<C-j>", function()
  navigate "j"
end, { desc = "Navigate down" })

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<Leader>q", function()
  -- Check if we're in a sidekick/terminal buffer
  if vim.bo.buftype == "terminal" then
    local ok, sidekick = pcall(require, "sidekick.cli")
    if ok then
      sidekick.toggle()
      return
    end
  end

  local listed_bufs = vim.fn.getbufinfo { buflisted = 1 }
  if #listed_bufs <= 1 then
    vim.cmd "quit"
  else
    vim.cmd "bd"
  end
end, { desc = "Close buffer or quit" })

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
map("t", "<S-Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Terminal mode navigation (for Claude Code pane, etc.)
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Navigate left from terminal" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Navigate down from terminal" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Navigate up from terminal" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Navigate right from terminal" })

-- Search mappings
map("n", "<leader>sf", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>sg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })

-- Terminal toggle
map("n", "<leader>;", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Toggle floating terminal" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
