return {
  "sudoish/vimhood.nvim",
  event = "VimEnter",
  branch = "fix/bracketed-paste-multiline-prompt",
  config = function()
    require("vimhood").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  end,
}
