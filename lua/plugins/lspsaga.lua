return {
  {
    "nvimdev/lspsaga.nvim",
    event = "BufReadPre",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lspsaga").setup {}
      -- Toggle code actions
      local map = vim.keymap.set
      map("n", "<leader>rn", ":Lspsaga rename<cr>", { desc = "Lspsaga Rename" })
      map("n", "<leader>ca", ":Lspsaga code_action<cr>", { desc = "Lspsaga Code action" })
      map("n", "<leader>cd", ":Lspsaga peek_definition<cr>", { desc = "Peek definition" })
      map("n", "<S-k>", ":Lspsaga hover_doc<cr>", { desc = "Hover doc" })

      map("n", "gd", ":Lspsaga goto_definition<cr>", { desc = "Go to definition" })
      map("n", "<leader>co", ":Lspsaga outline<cr>", { desc = "Outline" })

      -- Show diagnostics in line with lspsaga
      map("n", "gl", ":Lspsaga show_line_diagnostics<cr>", { desc = "Show line diagnostics" })
      map("n", "[d", ":Lspsaga diagnostic_jump_prev<cr>", { desc = "Prev diagnostic" })
      map("n", "]d", ":Lspsaga diagnostic_jump_next<cr>", { desc = "Next diagnostic" })

      -- Rename file
      map("n", "<leader>rf", vim.lsp.buf.rename, { desc = "Rename file" })
    end,
  },
  -- Replace lspsaga with nvim-lsputils
  {
    "RishabhRD/nvim-lsputils",
    dependencies = {
      "RishabhRD/popfix",
    },
    config = function()
      local bufnr = vim.api.nvim_buf_get_number(0)

      vim.lsp.handlers["textDocument/codeAction"] = function(_, _, actions)
        require("lsputil.codeAction").code_action_handler(nil, actions, nil, nil, nil)
      end

      vim.lsp.handlers["textDocument/references"] = function(_, _, result)
        require("lsputil.locations").references_handler(nil, result, { bufnr = bufnr }, nil)
      end

      vim.lsp.handlers["textDocument/definition"] = function(_, method, result)
        require("lsputil.locations").definition_handler(nil, result, { bufnr = bufnr, method = method }, nil)
      end

      vim.lsp.handlers["textDocument/declaration"] = function(_, method, result)
        require("lsputil.locations").declaration_handler(nil, result, { bufnr = bufnr, method = method }, nil)
      end

      vim.lsp.handlers["textDocument/typeDefinition"] = function(_, method, result)
        require("lsputil.locations").typeDefinition_handler(nil, result, { bufnr = bufnr, method = method }, nil)
      end

      vim.lsp.handlers["textDocument/implementation"] = function(_, method, result)
        require("lsputil.locations").implementation_handler(nil, result, { bufnr = bufnr, method = method }, nil)
      end

      vim.lsp.handlers["textDocument/documentSymbol"] = function(_, _, result, _, bufn)
        require("lsputil.symbols").document_handler(nil, result, { bufnr = bufn }, nil)
      end

      vim.lsp.handlers["textDocument/symbol"] = function(_, _, result, _, bufn)
        require("lsputil.symbols").workspace_handler(nil, result, { bufnr = bufn }, nil)
      end
    end,
  },
}
