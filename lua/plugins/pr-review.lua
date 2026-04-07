-- ~/.config/nvim/lua/plugins/pr-review.lua
-- PR Review workflow: github-pr-reviewer.nvim + custom layer

return {
  "otavioschwanck/github-pr-reviewer.nvim",
  cmd = { "PR", "PRReview", "PRListReviewRequests" },
  event = "BufReadPre",
  config = function()
    require("github-pr-reviewer").setup {
      picker = "telescope",
      show_comments = true,
      show_inline_diff = true,
      show_floats = true,
      next_file_key = "<C-n>",
      prev_file_key = "<C-p>",
      review_buffer = {
        position = "left",
        width = 50,
        group_by_directory = true,
        sort_by = "status",
      },
    }

    -- Global keybindings (always available)
    vim.keymap.set("n", "<leader>pr", "<cmd>PR<cr>", { desc = "PR Review menu" })
    vim.keymap.set("n", "<leader>pb", "<cmd>PRReviewBuffer<cr>", { desc = "PR file panel" })
    vim.keymap.set("n", "<leader>pc", "<cmd>PRPendingComment<cr>", { desc = "PR pending comment" })
    vim.keymap.set("v", "<leader>pc", function()
      require("github-pr-reviewer").add_pending_comment_with_selection()
    end, { desc = "PR pending comment (selection)" })
    vim.keymap.set("n", "<leader>pi", "<cmd>PRInfo<cr>", { desc = "PR info" })
    vim.keymap.set("n", "<leader>pq", "<cmd>PRReviewCleanup<cr>", { desc = "PR quit review" })
    vim.keymap.set("v", "<leader>ps", "<cmd>PRSuggestChange<cr>", { desc = "PR suggest change" })
  end,
}
