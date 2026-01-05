-- Luacheck configuration for NvChad config
-- http://luacheck.readthedocs.io/en/stable/config.html

std = "lua54"
max_code_line_length = 120
max_string_line_length = 120

-- Ignore unused arguments that end with underscore
ignore = {
  "631", -- max_line_length (handled by stylua)
}

globals = {
  "vim", -- Neovim global
  "describe", -- For testing
  "it", -- For testing
  "before_each", -- For testing
  "after_each", -- For testing
}

files["lua/**/init.lua"] = {
  unused_args = false,
}

files["lua/plugins/*.lua"] = {
  globals = {
    "require", -- Lazy.nvim allows bare require
  },
}
