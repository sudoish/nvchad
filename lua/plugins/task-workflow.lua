-- Task Workflow Plugin
-- Provides keybinding to trigger the AI task workflow
return {
  "ai-tools/task-workflow",
  keys = {
    {
      "<leader>at",
      function()
        require("ai-tools.task-workflow").start()
      end,
      desc = "Start AI task workflow",
    },
  },
}
