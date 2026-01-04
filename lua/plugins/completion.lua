-- AI Completion and Chat Tools
-- Configure which AI tools to use by changing the variables below

local ai_tools = require("ai-tools")

--------------------------------------------------------------------------------
-- CONFIGURATION
--------------------------------------------------------------------------------

-- CHAT TOOL: AI assistant for conversation and code generation
-- Available options: "claudecode", "sidekick", "amp", "augment", or nil to disable
local CHAT_TOOL = "claudecode"

-- COMPLETION TOOL: Inline code completion
-- Available options: "supermaven", "copilot", or nil to disable
local COMPLETION_TOOL = "supermaven"

--------------------------------------------------------------------------------

-- Build the plugin specs based on configuration
local plugins = {}

-- Add chat tool if configured
if CHAT_TOOL then
    local chat = ai_tools.get(CHAT_TOOL)
    if chat and next(chat) then
        table.insert(plugins, chat)
    end
end

-- Add completion tool if configured
if COMPLETION_TOOL then
    local completion = ai_tools.get(COMPLETION_TOOL)
    if completion and next(completion) then
        table.insert(plugins, completion)
    end
end

return plugins
