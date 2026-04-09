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
    vim.keymap.set(
      "v",
      "<leader>pc",
      ":<C-u>lua require('github-pr-reviewer').add_pending_comment_with_selection()<CR>",
      { desc = "PR pending comment (selection)" }
    )
    vim.keymap.set("n", "<leader>pi", "<cmd>PRInfo<cr>", { desc = "PR info" })
    vim.keymap.set("n", "<leader>pq", "<cmd>PRReviewCleanup<cr>", { desc = "PR quit review" })
    vim.keymap.set("v", "<leader>ps", "<cmd>PRSuggestChange<cr>", { desc = "PR suggest change" })

    -- =====================================================
    -- AI Review Helper: ask AI about selected code in review context
    -- =====================================================
    local review_cache = { pr_number = nil, title = nil, body = nil, git_root = nil }

    local function get_pr_metadata()
      local pr_number = vim.g.pr_review_number
      if not pr_number then
        return { number = "?", title = "Unknown PR", body = "" }
      end
      -- Return cache if still for the same PR
      if review_cache.pr_number == pr_number and review_cache.title then
        return review_cache
      end
      -- Fetch title and body from gh CLI (once per PR)
      local result = vim.fn.system(
        string.format("gh pr view %d --json title,body --jq '[.title, .body] | @tsv'", pr_number)
      )
      if vim.v.shell_error == 0 then
        local title, body = result:match("^(.-)\t(.*)$")
        review_cache.pr_number = pr_number
        review_cache.title = title or "Unknown PR"
        review_cache.body = (body or ""):gsub("%s+$", "")
      else
        review_cache.pr_number = pr_number
        review_cache.title = "Unknown PR"
        review_cache.body = ""
      end
      return review_cache
    end

    local function get_review_filepath()
      local bufname = vim.api.nvim_buf_get_name(0)
      if not review_cache.git_root then
        local root = vim.fn.trim(vim.fn.system("git rev-parse --show-toplevel"))
        if vim.v.shell_error == 0 then
          review_cache.git_root = root
        else
          return bufname
        end
      end
      return bufname:sub(#review_cache.git_root + 2)
    end

    local function get_visual_selection()
      local start_line = vim.fn.getpos("'<")[2]
      local end_line = vim.fn.getpos("'>")[2]
      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      return {
        text = table.concat(lines, "\n"),
        start_line = start_line,
        end_line = end_line,
      }
    end

    local function ai_review_ask()
      if not vim.g.pr_review_number then
        vim.notify("Not in a PR review session", vim.log.levels.WARN)
        return
      end

      local selection = get_visual_selection()
      if selection.text == "" then
        vim.notify("No text selected", vim.log.levels.WARN)
        return
      end

      local filepath = get_review_filepath()
      local metadata = get_pr_metadata()
      local filetype = vim.bo.filetype

      local prompt = string.format(
        "## PR Review Context\nPR #%s: %s\n\nFile: `%s` (lines %d-%d)\n\n### Selected code:\n```%s\n%s\n```\n\nI'm reviewing this PR. Help me understand this change. What does it do, and is there anything concerning about it?",
        metadata.number,
        metadata.title,
        filepath,
        selection.start_line,
        selection.end_line,
        filetype,
        selection.text
      )

      local sidekick_cli = require("sidekick.cli")
      sidekick_cli.toggle({ focus = true })
      vim.defer_fn(function()
        sidekick_cli.send({ msg = prompt })
      end, 500)
    end

    -- Clear cache when review ends (cleanup resets vim.g.pr_review_number,
    -- so the next get_pr_metadata() call will re-fetch automatically.
    -- We still clear git_root since the repo may change between reviews.)
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("PRReviewCacheClear", { clear = true }),
      callback = function()
        if not vim.g.pr_review_number and review_cache.pr_number then
          review_cache = { pr_number = nil, title = nil, body = nil, git_root = nil }
        end
      end,
    })

    vim.keymap.set("v", "<leader>pa", ai_review_ask, { desc = "PR ask AI about selection" })
  end,
}
