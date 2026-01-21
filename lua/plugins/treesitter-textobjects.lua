return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "BufRead",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "vim",
          "lua",
          "vimdoc",
          "html",
          "css",
          "javascript",
          "typescript",
          "tsx",
          "python",
          "go",
          "rust",
          "elixir",
          "json",
          "yaml",
          "markdown",
          "bash",
        },
        textobjects = {
          select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
              -- Function text objects
              ["af"] = { query = "@function.outer", desc = "Select around function" },
              ["if"] = { query = "@function.inner", desc = "Select inside function" },

              -- Class text objects
              ["ac"] = { query = "@class.outer", desc = "Select around class" },
              ["ic"] = { query = "@class.inner", desc = "Select inside class" },

              -- Parameter/argument text objects
              ["aa"] = { query = "@parameter.outer", desc = "Select around argument" },
              ["ia"] = { query = "@parameter.inner", desc = "Select inside argument" },

              -- Conditional text objects
              ["ai"] = { query = "@conditional.outer", desc = "Select around conditional" },
              ["ii"] = { query = "@conditional.inner", desc = "Select inside conditional" },

              -- Loop text objects
              ["al"] = { query = "@loop.outer", desc = "Select around loop" },
              ["il"] = { query = "@loop.inner", desc = "Select inside loop" },

              -- Block text objects
              ["ab"] = { query = "@block.outer", desc = "Select around block" },
              ["ib"] = { query = "@block.inner", desc = "Select inside block" },

              -- Comment text objects
              ["aC"] = { query = "@comment.outer", desc = "Select around comment" },
              ["iC"] = { query = "@comment.inner", desc = "Select inside comment" },

              -- Assignment text objects
              ["a="] = { query = "@assignment.outer", desc = "Select around assignment" },
              ["i="] = { query = "@assignment.inner", desc = "Select inside assignment" },
              ["l="] = { query = "@assignment.lhs", desc = "Select left side of assignment" },
              ["r="] = { query = "@assignment.rhs", desc = "Select right side of assignment" },
            },
            selection_modes = {
              ["@parameter.outer"] = "v",
              ["@function.outer"] = "V",
              ["@class.outer"] = "V",
            },
            include_surrounding_whitespace = true,
          },
          move = {
            enable = true,
            set_jumps = true, -- Add to jumplist
            goto_next_start = {
              ["]f"] = { query = "@function.outer", desc = "Next function start" },
              ["]c"] = { query = "@class.outer", desc = "Next class start" },
              ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
              ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
              ["]l"] = { query = "@loop.outer", desc = "Next loop start" },
            },
            goto_next_end = {
              ["]F"] = { query = "@function.outer", desc = "Next function end" },
              ["]C"] = { query = "@class.outer", desc = "Next class end" },
              ["]A"] = { query = "@parameter.inner", desc = "Next argument end" },
              ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
              ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
            },
            goto_previous_start = {
              ["[f"] = { query = "@function.outer", desc = "Previous function start" },
              ["[c"] = { query = "@class.outer", desc = "Previous class start" },
              ["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
              ["[i"] = { query = "@conditional.outer", desc = "Previous conditional start" },
              ["[l"] = { query = "@loop.outer", desc = "Previous loop start" },
            },
            goto_previous_end = {
              ["[F"] = { query = "@function.outer", desc = "Previous function end" },
              ["[C"] = { query = "@class.outer", desc = "Previous class end" },
              ["[A"] = { query = "@parameter.inner", desc = "Previous argument end" },
              ["[I"] = { query = "@conditional.outer", desc = "Previous conditional end" },
              ["[L"] = { query = "@loop.outer", desc = "Previous loop end" },
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>xa"] = { query = "@parameter.inner", desc = "Swap with next argument" },
              ["<leader>xf"] = { query = "@function.outer", desc = "Swap with next function" },
            },
            swap_previous = {
              ["<leader>xA"] = { query = "@parameter.inner", desc = "Swap with previous argument" },
              ["<leader>xF"] = { query = "@function.outer", desc = "Swap with previous function" },
            },
          },
        },
      }

      -- Repeat movement with ; and ,
      local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

      -- Make builtin f, F, t, T also repeatable with ; and ,
      vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
    end,
  },
}
