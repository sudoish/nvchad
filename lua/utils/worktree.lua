local M = {}

-- Invalid characters for git branch names
local INVALID_BRANCH_CHARS = {
  " ", -- space
  "~", -- tilde
  "^", -- caret
  ":", -- colon
  "?", -- question mark
  "*", -- asterisk
  "[", -- open bracket
  "\\", -- backslash
  "\t", -- tab
  "\n", -- newline
  "\r", -- carriage return
}

--- Check if we're in a git repository
--- @return boolean
local function is_git_repo()
  local result = vim.fn.system "git rev-parse --is-inside-work-tree 2>/dev/null"
  return vim.v.shell_error == 0 and result:match "true" ~= nil
end

--- Validate a branch name according to git's rules
--- @param name string|nil The branch name to validate
--- @return boolean valid Whether the name is valid
--- @return string|nil error Error message if invalid
function M.validate_branch_name(name)
  -- Check for nil or non-string
  if name == nil then
    return false, "Branch name cannot be nil"
  end

  if type(name) ~= "string" then
    return false, "Branch name must be a string"
  end

  -- Check for empty string
  if #name == 0 then
    return false, "Branch name cannot be empty"
  end

  -- Check for leading hyphen
  if name:sub(1, 1) == "-" then
    return false, "Branch name cannot start with a hyphen"
  end

  -- Check for .lock suffix
  if name:match "%.lock$" then
    return false, "Branch name cannot end with .lock"
  end

  -- Check for consecutive dots
  if name:match "%.%." then
    return false, "Branch name cannot contain consecutive dots"
  end

  -- Check for invalid characters
  for _, char in ipairs(INVALID_BRANCH_CHARS) do
    if name:find(char, 1, true) then
      return false, "Branch name contains invalid character"
    end
  end

  -- Check for control characters (ASCII 0-31)
  for i = 1, #name do
    local byte = string.byte(name, i)
    if byte < 32 then
      return false, "Branch name contains control characters"
    end
  end

  return true, nil
end

--- Check if a worktree exists at the given path
--- @param path string|nil The path to check
--- @return boolean exists Whether a worktree exists at the path
function M.exists(path)
  -- Handle nil or empty path
  if path == nil or path == "" then
    return false
  end

  -- Check if directory exists
  if vim.fn.isdirectory(path) == 0 then
    return false
  end

  -- Check if it's a git worktree by looking for .git file or directory
  local git_path = path .. "/.git"
  if vim.fn.filereadable(git_path) == 1 or vim.fn.isdirectory(git_path) == 1 then
    return true
  end

  return false
end

--- List all worktrees in the current repository
--- @return table[] worktrees List of worktree objects with path and branch
function M.list()
  if not is_git_repo() then
    return {}
  end

  local result = vim.fn.system "git worktree list --porcelain 2>/dev/null"
  if vim.v.shell_error ~= 0 then
    return {}
  end

  local worktrees = {}
  local current_worktree = {}

  for line in result:gmatch "[^\r\n]+" do
    if line:match "^worktree " then
      -- Start of a new worktree entry
      if current_worktree.path then
        table.insert(worktrees, current_worktree)
      end
      current_worktree = {
        path = line:match "^worktree (.+)",
        branch = "",
      }
    elseif line:match "^branch " then
      -- Branch name (refs/heads/...)
      local branch_ref = line:match "^branch (.+)"
      if branch_ref then
        -- Strip refs/heads/ prefix if present
        current_worktree.branch = branch_ref:gsub("^refs/heads/", "")
      end
    elseif line:match "^HEAD " then
      -- For detached HEAD, use the commit hash
      if current_worktree.branch == "" then
        current_worktree.branch = line:match "^HEAD (.+)"
      end
    end
  end

  -- Don't forget the last worktree
  if current_worktree.path then
    table.insert(worktrees, current_worktree)
  end

  return worktrees
end

--- Create a new worktree for a branch
--- @param branch_name string The name of the branch
--- @param path string The path where to create the worktree
--- @return table result Result table with success, error, and path fields
function M.create(branch_name, path)
  -- Validate arguments
  if branch_name == nil or path == nil then
    return {
      success = false,
      error = "Branch name and path are required",
      path = nil,
    }
  end

  if type(branch_name) ~= "string" or #branch_name == 0 then
    return {
      success = false,
      error = "Branch name cannot be empty",
      path = nil,
    }
  end

  if type(path) ~= "string" or #path == 0 then
    return {
      success = false,
      error = "Path cannot be empty",
      path = nil,
    }
  end

  -- Validate branch name
  local valid, err = M.validate_branch_name(branch_name)
  if not valid then
    return {
      success = false,
      error = err,
      path = nil,
    }
  end

  -- Check if we're in a git repository
  if not is_git_repo() then
    return {
      success = false,
      error = "Not in a git repository",
      path = nil,
    }
  end

  -- Check if worktree already exists at path
  if M.exists(path) then
    return {
      success = false,
      error = "Worktree already exists at path",
      path = nil,
    }
  end

  -- Check if the branch exists
  local branch_check = vim.fn.system("git show-ref --verify --quiet refs/heads/" .. branch_name .. " 2>/dev/null")
  local branch_exists = vim.v.shell_error == 0

  -- Create the worktree
  local cmd
  if branch_exists then
    -- Use existing branch
    cmd = string.format('git worktree add "%s" "%s" 2>&1', path, branch_name)
  else
    -- Create new branch
    cmd = string.format('git worktree add -b "%s" "%s" 2>&1', branch_name, path)
  end

  local result = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    return {
      success = false,
      error = "Failed to create worktree: " .. result:gsub("\n", " "),
      path = nil,
    }
  end

  return {
    success = true,
    error = nil,
    path = path,
  }
end

--- Remove a worktree
--- @param worktree_path string The path of the worktree to remove
--- @return table result Result table with success and error fields
function M.remove(worktree_path)
  -- Validate argument
  if worktree_path == nil or worktree_path == "" then
    return {
      success = false,
      error = "Worktree path is required",
    }
  end

  -- Check if we're in a git repository
  if not is_git_repo() then
    return {
      success = false,
      error = "Not in a git repository",
    }
  end

  -- Check if the worktree exists
  if not M.exists(worktree_path) then
    return {
      success = false,
      error = "Worktree does not exist at path",
    }
  end

  -- Remove the worktree
  local cmd = string.format('git worktree remove "%s" --force 2>&1', worktree_path)
  local result = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return {
      success = false,
      error = "Failed to remove worktree: " .. result:gsub("\n", " "),
    }
  end

  return {
    success = true,
    error = nil,
  }
end

return M
