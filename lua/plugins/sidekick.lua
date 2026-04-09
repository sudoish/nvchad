-- Sidekick.nvim - Universal AI CLI integration
-- Manages all AI tool terminals: claude, opencode, codex, gemini, etc.
-- Claude Code's MCP server runs headlessly via claudecode.nvim (plugins/claudecode.lua)

local DEFAULT_TOOL = "claude"

return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      default = DEFAULT_TOOL,
      tools = {
        -- Custom tools for resume/continue with flags
        ["claude-resume"] = {
          cmd = { "claude", "--resume" },
        },
        ["claude-continue"] = {
          cmd = { "claude", "--continue" },
        },
        ["opencode-resume"] = {
          cmd = { "opencode", "--resume" },
        },
        ["opencode-continue"] = {
          cmd = { "opencode", "--continue" },
        },
      },
    },
  },
  keys = {
    -- Toggle / focus the active AI tool
    {
      "<leader>ac",
      function()
        require("sidekick.cli").toggle { focus = true }
      end,
      desc = "Toggle AI",
      mode = { "n", "v" },
    },
    {
      "<leader>af",
      function()
        require("sidekick.cli").focus()
      end,
      desc = "Focus AI",
    },
    -- Resume / continue (uses the currently active tool, falls back to default)
    {
      "<leader>ar",
      function()
        local sessions = require("sidekick.status").cli()
        local tool = (sessions[1] and sessions[1].tool) or DEFAULT_TOOL
        require("sidekick.cli").toggle { name = tool .. "-resume", focus = true }
      end,
      desc = "Resume AI session",
    },
    {
      "<leader>aC",
      function()
        local sessions = require("sidekick.status").cli()
        local tool = (sessions[1] and sessions[1].tool) or DEFAULT_TOOL
        require("sidekick.cli").toggle { name = tool .. "-continue", focus = true }
      end,
      desc = "Continue AI session",
    },
    -- Switch between AI tools
    {
      "<leader>am",
      function()
        require("sidekick.cli").select { filter = { installed = true } }
      end,
      desc = "Select AI tool",
    },
    -- Send context to active tool
    {
      "<leader>ab",
      function()
        require("sidekick.cli").send { msg = "{file}" }
      end,
      desc = "Add current buffer",
    },
    {
      "<leader>as",
      function()
        require("sidekick.cli").send { msg = "{position}" }
      end,
      mode = "v",
      desc = "Send selection to AI",
    },
    -- Quick toggle
    {
      "<c-.>",
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "Sidekick Toggle",
      mode = { "n", "t", "i", "x" },
    },
    -- <C-h> navigation handled by mappings.lua (smart vim/tmux navigation)
    -- Copilot NES (Next Edit Suggestions)
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
