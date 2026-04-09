return {
  -- Extend NvChad's treesitter with additional parsers (main branch for 0.12)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate | TSInstallAll",
    opts = {
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
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "BufRead",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local select = require "nvim-treesitter-textobjects.select"
      local move = require "nvim-treesitter-textobjects.move"
      local swap = require "nvim-treesitter-textobjects.swap"

      require("nvim-treesitter-textobjects").setup {
        select = {
          lookahead = true,
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "V",
          },
          include_surrounding_whitespace = true,
        },
        move = {
          set_jumps = true,
        },
      }

      -- Select keymaps
      local select_maps = {
        ["af"] = { "@function.outer", "Select around function" },
        ["if"] = { "@function.inner", "Select inside function" },
        ["ac"] = { "@class.outer", "Select around class" },
        ["ic"] = { "@class.inner", "Select inside class" },
        ["aa"] = { "@parameter.outer", "Select around argument" },
        ["ia"] = { "@parameter.inner", "Select inside argument" },
        ["ai"] = { "@conditional.outer", "Select around conditional" },
        ["ii"] = { "@conditional.inner", "Select inside conditional" },
        ["al"] = { "@loop.outer", "Select around loop" },
        ["il"] = { "@loop.inner", "Select inside loop" },
        ["ab"] = { "@block.outer", "Select around block" },
        ["ib"] = { "@block.inner", "Select inside block" },
        ["aC"] = { "@comment.outer", "Select around comment" },
        ["iC"] = { "@comment.inner", "Select inside comment" },
        ["a="] = { "@assignment.outer", "Select around assignment" },
        ["i="] = { "@assignment.inner", "Select inside assignment" },
        ["l="] = { "@assignment.lhs", "Select left side of assignment" },
        ["r="] = { "@assignment.rhs", "Select right side of assignment" },
      }

      for key, val in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(val[1], "textobjects")
        end, { desc = val[2] })
      end

      -- Move keymaps
      local move_maps = {
        goto_next_start = {
          ["]f"] = { "@function.outer", "Next function start" },
          ["]c"] = { "@class.outer", "Next class start" },
          ["]a"] = { "@parameter.inner", "Next argument start" },
          ["]i"] = { "@conditional.outer", "Next conditional start" },
          ["]l"] = { "@loop.outer", "Next loop start" },
        },
        goto_next_end = {
          ["]F"] = { "@function.outer", "Next function end" },
          ["]C"] = { "@class.outer", "Next class end" },
          ["]A"] = { "@parameter.inner", "Next argument end" },
          ["]I"] = { "@conditional.outer", "Next conditional end" },
          ["]L"] = { "@loop.outer", "Next loop end" },
        },
        goto_previous_start = {
          ["[f"] = { "@function.outer", "Previous function start" },
          ["[c"] = { "@class.outer", "Previous class start" },
          ["[a"] = { "@parameter.inner", "Previous argument start" },
          ["[i"] = { "@conditional.outer", "Previous conditional start" },
          ["[l"] = { "@loop.outer", "Previous loop start" },
        },
        goto_previous_end = {
          ["[F"] = { "@function.outer", "Previous function end" },
          ["[C"] = { "@class.outer", "Previous class end" },
          ["[A"] = { "@parameter.inner", "Previous argument end" },
          ["[I"] = { "@conditional.outer", "Previous conditional end" },
          ["[L"] = { "@loop.outer", "Previous loop end" },
        },
      }

      for fn_name, mappings in pairs(move_maps) do
        for key, val in pairs(mappings) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            move[fn_name](val[1], "textobjects")
          end, { desc = val[2] })
        end
      end

      -- Swap keymaps
      vim.keymap.set("n", "<leader>xa", function()
        swap.swap_next "@parameter.inner"
      end, { desc = "Swap with next argument" })
      vim.keymap.set("n", "<leader>xf", function()
        swap.swap_next "@function.outer"
      end, { desc = "Swap with next function" })
      vim.keymap.set("n", "<leader>xA", function()
        swap.swap_previous "@parameter.inner"
      end, { desc = "Swap with previous argument" })
      vim.keymap.set("n", "<leader>xF", function()
        swap.swap_previous "@function.outer"
      end, { desc = "Swap with previous function" })

      -- Repeat movement with ; and ,
      local ts_repeat_move = require "nvim-treesitter-textobjects.repeatable_move"
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
