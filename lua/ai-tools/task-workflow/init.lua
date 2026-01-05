--- Task Workflow Orchestrator
--- Integrates task input, git worktree creation, tmux window management,
--- and AI chat initialization for a complete development workflow.
local M = {}

-- Dependencies
local config = require "ai-tools.task-workflow.config"
local worktree = require "utils.worktree"
local tmux = require "utils.tmux"
local slugify = require "utils.slugify"
local task_input = require "ai-tools.task-input"

--- Helper to notify user based on config settings
---@param msg string The message to display
---@param level number The vim.log.levels value
local function notify(msg, level)
  if level == vim.log.levels.ERROR or level == vim.log.levels.WARN then
    if config.notifications.errors then
      vim.notify(msg, level)
    end
  else
    if config.notifications.success then
      vim.notify(msg, level)
    end
  end
end

--- Cleanup resources on failure
--- Removes worktree and kills tmux window
---@param branch_name string The branch/window name
---@param worktree_path string The worktree path to remove
---@return table result { success: boolean, error: string|nil }
function M.cleanup(branch_name, worktree_path)
  local errors = {}

  -- Try to remove worktree
  if worktree_path and worktree_path ~= "" then
    local worktree_result = worktree.remove(worktree_path)
    if not worktree_result.success then
      table.insert(errors, "Worktree: " .. (worktree_result.error or "unknown error"))
    end
  end

  -- Try to kill tmux window (continue even if worktree removal failed)
  if branch_name and branch_name ~= "" then
    local tmux_result = tmux.kill_window(branch_name)
    if not tmux_result.success then
      table.insert(errors, "Tmux: " .. (tmux_result.error or "unknown error"))
    end
  end

  if #errors > 0 then
    return {
      success = false,
      error = "Cleanup errors: " .. table.concat(errors, "; "),
    }
  end

  return {
    success = true,
    error = nil,
  }
end

--- Build the task prompt from task data
---@param task table The task { title, description }
---@return string prompt The formatted prompt
function M.build_task_prompt(task)
  local prompt = "## Task: " .. task.title
  if task.description and task.description ~= "" then
    prompt = prompt .. "\n\n" .. task.description
  end
  return prompt
end

--- Initialize AI chat from saved task file (called in new neovim instance)
--- This is meant to be called via nvim -c from the new tmux window
function M.initialize_from_saved_task()
  vim.defer_fn(function()
    local task = task_input.get_task()

    if not task then
      vim.notify("No saved task found", vim.log.levels.WARN)
      return
    end

    -- Toggle sidekick with the AI tool
    local ok, err = pcall(function()
      local sidekick_cli = require "sidekick.cli"
      sidekick_cli.toggle { name = config.default_ai_tool, focus = true }
    end)

    if not ok then
      vim.notify("Failed to toggle sidekick: " .. tostring(err), vim.log.levels.WARN)
      return
    end

    -- Send the task prompt after sidekick has opened
    vim.defer_fn(function()
      local send_ok, send_err = pcall(function()
        local sidekick_cli = require "sidekick.cli"
        local prompt = M.build_task_prompt(task)
        sidekick_cli.send { msg = prompt }
      end)

      if not send_ok then
        vim.notify("Failed to send task prompt: " .. tostring(send_err), vim.log.levels.WARN)
      end
    end, 500)
  end, 1000) -- Wait for neovim to fully load
end

--- Initialize AI chat with task context (deprecated - kept for API compatibility)
--- Note: This runs in the original window. For new tmux windows, use initialize_from_saved_task()
---@param task table The task { title, description }
---@param worktree_path string The worktree path (for context)
---@return table result { success: boolean, error: string|nil }
function M.initialize_ai_chat(task, worktree_path)
  -- This function is now a no-op since AI chat is initialized in the new window
  -- via the nvim -c command that calls initialize_from_saved_task()
  return {
    success = true,
    error = nil,
  }
end

--- Create the development environment for a task
--- Creates git worktree and tmux window
---@param task table The task { title, description }
---@param callback function Callback receiving { success, error, result }
function M.create_environment(task, callback)
  -- Validate task
  if not task or not task.title then
    callback {
      success = false,
      error = "Task title is required",
      result = nil,
    }
    return
  end

  -- Check preconditions: must be inside tmux
  if not tmux.is_inside_tmux() then
    callback {
      success = false,
      error = "Must be running inside tmux session",
      result = nil,
    }
    return
  end

  -- Generate slugified branch name
  local branch_name = slugify.slugify(task.title)
  if branch_name == "" then
    callback {
      success = false,
      error = "Failed to generate branch name from task title",
      result = nil,
    }
    return
  end

  -- Build worktree path
  local worktree_path = config.trees_folder .. "/" .. branch_name

  -- Step 1: Create worktree
  local worktree_result = worktree.create(branch_name, worktree_path)
  if not worktree_result.success then
    notify("Failed to create worktree: " .. (worktree_result.error or "unknown"), vim.log.levels.ERROR)
    callback {
      success = false,
      error = worktree_result.error,
      result = nil,
    }
    return
  end

  -- Step 2: Create tmux window
  local tmux_result = tmux.create_window(branch_name, worktree_path)
  if not tmux_result.success then
    -- Cleanup: remove the worktree we just created
    worktree.remove(worktree_path)
    notify("Failed to create tmux window: " .. (tmux_result.error or "unknown"), vim.log.levels.ERROR)
    callback {
      success = false,
      error = tmux_result.error,
      result = nil,
    }
    return
  end

  -- Step 3: Switch to the new window
  local switch_result = tmux.switch_window(branch_name)
  if not switch_result.success then
    notify("Warning: Could not switch to new window", vim.log.levels.WARN)
    -- Continue anyway, user can switch manually
  end

  -- Step 4: Wait a moment for the window to be ready, then send nvim command
  vim.defer_fn(function()
    local nvim_cmd = [[nvim . -c "lua require('ai-tools.task-workflow').initialize_from_saved_task()"]]
    local send_result = tmux.send_command(branch_name, nvim_cmd)
    if not send_result.success then
      notify("Warning: Could not start nvim in new window: " .. (send_result.error or "unknown"), vim.log.levels.WARN)
    else
      notify("Starting nvim in task window...", vim.log.levels.INFO)
    end
  end, 500) -- Wait 500ms for window to be ready

  -- Success!
  notify("Task environment created: " .. branch_name, vim.log.levels.INFO)
  callback {
    success = true,
    error = nil,
    result = {
      branch_name = branch_name,
      worktree_path = worktree_path,
      window_id = tmux_result.window_id,
      task = task,
    },
  }
end

--- Start the complete task workflow interactively
--- Prompts for task input, creates environment, and initializes AI chat
---@param callback function Callback receiving { success, error, result }
function M.start(callback)
  callback = callback or function() end

  -- Step 1: Get task input from user
  task_input.input_task(function(success, task)
    if not success or not task then
      notify("Task input cancelled", vim.log.levels.INFO)
      callback {
        success = false,
        error = "Task input cancelled",
        result = nil,
      }
      return
    end

    -- Step 2: Create the development environment
    -- Note: AI chat initialization happens automatically in the new window
    -- via the nvim -c command that calls initialize_from_saved_task()
    M.create_environment(task, function(env_result)
      if not env_result.success then
        callback(env_result)
        return
      end

      callback(env_result)
    end)
  end)
end

return M
