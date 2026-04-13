-- Sidekick.nvim - Universal AI CLI integration
-- Manages all AI tool terminals: claude, opencode, codex, gemini, etc.
-- Claude Code's MCP server runs headlessly via claudecode.nvim (plugins/claudecode.lua)

local DEFAULT_TOOL = "claude"

-- Build the "review branch" prompt by reading prompts/review-branch.md
-- and substituting {branch}/{base} placeholders. Called lazily when the
-- prompt is invoked so the user is asked for branch names each time.
local function review_branch_prompt()
  local current = vim.fn.systemlist("git branch --show-current")[1] or ""
  local branch = vim.fn.input("Branch to review: ", current)
  if branch == "" then
    return nil
  end
  local base = vim.fn.input("Base branch: ", "main")
  if base == "" then
    return nil
  end

  local path = vim.fn.stdpath("config") .. "/prompts/review-branch.md"
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or not lines or #lines == 0 then
    vim.notify("Could not read prompt template: " .. path, vim.log.levels.ERROR)
    return nil
  end

  local body = table.concat(lines, "\n")
  body = body:gsub("{branch}", branch):gsub("{base}", base)
  return body
end

return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      default = DEFAULT_TOOL,
      win = {
        split = {
          width = 0.35, -- 35% of screen width for right-split layout
        },
      },
      prompts = {
        -- Detailed branch code-review prompt (see prompts/review-branch.md).
        -- Invoked via <leader>aR; prompts for branch + base interactively.
        review_branch = review_branch_prompt,
      },
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
    -- Code review a branch (prompts for branch + base, sends detailed review request)
    {
      "<leader>aR",
      function()
        require("sidekick.cli").send {
          prompt = "review_branch",
          submit = true,
          focus = true,
        }
      end,
      desc = "Review branch (AI)",
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
