local M = {}

local data_path = vim.fn.stdpath "data" .. "/project_last_files.json"

local function read_data()
  local file = io.open(data_path, "r")
  if not file then
    return {}
  end
  local content = file:read "*a"
  file:close()
  if content == "" then
    return {}
  end
  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok then
    return {}
  end
  return data or {}
end

local function write_data(data)
  local file = io.open(data_path, "w")
  if not file then
    return false
  end
  local ok, json = pcall(vim.fn.json_encode, data)
  if not ok then
    file:close()
    return false
  end
  file:write(json)
  file:close()
  return true
end

function M.get_project_root()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  if vim.v.shell_error == 0 and git_root and git_root ~= "" then
    return git_root
  end
  return nil
end

function M.is_restorable_file(filepath)
  if not filepath or filepath == "" then
    return false
  end
  local non_restorable_patterns = {
    "^term://",
    "^oil://",
    "^fugitive://",
    "^gitsigns://",
    "^NvimTree",
    "^neo%-tree",
    "^Trouble",
    "^qf$",
    "^help$",
  }
  for _, pattern in ipairs(non_restorable_patterns) do
    if filepath:match(pattern) then
      return false
    end
  end
  return true
end

function M.save_last_file(project_root, filepath)
  if not project_root or not filepath then
    return false
  end
  if not M.is_restorable_file(filepath) then
    return false
  end
  local data = read_data()
  data[project_root] = filepath
  return write_data(data)
end

function M.get_last_file(project_root)
  if not project_root then
    return nil
  end
  local data = read_data()
  return data[project_root]
end

function M.restore_last_file()
  local argc = vim.fn.argc()
  if argc > 0 then
    return false
  end

  local project_root = M.get_project_root()
  if not project_root then
    return false
  end

  local last_file = M.get_last_file(project_root)
  if not last_file then
    return false
  end

  if vim.fn.filereadable(last_file) == 0 then
    return false
  end

  vim.schedule(function()
    vim.cmd.edit(last_file)
  end)
  return true
end

function M.track_current_file()
  local project_root = M.get_project_root()
  if not project_root then
    return
  end

  local filepath = vim.fn.expand "%:p"
  M.save_last_file(project_root, filepath)
end

function M.setup()
  local augroup = vim.api.nvim_create_augroup("ProjectLastFile", { clear = true })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    callback = function()
      M.track_current_file()
    end,
    desc = "Track last opened file per project",
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup,
    callback = function()
      vim.schedule(function()
        M.restore_last_file()
      end)
    end,
    desc = "Restore last file on startup",
  })
end

return M
