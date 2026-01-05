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
- (Optional) tmux (recommended for task workflow)

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
2. Create a git worktree (optional)
3. Open a new tmux session
4. Launch your preferred AI chat agent

AI tools are configured in `lua/ai-tools/` and include:
- **claudecode**: Native Claude Code integration
- **sidekick**: Universal CLI wrapper for Claude, Droid, etc.
- **amp**: Sourcegraph Amp
- **supermaven**: Fast inline code completion
- **copilot**: GitHub Copilot

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
│   └── *.lua         # Feature plugins (git, testing, obsidian, etc.)
└── ai-tools/         # AI tool configurations
    ├── init.lua      # Tool selection system
    ├── task-workflow/# Task workflow orchestration
    └── *.lua         # Individual AI tool configs
```

### Customization

To customize AI tools, modify `lua/ai-tools/init.lua`:

```lua
-- Enable specific AI tools by editing your plugin specs
-- in lua/plugins/*.lua files

-- Example: Use Claude Code + Supermaven
require "ai-tools.claudecode"
require "ai-tools.supermaven"
```

## 🛠️ Development

### Code Quality Tools

```bash
# Format code (2 spaces, 120 cols)
stylua .

# Lint Lua code
luacheck .

# Validate Neovim config
nvim --headless -u init.lua -c "lua vim.cmd('quit')"

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
- **AI**: Various AI assistants (see AI Tools section)
- **Productivity**: harpoon, obsidian.nvim

## 🧪 Testing

Run tests using Neotest:

```vim
:Neotest run
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
