-- Sidekick.nvim - Universal AI CLI integration

--------------------------------------------------------------------------------
-- CONFIGURATION
--------------------------------------------------------------------------------

-- Default AI tool to use with Sidekick
-- Change this variable to switch between different AI tools (e.g., "droid", "claude", "gpt", etc.)
local DEFAULT_TOOL = "claude"

--------------------------------------------------------------------------------

return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      mux = {
        backend = "tmux",
        enabled = true,
      },
      tools = {
        [DEFAULT_TOOL] = {
          cmd = { DEFAULT_TOOL },
        },
        -- Separate tools for resume and continue with flags built into cmd
        [DEFAULT_TOOL .. "-resume"] = {
          cmd = { DEFAULT_TOOL, "--resume" },
        },
        [DEFAULT_TOOL .. "-continue"] = {
          cmd = { DEFAULT_TOOL, "--continue" },
        },
      },
    },
  },
  keys = {
    -- Toggle AI tool
    {
      "<leader>ac",
      function()
        require("sidekick.cli").toggle { name = DEFAULT_TOOL, focus = true }
      end,
      desc = "Toggle " .. (DEFAULT_TOOL:gsub("^%l", string.upper)),
      mode = { "n", "v" },
    },
    -- Focus AI tool
    {
      "<leader>af",
      function()
        require("sidekick.cli").focus { name = DEFAULT_TOOL }
      end,
      desc = "Focus " .. (DEFAULT_TOOL:gsub("^%l", string.upper)),
    },
    -- Resume AI tool (uses separate tool with --resume flag)
    {
      "<leader>ar",
      function()
        require("sidekick.cli").toggle { name = DEFAULT_TOOL .. "-resume", focus = true }
      end,
      desc = "Resume " .. (DEFAULT_TOOL:gsub("^%l", string.upper)),
    },
    -- Continue AI tool (uses separate tool with --continue flag)
    {
      "<leader>aC",
      function()
        require("sidekick.cli").toggle { name = DEFAULT_TOOL .. "-continue", focus = true }
      end,
      desc = "Continue " .. (DEFAULT_TOOL:gsub("^%l", string.upper)),
    },
    -- Select AI tool
    {
      "<leader>am",
      function()
        require("sidekick.cli").select { filter = { installed = true } }
      end,
      desc = "Select AI tool",
    },
    -- Add current buffer/file
    {
      "<leader>ab",
      function()
        require("sidekick.cli").send { msg = "{file}" }
      end,
      desc = "Add current buffer",
    },
    -- Send selection
    {
      "<leader>as",
      function()
        require("sidekick.cli").send { selection = true }
      end,
      mode = "v",
      desc = "Send to " .. (DEFAULT_TOOL:gsub("^%l", string.upper)),
    },
    -- Accept diff
    {
      "<leader>ay",
      function()
        require("sidekick.ui").accept()
      end,
      desc = "Accept diff",
    },
    -- Deny diff
    {
      "<leader>ad",
      function()
        require("sidekick.ui").reject()
      end,
      desc = "Deny diff",
    },
    -- Quick toggle with Ctrl+.
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
