# AGENTS.md - NvChad Configuration

## Build/Lint/Test Commands
- **Format Lua**: `stylua .` (uses .stylua.toml config)
- **Check config**: `nvim --headless -c "checkhealth" -c "quit"`
- **Syntax check**: `nvim --headless -u init.lua -c "lua vim.cmd('quit')"`

## Code Style Guidelines
- **Language**: Lua only
- **Indentation**: 2 spaces (defined in .stylua.toml)
- **Line width**: 120 characters max
- **Quote style**: Auto-prefer double quotes
- **Call parentheses**: None (stylua removes unnecessary parentheses)

## File Structure
- `lua/configs/`: Plugin configurations
- `lua/plugins/`: Plugin specifications for lazy.nvim
- `lua/chadrc.lua`: Main NvChad configuration
- `lua/mappings.lua`: Custom keymaps
- `lua/options.lua`: Vim options

## Naming Conventions
- Use snake_case for file names
- Use descriptive variable names
- Follow NvChad's module pattern: return table from config files

## Error Handling
- Use pcall() for potentially failing operations
- Provide fallbacks for missing dependencies
- Check plugin availability before configuration