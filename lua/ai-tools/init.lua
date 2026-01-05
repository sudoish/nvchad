-- AI Tools module
-- This module provides a centralized way to select which AI tools to use
-- Tools are categorized into two modalities:
--   - chat: AI assistants for conversation/code generation (claudecode, sidekick, amp, augment)
--   - completion: Inline code completion (supermaven, copilot)

local M = {}

-- Available AI tools by category
M.chat = {
  "claudecode", -- Claude Code native plugin
  "sidekick", -- Sidekick.nvim (universal CLI wrapper for claude, droid, etc.)
  "amp", -- Sourcegraph Amp
  "augment", -- Augment Code
  "droid", -- Droid (Factory AI agent)
}

M.completion = {
  "supermaven", -- Supermaven inline completion
  "copilot", -- GitHub Copilot
}

-- Get the configuration for a specific AI tool
---@param name string The name of the AI tool
---@return table The plugin spec for the AI tool
function M.get(name)
  local ok, tool = pcall(require, "ai-tools." .. name)
  if ok then
    return tool
  end
  vim.notify("AI tool '" .. name .. "' not found", vim.log.levels.WARN)
  return {}
end

-- Get multiple AI tool configurations
---@param names string[] List of AI tool names
---@return table[] List of plugin specs
function M.get_multiple(names)
  local specs = {}
  for _, name in ipairs(names) do
    local spec = M.get(name)
    if spec and next(spec) then
      table.insert(specs, spec)
    end
  end
  return specs
end

-- Check if a tool name is valid for a category
---@param name string The tool name
---@param category "chat"|"completion" The category to check
---@return boolean
function M.is_valid(name, category)
  local list = category == "chat" and M.chat or M.completion
  for _, tool in ipairs(list) do
    if tool == name then
      return true
    end
  end
  return false
end

return M
