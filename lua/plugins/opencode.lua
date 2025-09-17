-- Create the Opencode command
vim.api.nvim_create_user_command("Opencode", function()
  -- Check if opencode is available
  if vim.fn.executable "opencode" == 0 then
    vim.notify("opencode command not found. Please install opencode CLI.", vim.log.levels.ERROR)
    return
  end

  -- Check if opencode buffer already exists
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name:match("opencode") or vim.bo[buf].filetype == "opencode" then
        -- Find window with opencode buffer
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == buf then
            vim.api.nvim_set_current_win(win)
            vim.cmd "startinsert"
            return
          end
        end
        -- Buffer exists but no window, create new window
        vim.cmd "leftabove vsplit"
        vim.api.nvim_win_set_buf(0, buf)
        vim.api.nvim_win_set_width(0, 80)
        vim.cmd "startinsert"
        return
      end
    end
  end

  -- Create a vertical split on the left
  vim.cmd "leftabove vsplit"
  
  -- Create a new buffer for the terminal
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  
  -- Get the new window
  local win = vim.api.nvim_get_current_win()
  
  -- Set buffer options for terminal
  vim.bo[buf].buftype = "terminal"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "opencode"
  
  -- Set window width
  vim.api.nvim_win_set_width(win, 80)
  
  -- Set buffer name
  vim.api.nvim_buf_set_name(buf, "opencode://terminal")
  
  -- Set up environment variables for better terminal experience
  local env = vim.fn.environ()
  env.TERM = "xterm-256color"
  env.COLORTERM = "truecolor"
  
  -- Start opencode in terminal mode with proper environment
  local job_id = vim.fn.termopen("opencode", {
    env = env,
    cwd = vim.fn.getcwd(),
    on_exit = function(_, exit_code)
      -- Close the buffer when opencode exits
      if vim.api.nvim_buf_is_valid(buf) then
        vim.schedule(function()
          vim.api.nvim_buf_delete(buf, { force = true })
        end)
      end
    end,
  })
  
  if job_id <= 0 then
    vim.notify("Failed to start opencode terminal", vim.log.levels.ERROR)
    vim.api.nvim_buf_delete(buf, { force = true })
    return
  end
  
  -- Set up terminal-specific keymaps
  vim.api.nvim_buf_set_keymap(buf, "t", "<C-\\><C-n>", "<C-\\><C-n>", { noremap = true })
  vim.api.nvim_buf_set_keymap(buf, "t", "<Esc>", "<C-\\><C-n>", { noremap = true })
  
  -- Enter insert mode to interact with opencode
  vim.cmd "startinsert"
  
end, {
  desc = "Open opencode in a left vertical split",
})



return {}