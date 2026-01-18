--- Tmux Window Management Module
--- Provides utilities for creating and managing tmux windows from Neovim
local M = {}

--- Pattern for valid window names: alphanumeric, hyphens, underscores
--- Must not start with a hyphen
local VALID_NAME_PATTERN = "^[a-zA-Z0-9_][a-zA-Z0-9_%-]*$"

--- Helper function to trim whitespace from string
---@param s string
---@return string
local function trim(s)
  if not s then
    return ""
  end
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--- Generate a tmux-safe window name from any string
---@param text string The input text
---@return string safe_name A tmux-safe window name
function M.generate_safe_name(text)
  if type(text) ~= "string" or #text == 0 then
    return "task"
  end

  local result = {}
  local i = 1

  while i <= #text do
    local char = text:sub(i, i)
    local byte = string.byte(char)

    -- Allow alphanumeric characters
    if byte and ((byte >= 48 and byte <= 57) or (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122)) then
      result[#result + 1] = char:lower()
    -- Allow underscores and hyphens as separators
    elseif char == "_" or char == "-" then
      if #result > 0 and result[#result] ~= "_" and result[#result] ~= "-" then
        result[#result + 1] = "_"
      end
    -- Replace other characters with underscores
    elseif #result > 0 and result[#result] ~= "_" then
      result[#result + 1] = "_"
    end

    i = i + 1
  end

  local safe_name = table.concat(result)

  -- Remove leading/trailing underscores
  safe_name = safe_name:gsub("^_+", "")
  safe_name = safe_name:gsub("_+$", "")

  -- Ensure it doesn't start with a hyphen
  if safe_name:sub(1, 1) == "-" then
    safe_name = "_" .. safe_name:sub(2)
  end

  -- Limit length for tmux window names (reasonable limit)
  if #safe_name > 50 then
    safe_name = safe_name:sub(1, 50)
  end

  -- Ensure we have at least one character
  if safe_name == "" then
    safe_name = "task"
  end

  return safe_name
end

--- Helper function to execute tmux command and check result
---@param cmd string The tmux command to execute
---@return string output The command output
---@return boolean success Whether the command succeeded
local function exec_tmux(cmd)
  local output = vim.fn.system(cmd)
  local success = vim.v.shell_error == 0
  return output, success
end

--- Check if currently running inside a tmux session
---@return boolean is_in_tmux True if inside tmux, false otherwise
function M.is_inside_tmux()
  local tmux_env = vim.env.TMUX
  return tmux_env ~= nil and tmux_env ~= ""
end

--- Validate a tmux window name
---@param name string|nil The window name to validate
---@return boolean valid True if valid, false otherwise
---@return string|nil error Error message if invalid, nil if valid
function M.validate_window_name(name)
  if name == nil then
    return false, "Window name cannot be nil"
  end

  if type(name) ~= "string" then
    return false, "Window name must be a string"
  end

  if name == "" then
    return false, "Window name cannot be empty"
  end

  if name:sub(1, 1) == "-" then
    return false, "Window name cannot start with a hyphen"
  end

  if not name:match(VALID_NAME_PATTERN) then
    return false, "Window name contains invalid characters (only alphanumeric, hyphens, and underscores allowed)"
  end

  return true, nil
end

--- Get the current tmux session name
---@return string|nil session_name The session name, or nil if not in tmux
function M.get_current_session()
  if not M.is_inside_tmux() then
    return nil
  end

  local output = vim.fn.system [[tmux display-message -p "#S"]]
  return trim(output)
end

--- Create a new tmux window in the current session
---@param window_name string The name for the new window
---@param path string The working directory for the new window
---@return table result { success: boolean, window_id: string|nil, error: string|nil }
function M.create_window(window_name, path)
  -- Check if inside tmux
  if not M.is_inside_tmux() then
    return {
      success = false,
      window_id = nil,
      error = "Not running inside tmux session",
    }
  end

  -- Validate window name
  local valid, err = M.validate_window_name(window_name)
  if not valid then
    return {
      success = false,
      window_id = nil,
      error = err,
    }
  end

  -- Validate path
  if path == nil or path == "" then
    return {
      success = false,
      window_id = nil,
      error = "Path cannot be empty",
    }
  end

  -- Create the window
  local cmd = string.format([[tmux new-window -n "%s" -c "%s"]], window_name, path)
  local output, success = exec_tmux(cmd)

  if not success then
    return {
      success = false,
      window_id = nil,
      error = "Failed to create window: " .. trim(output),
    }
  end

  -- Get the window ID of the newly created window
  local window_id = trim(vim.fn.system [[tmux display-message -p "#I"]])

  return {
    success = true,
    window_id = window_id,
    error = nil,
  }
end

--- Switch to a specific tmux window
---@param window_name string The name of the window to switch to
---@return table result { success: boolean, error: string|nil }
function M.switch_window(window_name)
  -- Check if inside tmux
  if not M.is_inside_tmux() then
    return {
      success = false,
      error = "Not running inside tmux session",
    }
  end

  -- Validate window name
  local valid, err = M.validate_window_name(window_name)
  if not valid then
    return {
      success = false,
      error = err,
    }
  end

  -- Switch to the window
  local cmd = string.format([[tmux select-window -t "%s"]], window_name)
  local output, success = exec_tmux(cmd)

  if not success then
    return {
      success = false,
      error = "Failed to switch to window: " .. trim(output),
    }
  end

  return {
    success = true,
    error = nil,
  }
end

--- Send a command to a specific tmux window
---@param window_name string The target window name
---@param command string The command to send
---@return table result { success: boolean, error: string|nil }
function M.send_command(window_name, command)
  -- Check if inside tmux
  if not M.is_inside_tmux() then
    return {
      success = false,
      error = "Not running inside tmux session",
    }
  end

  -- Validate window name
  local valid, err = M.validate_window_name(window_name)
  if not valid then
    return {
      success = false,
      error = err,
    }
  end

  -- Validate command
  if command == nil then
    return {
      success = false,
      error = "Command cannot be nil",
    }
  end

  if command == "" then
    return {
      success = false,
      error = "Command cannot be empty",
    }
  end

  -- Send the command directly - tmux send-keys types into the target shell
  local cmd = string.format('tmux send-keys -t "%s" %s Enter', window_name, vim.fn.shellescape(command))
  local output, success = exec_tmux(cmd)

  if not success then
    return {
      success = false,
      error = "Failed to send command: " .. trim(output),
    }
  end

  return {
    success = true,
    error = nil,
  }
end

--- Kill/close a tmux window
---@param window_name string The name of the window to kill
---@return table result { success: boolean, error: string|nil }
function M.kill_window(window_name)
  -- Check if inside tmux
  if not M.is_inside_tmux() then
    return {
      success = false,
      error = "Not running inside tmux session",
    }
  end

  -- Validate window name
  local valid, err = M.validate_window_name(window_name)
  if not valid then
    return {
      success = false,
      error = err,
    }
  end

  -- Kill the window
  local cmd = string.format([[tmux kill-window -t "%s"]], window_name)
  local output, success = exec_tmux(cmd)

  if not success then
    return {
      success = false,
      error = "Failed to kill window (may not exist): " .. trim(output),
    }
  end

  return {
    success = true,
    error = nil,
  }
end

--- Get the current window name
---@return string|nil window_name The current window name, or nil if not in tmux
function M.get_current_window_name()
  if not M.is_inside_tmux() then
    return nil
  end
  return trim(vim.fn.system 'tmux display-message -p "#W"')
end

--- Get the current window index
---@return string|nil window_index The current window index, or nil if not in tmux
function M.get_current_window_index()
  if not M.is_inside_tmux() then
    return nil
  end
  return trim(vim.fn.system 'tmux display-message -p "#I"')
end

return M
