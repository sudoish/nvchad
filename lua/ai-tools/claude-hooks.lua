--- Claude Code Hooks Setup Module
--- Automatically configures Claude Code hooks for any user of this nvim config
local M = {}

local setup_hooks = require "ai-tools.task-workflow.setup-hooks"

--- Setup Claude Code hooks with user feedback
---@param silent boolean|nil Whether to suppress notifications
function M.setup(silent)
  silent = silent or false

  -- Check if hooks are already properly configured
  local claude_settings_path = vim.fn.expand "~/.claude/settings.json"
  local f = io.open(claude_settings_path, "r")
  local existing_hooks = false

  if f then
    local content = f:read "*all"
    f:close()
    if content and content ~= "" then
      local ok, decoded = pcall(vim.json.decode, content)
      if ok and decoded and decoded.hooks then
        existing_hooks = true
      end
    end
  end

  -- Perform the setup
  local result = setup_hooks.setup()

  if result.success then
    if not silent then
      if existing_hooks then
        vim.notify("Claude Code hooks updated successfully", vim.log.levels.INFO)
      else
        vim.notify("Claude Code hooks installed successfully", vim.log.levels.INFO)
      end
    end
    return true
  else
    if not silent then
      vim.notify("Failed to setup Claude Code hooks: " .. (result.error or "unknown error"), vim.log.levels.ERROR)
    end
    return false
  end
end

--- Remove Claude Code hooks
---@param silent boolean|nil Whether to suppress notifications
function M.cleanup(silent)
  silent = silent or false

  -- Clear hooks by writing empty settings
  local claude_settings_path = vim.fn.expand "~/.claude/settings.json"
  local f = io.open(claude_settings_path, "r")

  if not f then
    if not silent then
      vim.notify("No Claude Code settings found", vim.log.levels.INFO)
    end
    return true
  end

  local content = f:read "*all"
  f:close()

  local ok, decoded = pcall(vim.json.decode, content)
  if not ok then
    if not silent then
      vim.notify("Failed to parse Claude Code settings", vim.log.levels.ERROR)
    end
    return false
  end

  -- Remove hooks section
  decoded.hooks = nil

  -- Write back without hooks
  f = io.open(claude_settings_path, "w")
  if not f then
    if not silent then
      vim.notify("Failed to write Claude Code settings", vim.log.levels.ERROR)
    end
    return false
  end

  local encoded = vim.json.encode(decoded)
  f:write(encoded)
  f:close()

  if not silent then
    vim.notify("Claude Code hooks removed", vim.log.levels.INFO)
  end
  return true
end

--- Check if hooks are properly configured
---@return boolean configured Whether hooks are configured
function M.check_configured()
  local claude_settings_path = vim.fn.expand "~/.claude/settings.json"
  local f = io.open(claude_settings_path, "r")

  if not f then
    return false
  end

  local content = f:read "*all"
  f:close()

  if not content or content == "" then
    return false
  end

  local ok, decoded = pcall(vim.json.decode, content)
  if not ok or not decoded or not decoded.hooks then
    return false
  end

  return true
end

--- Auto-setup function that runs silently
--- Intended to be called automatically when nvim starts
function M.auto_setup()
  -- Only setup if not already configured
  if not M.check_configured() then
    M.setup(true) -- silent mode
  end
end

return M
