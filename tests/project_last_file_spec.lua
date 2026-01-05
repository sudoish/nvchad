local M = {}

-- Add lua directory to path for standalone testing
package.path = package.path .. ";./lua/?.lua"

-- Mock vim globals for standalone testing outside neovim
-- Must be set before requiring the module
_G.vim = _G.vim
  or {
    fn = {
      stdpath = function(what)
        if what == "data" then
          return "/tmp/nvim-test-data"
        end
        return ""
      end,
      systemlist = function()
        return { "/tmp/test-project" }
      end,
      argc = function()
        return 0
      end,
      expand = function()
        return ""
      end,
      filereadable = function()
        return 1
      end,
      json_encode = function(data)
        local result = "{"
        local first = true
        for k, v in pairs(data) do
          if not first then
            result = result .. ","
          end
          result = result .. '"' .. k .. '":"' .. v .. '"'
          first = false
        end
        return result .. "}"
      end,
      json_decode = function(str)
        local result = {}
        for k, v in str:gmatch '"([^"]+)":"([^"]+)"' do
          result[k] = v
        end
        return result
      end,
    },
    v = {
      shell_error = 0,
    },
    cmd = {
      edit = function() end,
    },
    api = {
      nvim_create_augroup = function()
        return 1
      end,
      nvim_create_autocmd = function() end,
    },
    schedule = function(fn)
      fn()
    end,
  }

describe("Project Last File", function()
  local project_last_file

  before_each(function()
    package.loaded["project-last-file"] = nil
    project_last_file = require "project-last-file"
  end)

  it("should load the module", function()
    assert.is_table(project_last_file, "module should be a table")
  end)

  it("should have get_project_root function", function()
    assert.is_function(project_last_file.get_project_root, "should have get_project_root function")
  end)

  it("should have save_last_file function", function()
    assert.is_function(project_last_file.save_last_file, "should have save_last_file function")
  end)

  it("should have get_last_file function", function()
    assert.is_function(project_last_file.get_last_file, "should have get_last_file function")
  end)

  it("should have restore_last_file function", function()
    assert.is_function(project_last_file.restore_last_file, "should have restore_last_file function")
  end)

  describe("get_project_root", function()
    it("should return a string for git projects", function()
      local root = project_last_file.get_project_root()
      if root then
        assert.is_string(root, "project root should be a string")
      end
    end)
  end)

  describe("save and get last file", function()
    it("should save and retrieve a file path", function()
      local test_project = "/tmp/test-project"
      local test_file = "/tmp/test-project/test.lua"

      project_last_file.save_last_file(test_project, test_file)
      local retrieved = project_last_file.get_last_file(test_project)

      assert.equals(test_file, retrieved, "should retrieve the saved file path")
    end)

    it("should return nil for unknown projects", function()
      local result = project_last_file.get_last_file "/nonexistent/project/path"
      assert.is_nil(result, "should return nil for unknown projects")
    end)
  end)

  describe("is_restorable_file", function()
    it("should have is_restorable_file function", function()
      assert.is_function(project_last_file.is_restorable_file, "should have is_restorable_file function")
    end)

    it("should return false for special buffers", function()
      assert.is_false(project_last_file.is_restorable_file "", "empty path should not be restorable")
      assert.is_false(project_last_file.is_restorable_file "term://", "terminal should not be restorable")
      assert.is_false(project_last_file.is_restorable_file "oil://", "oil should not be restorable")
    end)

    it("should return true for regular files", function()
      assert.is_true(project_last_file.is_restorable_file "/path/to/file.lua", "lua file should be restorable")
    end)
  end)
end)

return M
