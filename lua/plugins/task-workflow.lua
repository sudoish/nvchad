-- Task Workflow Keybinding
-- Triggers the AI task workflow: input → worktree → tmux → AI chat

vim.keymap.set("n", "<leader>at", function()
  require("ai-tools.task-workflow").start()
end, { desc = "Start AI task workflow" })

return {}
