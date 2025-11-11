require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "pyright", "ts_ls", "gopls", "ruff" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
