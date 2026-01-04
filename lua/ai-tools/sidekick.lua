-- Sidekick.nvim - Universal AI CLI integration
return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      mux = {
        backend = "tmux",
        enabled = true,
      },
    },
  },
  keys = {
    -- Toggle Claude (matching <leader>ac from claude-code)
    {
      "<leader>ac",
      function()
        require("sidekick.cli").toggle { name = "claude", focus = true }
      end,
      desc = "Toggle Claude",
      mode = { "n", "v" },
    },
    -- Focus Claude (matching <leader>af from claude-code)
    {
      "<leader>af",
      function()
        require("sidekick.cli").focus { name = "claude" }
      end,
      desc = "Focus Claude",
    },
    -- Resume Claude (matching <leader>ar from claude-code)
    {
      "<leader>ar",
      function()
        require("sidekick.cli").toggle { name = "claude", args = { "--resume" }, focus = true }
      end,
      desc = "Resume Claude",
    },
    -- Continue Claude (matching <leader>aC from claude-code)
    {
      "<leader>aC",
      function()
        require("sidekick.cli").toggle { name = "claude", args = { "--continue" }, focus = true }
      end,
      desc = "Continue Claude",
    },
    -- Select CLI tool (matching <leader>am from claude-code)
    {
      "<leader>am",
      function()
        require("sidekick.cli").select { filter = { installed = true } }
      end,
      desc = "Select AI tool",
    },
    -- Add current buffer/file (matching <leader>ab from claude-code)
    {
      "<leader>ab",
      function()
        require("sidekick.cli").send { msg = "{file}" }
      end,
      desc = "Add current buffer",
    },
    -- Send selection (matching <leader>as from claude-code visual mode)
    {
      "<leader>as",
      function()
        require("sidekick.cli").send { selection = true }
      end,
      mode = "v",
      desc = "Send to Claude",
    },
    -- Accept diff (matching <leader>ay from claude-code)
    {
      "<leader>ay",
      function()
        require("sidekick.ui").accept()
      end,
      desc = "Accept diff",
    },
    -- Deny diff (matching <leader>ad from claude-code)
    {
      "<leader>ad",
      function()
        require("sidekick.ui").reject()
      end,
      desc = "Deny diff",
    },
    -- Quick toggle with Ctrl+. (bonus from original sidekick config)
    {
      "<c-.>",
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "Sidekick Toggle",
      mode = { "n", "t", "i", "x" },
    },
    -- Navigate left from chat to editor with Ctrl+h
    {
      "<c-h>",
      "<cmd>wincmd h<cr>",
      desc = "Navigate to left window",
      mode = { "n", "t" },
    },
    -- Jump/apply next edit suggestion
    {
      "<tab>",
      function()
        if not require("sidekick").nes_jump_or_apply() then
          return "<Tab>"
        end
      end,
      expr = true,
      desc = "Goto/Apply Next Edit Suggestion",
    },
  },
}
