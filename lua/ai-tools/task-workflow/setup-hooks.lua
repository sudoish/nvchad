--- Setup Hooks Module for Claude Code Attention Notifications
--- Provides utilities to install Claude Code hook configuration
local M = {}

local config = require "ai-tools.task-workflow.config"

--- Get the path to the scripts directory in the nvim config
---@return string scripts_dir The path to the scripts directory
local function get_scripts_dir()
  return vim.fn.stdpath "config" .. "/scripts"
end

--- Generate the Claude Code hooks configuration
---@return table hooks_config The hooks configuration table
function M.generate_hooks_config()
  local cfg = config.notifications.claude_attention
  if not cfg.enabled then
    return {}
  end

  local scripts_dir = get_scripts_dir()
  local attention_script = scripts_dir .. "/claude-attention.sh"
  local clear_script = scripts_dir .. "/claude-attention-clear.sh"

  local hooks = {
    UserPromptSubmit = {
      {
        hooks = {
          { type = "command", command = clear_script },
        },
      },
    },
  }

  -- Add notification hooks based on enabled events
  local notification_hooks = {}

  if cfg.events.permission_prompt then
    table.insert(notification_hooks, {
      matcher = "permission_prompt",
      hooks = {
        { type = "command", command = attention_script },
      },
    })
  end

  if cfg.events.idle_prompt then
    table.insert(notification_hooks, {
      matcher = "idle_prompt",
      hooks = {
        { type = "command", command = attention_script },
      },
    })
  end

  if #notification_hooks > 0 then
    hooks.Notification = notification_hooks
  end

  if cfg.events.stop then
    hooks.Stop = {
      {
        hooks = {
          { type = "command", command = attention_script },
        },
      },
    }
  end

  return { hooks = hooks }
end

--- Write hooks configuration to Claude Code settings
---@param merge boolean|nil Whether to merge with existing settings (default: true)
---@return table result { success: boolean, error: string|nil }
function M.install_hooks(merge)
  merge = merge ~= false

  local claude_settings_path = vim.fn.expand "~/.claude/settings.json"
  local hooks_config = M.generate_hooks_config()

  if merge then
    -- Read existing settings
    local existing = {}
    local f = io.open(claude_settings_path, "r")
    if f then
      local content = f:read "*all"
      f:close()
      local ok, decoded = pcall(vim.json.decode, content)
      if ok and decoded then
        existing = decoded
      end
    end

    -- Merge hooks
    existing.hooks = existing.hooks or {}
    for event, event_hooks in pairs(hooks_config.hooks) do
      existing.hooks[event] = event_hooks
    end

    hooks_config = existing
  end

  -- Ensure directory exists
  vim.fn.mkdir(vim.fn.expand "~/.claude", "p")

  -- Write settings
  local f = io.open(claude_settings_path, "w")
  if not f then
    return { success = false, error = "Failed to open settings file for writing" }
  end

  local ok, encoded = pcall(vim.json.encode, hooks_config)
  if not ok then
    f:close()
    return { success = false, error = "Failed to encode JSON: " .. tostring(encoded) }
  end

  f:write(encoded)
  f:close()

  return { success = true }
end

--- Verify that the hook scripts exist
---@return table result { success: boolean, error: string|nil }
function M.verify_scripts()
  local scripts_dir = get_scripts_dir()
  local attention_script = scripts_dir .. "/claude-attention.sh"
  local clear_script = scripts_dir .. "/claude-attention-clear.sh"

  if vim.fn.filereadable(attention_script) ~= 1 then
    return { success = false, error = "Attention script not found: " .. attention_script }
  end

  if vim.fn.filereadable(clear_script) ~= 1 then
    return { success = false, error = "Clear script not found: " .. clear_script }
  end

  return { success = true }
end

--- Full setup: verify scripts exist and install hooks
---@return table result { success: boolean, error: string|nil }
function M.setup()
  -- Verify scripts exist
  local result = M.verify_scripts()
  if not result.success then
    return result
  end

  -- Install hooks
  result = M.install_hooks(true)
  if not result.success then
    return result
  end

  return { success = true }
end

return M
