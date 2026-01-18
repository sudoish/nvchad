-- Task Workflow Keybinding
-- Triggers the AI task workflow: input → worktree → tmux → AI chat

vim.keymap.set("n", "<leader>at", function()
  require("ai-tools.task-workflow").start()
end, { desc = "Start AI task workflow" })

-- Setup Claude Code attention hooks command
vim.api.nvim_create_user_command("TaskWorkflowSetupHooks", function()
  local setup = require "ai-tools.task-workflow.setup-hooks"
  local result = setup.setup()
  if result.success then
    vim.notify("Claude Code hooks installed successfully!", vim.log.levels.INFO)
  else
    vim.notify("Failed to install hooks: " .. result.error, vim.log.levels.ERROR)
  end
end, { desc = "Setup Claude Code attention hooks" })

-- Test attention styling command
vim.api.nvim_create_user_command("TaskWorkflowAttentionTest", function()
  local tmux = require "utils.tmux"
  local config = require "ai-tools.task-workflow.config"
  local cfg = config.notifications.claude_attention

  local result = tmux.set_attention_style {
    icon = cfg.tmux_style.icon,
    fg_color = cfg.tmux_style.fg_color,
    bg_color = cfg.tmux_style.bg_color,
    theme_bg = cfg.tmux_style.theme_bg,
    theme_fg = cfg.tmux_style.theme_fg,
    theme_accent = cfg.tmux_style.theme_accent,
  }

  if result.success then
    vim.notify("Attention styling applied!", vim.log.levels.INFO)
  else
    vim.notify("Failed: " .. result.error, vim.log.levels.ERROR)
  end
end, { desc = "Test attention styling on current window" })

-- Clear attention styling command
vim.api.nvim_create_user_command("TaskWorkflowAttentionClear", function()
  local tmux = require "utils.tmux"

  local result = tmux.clear_attention_style()

  if result.success then
    vim.notify("Attention styling cleared!", vim.log.levels.INFO)
  else
    vim.notify("Failed: " .. result.error, vim.log.levels.ERROR)
  end
end, { desc = "Clear attention styling from current window" })

return {}
