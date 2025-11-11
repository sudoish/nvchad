local util = require "conform.util"

local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    python = { "ruff_format" },
  },

  formatters = {
    ruff_format = {
      command = util.find_executable({
        ".venv/bin/ruff",
        "ruff",
      }, "ruff"),
      args = { "format", "--stdin-filename", "$FILENAME", "-" },
      cwd = util.root_file { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
      stdin = true,
    },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 200,
    lsp_fallback = true,
  },
}

return options
