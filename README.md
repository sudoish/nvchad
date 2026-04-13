# NvChad AI-Enhanced Configuration

A feature-rich Neovim configuration based on [NvChad v3.0](https://github.com/NvChad/NvChad) with deep AI tooling integration, optimized for modern development workflows.

## ✨ Key Features

- **AI-Powered Development**: Unified AI tooling with support for Claude Code, Sidekick, Amp, Supermaven, GitHub Copilot, and Factory Droid
- **Task Workflow System**: Automated workflow that orchestrates git worktrees, tmux sessions, and AI chat agents
- **Visual Transparency**: Beautiful TokyNight theme with full transparency support across all UI elements
- **Modern Tools**: Oil.nvim file browser, LazyGit, Telescope fuzzy finder, and LSP integration with Blink completion
- **Music Production**: Live coding support for TidalCycles and Strudel
- **Testing**: Integrated Neotest for running tests directly in Neovim
- **Database**: Vim-dadbod for database management

## 🚀 Quick Start

### Prerequisites

- Neovim 0.9+
- Git
- tmux for the AI task workflow (`<leader>at` requires running inside tmux)

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/nvchad ~/.config/nvim
cd ~/.config/nvim

# Remove the .git folder to use it as your personal config
rm -rf .git

# Open Neovim (plugins will auto-install)
nvim
```

### First Launch

Neovim will automatically:
1. Download and install lazy.nvim plugin manager
2. Install all configured plugins
3. Generate color themes based on your configuration

## 🎯 Usage

### AI Tools

Start the AI task workflow with `<leader>at` to:
1. Input your task description
2. Create a git worktree
3. Open a new tmux window
4. Launch the configured AI tool in the new Neovim instance

The current AI integrations are configured primarily in `lua/plugins/`:
- `claudecode.lua` - Claude Code MCP integration
- `sidekick.lua` - AI CLI terminal management and prompt sending
- `opencode.lua` - Opencode integration and keymaps
- `task-workflow.lua` - task workflow keybinding entrypoint
- `pr-review.lua` - PR review integration with optional AI assistance

The workflow orchestration logic lives in `lua/ai-tools/task-workflow/` and the branch review prompt lives in `prompts/review-branch.md`.

### Key Mappings

Check available keybindings in `lua/mappings.lua`. Common mappings:
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Buffers
- `<leader>at` - Start AI task workflow
- `<leader>th` - Toggle theme

## ⚙️ Configuration

### Main Configuration Files

- `lua/chadrc.lua` - Theme, UI, transparency settings
- `lua/options.lua` - Neovim options
- `lua/mappings.lua` - Key mappings
- `lua/autocmds.lua` - Autocommands

### Plugin Structure

```
lua/
├── configs/          # Plugin-specific configurations
├── plugins/          # Plugin specifications
│   ├── init.lua      # Core plugins (conform, lspconfig, blink)
│   └── *.lua         # Feature plugins, including AI integrations
└── ai-tools/         # Workflow helpers used by AI features
    ├── task-input.lua
    └── task-workflow/
        ├── config.lua
        └── init.lua
```

### Customization

To customize AI behavior, edit the relevant plugin specs under `lua/plugins/` and the workflow files under `lua/ai-tools/task-workflow/`.

Common entry points:
- `lua/plugins/sidekick.lua` for AI terminal behavior and prompts
- `lua/plugins/claudecode.lua` for Claude Code MCP settings
- `lua/plugins/opencode.lua` for Opencode behavior and mappings
- `lua/ai-tools/task-workflow/config.lua` for workflow defaults

## 🛠️ Development

### Code Quality Tools

```bash
# Format code (2 spaces, 120 cols)
stylua .

# Lint Lua code
luacheck .

# Validate Neovim config
nvim --headless -u init.lua -c "lua vim.cmd('quit')"

# Run AI workflow specs
~/.luarocks/bin/busted tests/opencode_spec.lua specs/task_workflow_spec.lua specs/task_workflow_config_spec.lua

# Run pre-commit hooks
pre-commit run --all-files
```

### Adding Plugins

1. Create a new file in `lua/plugins/<plugin-name>.lua`:

```lua
return {
  {
    "author/plugin-name",
    event = "User BaseFile",
    opts = {
      -- Plugin options
    },
  },
}
```

2. Configure the plugin in `lua/configs/<plugin-name>.lua`:
```lua
local M = {}

M.plugin_name = {
  -- Configuration options
}

return M
```

## 🏗️ Architecture

This repo uses NvChad v3.0 as a plugin, not as a base installation:

- Main NvChad repo is loaded as a plugin via lazy.nvim
- Import NvChad modules: `require "nvchad.options"`, `require "nvchad.mappings"`
- Customize via overriding configs in `lua/` directory
- All configuration is Lua-based with 2-space indentation

## 📦 Key Plugins

- **Core**: NvChad v3.0, lazy.nvim, plenary.nvim
- **Editor**: nvim-treesitter, nvim-lspconfig, blink.cmp
- **UI**: telescope.nvim, lualine.nvim, nvim-tree, oil.nvim
- **Git**: gitsigns.nvim, lazygit.nvim
- **Testing**: neotest
- **AI**: Claude Code, Sidekick, Opencode, and PR review helpers
- **Productivity**: harpoon, obsidian.nvim

## 🧪 Testing

Run focused Lua specs from the command line:

```bash
~/.luarocks/bin/busted tests/opencode_spec.lua specs/task_workflow_spec.lua specs/task_workflow_config_spec.lua
```

## 📝 Notes

- This configuration can be forked or cloned and used as a personal Neovim setup
- Delete `.git/` folder if you want to use it as your own configuration
- All plugin specifications are lazy-loaded for optimal performance

## 🙏 Credits

- [LazyVim/starter](https://github.com/LazyVim/starter) - NvChad's starter was inspired by LazyVim's approach
- [NvChad](https://github.com/NvChad/NvChad) - Base configuration framework
- All plugin authors and contributors

## 📄 License

This configuration follows the same license as NvChad.

---
*Last updated: February 2026*
