-- Task Input Module
-- Provides interactive task input with temporary storage for AI assistant tasks

local M = {}

--------------------------------------------------------------------------------
-- STORAGE
--------------------------------------------------------------------------------

-- Path to temporary task storage file
local task_storage_path = vim.fn.stdpath "data" .. "/ai-tools-task.json"

-- In-memory task storage
local current_task = {
  title = nil,
  description = nil,
}

--------------------------------------------------------------------------------
-- VALIDATION
--------------------------------------------------------------------------------

-- Validate task title
---@param title string The task title to validate
---@return boolean, string|nil True if valid, false with error message
local function validate_title(title)
  if not title or title == "" then
    return false, "Title cannot be empty"
  end
  if #title > 1000 then
    return false, "Title cannot exceed 1000 characters"
  end
  return true
end

--------------------------------------------------------------------------------
-- STORAGE FUNCTIONS
--------------------------------------------------------------------------------

-- Load task from storage file
local function load_task_from_file()
  local file = io.open(task_storage_path, "r")
  if not file then
    return
  end
  local content = file:read "*a"
  file:close()
  if content and content ~= "" then
    local ok, data = pcall(vim.json.decode, content)
    if ok and data then
      current_task = data
    end
  end
end

-- Save task to storage file
local function save_task_to_file()
  local file = io.open(task_storage_path, "w")
  if not file then
    vim.notify("Failed to save task data", vim.log.levels.ERROR)
    return false
  end
  file:write(vim.json.encode(current_task))
  file:close()
  return true
end

--------------------------------------------------------------------------------
-- INPUT FUNCTIONS
--------------------------------------------------------------------------------

-- Prompt user for task input interactively
---@param callback function Callback function receiving (success, task)
function M.input_task(callback)
  current_task = { title = nil, description = nil }

  vim.ui.input({
    prompt = "Task title: ",
  }, function(title)
    -- Cancel if title is nil (user pressed Esc)
    if not title then
      callback(false, nil)
      return
    end

    -- Validate title
    local valid, err = validate_title(title)
    if not valid then
      vim.notify(err, vim.log.levels.WARN)
      callback(false, nil)
      return
    end

    current_task.title = title

    -- Prompt for description (optional)
    vim.ui.input({
      prompt = "Task description (optional): ",
    }, function(description)
      if description and description ~= "" then
        current_task.description = description
      end

      -- Save to storage
      if save_task_to_file() then
        callback(true, current_task)
      else
        callback(false, nil)
      end
    end)
  end)
end

--------------------------------------------------------------------------------
-- API FUNCTIONS
--------------------------------------------------------------------------------

-- Get the current task
---@return table|nil The current task or nil if not set
function M.get_task()
  if not current_task.title then
    return nil
  end
  return vim.deepcopy(current_task)
end

-- Set a task programmatically
---@param title string The task title
---@param description string|nil The task description
---@return boolean True if successful
function M.set_task(title, description)
  local valid, err = validate_title(title)
  if not valid then
    vim.notify(err, vim.log.levels.WARN)
    return false
  end

  current_task = {
    title = title,
    description = description,
  }

  return save_task_to_file()
end

-- Clear the current task
---@return boolean True if successful
function M.clear_task()
  current_task = { title = nil, description = nil }
  local file = io.open(task_storage_path, "w")
  if file then
    file:write "{}"
    file:close()
    return true
  end
  return false
end

-- Check if a task exists
---@return boolean True if a task is set
function M.has_task()
  return current_task.title ~= nil and current_task.title ~= ""
end

--------------------------------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------------------------------

-- Load existing task on module load
load_task_from_file()

return M
