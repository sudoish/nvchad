# AGENTS.md - NvChad Configuration

## Build/Lint/Test Commands
- **Format**: `stylua .` (2 spaces, 120 cols, double quotes, no call parens)
- **Lint**: `luacheck .` (static analysis for Lua code)
- **Validate**: `nvim --headless -u init.lua -c "lua vim.cmd('quit')"` or `:checkhealth`
- **AI Specs**: `~/.luarocks/bin/busted tests/opencode_spec.lua specs/task_workflow_spec.lua specs/task_workflow_config_spec.lua`

## Architecture
- NvChad v3.0 config using lazy.nvim plugin manager
- `lua/chadrc.lua`: Main config (theme, UI, transparency) - follows nvconfig.lua structure
- `lua/plugins/init.lua`: Core plugins (conform, lspconfig, blink)
- `lua/plugins/*.lua`: Feature plugins (git, testing, obsidian, oil, etc.)
- AI integrations are configured in `lua/plugins/claudecode.lua`, `lua/plugins/sidekick.lua`, `lua/plugins/opencode.lua`, `lua/plugins/pr-review.lua`, and `lua/plugins/task-workflow.lua`
- Task workflow logic lives in `lua/ai-tools/task-workflow/`; task input lives in `lua/ai-tools/task-input.lua`
- Branch review prompt lives in `prompts/review-branch.md`
- `lua/configs/`: Plugin-specific configs (conform.lua, lspconfig.lua, lazy.lua)
- `lua/mappings.lua`: Keymaps | `lua/options.lua`: Vim opts | `lua/autocmds.lua`: Autocommands

## AI Notes
- `luacheck .` excludes `.trees/` worktrees so lint reflects the active repo
- Keep AI workflow docs aligned with `lua/plugins/` and `lua/ai-tools/task-workflow/`

## Code Style
- **Lua only**, 2-space indent, 120 char line width
- Return tables from modules: `local M = {} ... return M` or `return { ... }`
- Use `require "configs.name"` for plugin opts, `require "configs.name"` in config functions
- snake_case for files; use `---@type` annotations where helpful
- Use pcall() for potentially failing operations; check plugin availability before config
