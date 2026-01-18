return {
  {
    "tpope/vim-fugitive",
    lazy = false,
    config = function()
      -- Git remaps
      vim.keymap.set("n", "<leader>gs", ":G<CR>", { desc = "Git status" })
      vim.keymap.set("n", "<leader>ga", ":G add %<CR>", { desc = "Git add current file" })
      vim.keymap.set("n", "<leader>gA", ":G add .<CR>", { desc = "Git add all files" })
      vim.keymap.set("n", "<leader>gc", ":G commit --no-verify<CR>", { desc = "Git commit" })

      local function pre_commit_check()
        local cmd = "pre-commit"

        -- Run pre-commit hook on a split buffer bottom
        vim.cmd "belowright vsplit"
        vim.cmd("terminal " .. cmd)
      end

      -- Smart git commit with AI assistance
      local function smart_commit()
        -- Get git diff (staged first, then unstaged if no staged changes)
        local staged_diff = vim.fn.system "git diff --cached"
        local diff = staged_diff
        local diff_type = "staged"

        -- If no staged changes, get unstaged changes
        if vim.fn.trim(staged_diff) == "" then
          diff = vim.fn.system "git diff"
          diff_type = "unstaged"
        end

        -- If still no changes, check for untracked files
        if vim.fn.trim(diff) == "" then
          local status = vim.fn.system "git status --short"
          if vim.fn.trim(status) == "" then
            vim.notify("No changes to commit", vim.log.levels.WARN)
            return
          end
          diff = "No diff available. Untracked files:\n" .. status
          diff_type = "untracked"
        end

        -- Get recent commit messages for style reference
        local recent_commits = vim.fn.system "git log --oneline -5 2>/dev/null"

        -- Build the prompt
        local prompt = [[## Task: Create a Git Commit Message

Analyze the following git changes and propose a concise commit message.

### Requirements:
- Follow conventional commit format if the project uses it
- Be concise (ideally one line, max 72 characters for the subject)
- Focus on WHAT changed and WHY, not HOW
- Do NOT include any co-authoring lines
- Do NOT execute the commit, just propose the message

### Recent commit messages (for style reference):
```
]] .. recent_commits .. [[
```

### Changes (]] .. diff_type .. [[):
```diff
]] .. diff .. [[
```

Propose a commit message based on these changes.]]

        -- Open sidekick and send the prompt
        local sidekick_cli = require "sidekick.cli"
        sidekick_cli.toggle { focus = true }

        -- Wait for sidekick to open, then send the prompt
        vim.defer_fn(function()
          sidekick_cli.send { msg = prompt }
        end, 500)
      end

      -- Verify precommit hooks with pre-commit cmd
      vim.keymap.set("n", "<leader>gv", pre_commit_check, { desc = "Git verify" })
      -- Push to current branch
      vim.keymap.set("n", "<leader>gp", ":G push origin HEAD<CR>", { desc = "Git push" })
      vim.keymap.set("n", "<leader>gd", ":G diff<CR>", { desc = "Git diff" })
      vim.keymap.set("n", "<leader>gl", ":G log<CR>", { desc = "Git log" })
      vim.keymap.set("n", "<leader>gf", ":G fetch<CR>", { desc = "Git fetch" })
      vim.keymap.set("n", "<leader>gF", ":G pull", { desc = "Git pull" })
      vim.keymap.set("n", "<leader>gS", ":G stash<CR>", { desc = "Git stash" })

      -- Create and checkout branch
      vim.keymap.set("n", "<leader>gbn", ":G checkout -b ", { desc = "Git create and checkout branch" })
      vim.keymap.set("n", "<leader>gbc", ":G checkout ", { desc = "Git checkout branch" })
      vim.keymap.set("n", "<leader>gbl", ":G branch -l<CR>", { desc = "Git list branches" })
      vim.keymap.set("n", "<leader>gbb", ":G blame<CR>", { desc = "Git blame" })

      -- Smart commit with AI assistance
      vim.keymap.set("n", "<leader>gm", smart_commit, { desc = "Git smart commit (AI)" })

      -- User command for smart commit
      vim.api.nvim_create_user_command("SmartCommit", smart_commit, {
        desc = "Generate AI-assisted commit message",
      })
    end,
  },
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    config = function()
      vim.cmd "highlight default link gitblame SpecialComment"
      require("gitblame").setup { enabled = false }
    end,
  },
}
