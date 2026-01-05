-- Amp.nvim - Sourcegraph AI assistant
return {
  "sourcegraph/amp.nvim",
  branch = "main",
  lazy = false,
  opts = { auto_start = true, log_level = "info" },
  keys = {
    { "<leader>aS", "<cmd>AmpStatus<cr>", desc = "Amp status" },
    {
      "<leader>as",
      function()
        local selection = require "amp.selection"
        selection.update_and_broadcast()
        require("amp.message").send_to_prompt "{selection}"
      end,
      mode = "v",
      desc = "Send selection to Amp",
    },
    {
      "<leader>aa",
      function()
        vim.notify("Amp: Accept diff (handled by Amp CLI)", vim.log.levels.INFO)
      end,
      desc = "Accept diff (Amp CLI)",
    },
    {
      "<leader>ad",
      function()
        vim.notify("Amp: Dismiss diff (handled by Amp CLI)", vim.log.levels.INFO)
      end,
      desc = "Dismiss diff (Amp CLI)",
    },
  },
}
