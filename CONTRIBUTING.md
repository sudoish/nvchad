# Contributing to NvChad Configuration

Thank you for your interest in contributing! This document provides guidelines for contributing to this NvChad configuration repository.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/nvchad.git`
3. Create a feature branch: `git checkout -b feature/your-feature`
4. Make your changes following the guidelines below

## Development Workflow

### Prerequisites

- Neovim 0.9+
- Lua 5.4 (for luacheck)
- stylua (for formatting)
- luacheck (for linting)
- pre-commit (for commit hooks)

### Make Changes

1. Edit configuration files in `lua/` directory
2. Add new plugins via `lua/plugins/` directory
3. Follow the code style guidelines below

### Before Committing

Install pre-commit hooks (recommended):
```bash
pre-commit install
```

Run manual checks:
```bash
# Format code
stylua .

# Lint code
luacheck .

# Test configuration
nvim --headless -u init.lua -c "lua vim.cmd('quit')"
```

### Create Pull Request

1. Push your branch: `git push origin feature/your-feature`
2. Create a pull request on GitHub
3. Fill out the PR template with:
   - Description of changes
   - Type of change
   - Testing done
   - Related issues

## Code Style

### Lua Guidelines

- **Indent**: 2 spaces
- **Line width**: 120 characters
- **Quote style**: Double quotes preferred
- **File naming**: snake_case
- **Module exports**: Use `local M = {} ... return M` or `return { }`

### Module Structure

```lua
local M = {}

-- Module exports
function M.setup()
  -- Configuration logic
end

return M
```

### Configuration Patterns

```lua
-- Use require for configs
local config = require "configs.name"

-- Use pcall for potentially failing operations
local ok, plugin = pcall(require, "plugin-name")
if ok then
  -- Configure plugin
end
```

### Type Annotations

Add `---@type` annotations where helpful:

```lua
---@type PluginSpec
local plugin = {
  "author/plugin",
  config = function()
    -- Configuration
  end,
}
```

## Testing

### Basic Validation

```bash
nvim --headless -u init.lua -c "lua vim.cmd('quit')"
```

### Test Suite

Run tests using Neotest:
```
:Neotest run
```

## Plugin Guidelines

### Adding Plugins

1. Create a new file in `lua/plugins/<plugin-name>.lua`
2. Follow this structure:

```lua
return {
  {
    "author/plugin-name",
    keys = "<leader>k",  -- Lazy load on key
    event = "LspAttach", -- or event-based loading
    dependencies = {
      "other/plugin",
    },
    opts = {
      -- Plugin options
    },
    config = function(_, opts)
      require("plugin-name").setup(opts)
    end,
  }
}
```

### Plugin Configuration

- Put shared configs in `lua/configs/`
- Use `require "configs.name"` pattern
- Follow NvChad conventions for plugin setup

## Documentation

### When to Update Documentation

- Adding new plugins
- Changing configuration structure
- Adding new features
- Breaking changes

### Documentation Files

- `README.md`: User-facing documentation
- `AGENTS.md`: Developer documentation for AI agents
- `CONTRIBUTING.md`: This file
- Inline comments: For complex logic

## Project Structure

```
.
├── .github/
│   ├── ISSUE_TEMPLATE/  # Issue templates
│   ├── pull_request_template.md
│   ├── dependabot.yml   # Dependency updates
│   └── labels.yml       # Issue/PR labels
├── lua/
│   ├── chadrc.lua       # Main NvChad config
│   ├── options.lua      # Neovim options
│   ├── mappings.lua     # Key mappings
│   ├── autocmds.lua     # Autocommands
│   ├── configs/         # Plugin configurations
│   │   ├── lazy.lua
│   │   ├── conform.lua
│   │   └── lspconfig.lua
│   ├── plugins/         # Plugin specifications
│   │   ├── init.lua
│   │   ├── completion.lua
│   │   └── ...
│   └── ai-tools/        # AI tool configurations
│       └── init.lua
├── tests/
│   └── config_spec.lua  # Configuration tests
├── .luacheckrc          # Lua linter config
├── .pre-commit-config.yaml
├── .stylua.toml         # Formatter config
├── .gitignore
├── .env.example
├── AGENTS.md
├── CONTRIBUTING.md
├── init.lua
├── lazy-lock.json
└── README.md
```

## Questions and Support

- Open an issue for bugs or questions
- Use `[QUESTION]` prefix for questions
- Check existing issues first

## License

This configuration follows the same license as NvChad.
