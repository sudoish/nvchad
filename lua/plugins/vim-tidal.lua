return {
  "tidalcycles/vim-tidal",
  lazy = false,
  ft = "tidal",
  config = function()
    vim.g.maplocalleader = ","
    vim.g.tidal_ghci = "ghci"
    vim.g.tidal_target = "terminal"
    vim.g.tidal_flash_duration = 150

    -- Configure to open in vertical split on the right
    vim.g.tidal_split = "vertical"
    vim.opt.splitright = true

    -- Set up keybindings for tidal files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "tidal",
      callback = function()
        local opts = { buffer = true, silent = true }
        -- Start Tidal (opens terminal) and send paragraph
        vim.keymap.set(
          "n",
          "<localleader>s",
          "<Plug>TidalParagraphSend",
          vim.tbl_extend("force", opts, { desc = "Send paragraph to Tidal (starts if needed)" })
        )
        -- Send line
        vim.keymap.set(
          "n",
          "<localleader>l",
          "<Plug>TidalLineSend",
          vim.tbl_extend("force", opts, { desc = "Send line to Tidal" })
        )
        -- Send visual selection
        vim.keymap.set(
          "v",
          "<localleader>s",
          "<Plug>TidalRegionSend",
          vim.tbl_extend("force", opts, { desc = "Send selection to Tidal" })
        )
        -- Hush all streams
        vim.keymap.set(
          "n",
          "<localleader>h",
          ":TidalHush<CR>",
          vim.tbl_extend("force", opts, { desc = "Hush all Tidal streams" })
        )
        -- Play specific stream (d1-d9)
        for i = 1, 9 do
          vim.keymap.set(
            "n",
            "<localleader>" .. i,
            ":TidalPlay " .. i .. "<CR>",
            vim.tbl_extend("force", opts, { desc = "Play d" .. i })
          )
        end

        local function silence_current_stream()
          -- gets the current line content, if it starts with d, silence the following number
          -- for example, if line starts with "d1", execute the command ":TidalSilence d1"
          -- if it starts with anything else that does not match d<number>, do nothing
          local line = vim.api.nvim_get_current_line()
          if line:match "^d" then
            local stream = line:match "^d(%d+)"
            vim.api.nvim_command(":TidalSilence " .. stream)
          end
        end
        -- Silence current stream with local leader + d
        vim.keymap.set(
          "n",
          "<localleader>d",
          silence_current_stream,
          vim.tbl_extend("force", opts, { desc = "Silence current stream" })
        )
      end,
    })
  end,
}
