-- claudecode.nvim: headless MCP server only
-- Terminal management is handled by sidekick.nvim
-- This plugin provides: selection tracking, diff accept/reject, diagnostics, file operations
return {
  "coder/claudecode.nvim",
  lazy = false,
  dependencies = { "folke/snacks.nvim" },
  opts = {
    port_range = { min = 10000, max = 65535 },
    auto_start = true,
    log_level = "info",
    track_selection = true,
    visual_demotion_delay_ms = 50,
    terminal = {
      provider = "none", -- sidekick.nvim handles the terminal
    },
    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = true,
      open_in_current_tab = true,
      show_diff_stats = true,
      keep_terminal_focus = false,
    },
  },
  config = function(_, opts)
    require("claudecode").setup(opts)

    -- Export MCP server env vars to the Neovim process so that
    -- any child terminal (sidekick, etc.) can connect Claude CLI to the MCP server.
    local function export_mcp_env()
      local ok, cc = pcall(require, "claudecode")
      if ok and cc.state and cc.state.port then
        vim.env.CLAUDE_CODE_SSE_PORT = tostring(cc.state.port)
        vim.env.ENABLE_IDE_INTEGRATION = "true"
        return true
      end
      return false
    end

    -- Server starts asynchronously — retry until the port is available
    local attempts = 0
    local function poll_mcp_env()
      attempts = attempts + 1
      if not export_mcp_env() and attempts < 10 then
        vim.defer_fn(poll_mcp_env, 500)
      end
    end
    vim.defer_fn(poll_mcp_env, 500)

    -- MCP-dependent keybindings (diff accept/reject works via MCP, no terminal needed)
    vim.keymap.set("n", "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
    vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })
  end,
}
