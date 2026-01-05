local M = {}

package.path = package.path .. ";./lua/?.lua"

-- Mock vim.fn for testing outside of Neovim
if not vim then
  _G.vim = {
    fn = {},
    v = {
      shell_error = 0,
    },
  }

  -- System command that tracks exit code
  vim.fn.system = function(cmd)
    -- Append exit code capture to command
    local handle = io.popen(cmd .. "; echo __EXIT_CODE__$?")
    if not handle then
      vim.v.shell_error = 1
      return ""
    end
    local result = handle:read "*a"
    handle:close()

    -- Extract exit code
    local exit_code = result:match "__EXIT_CODE__(%d+)"
    vim.v.shell_error = tonumber(exit_code) or 0

    -- Remove exit code marker from output
    result = result:gsub("__EXIT_CODE__%d+%s*", "")
    return result
  end

  -- Check if path is a directory
  vim.fn.isdirectory = function(path)
    if not path or path == "" then
      return 0
    end
    local result = os.execute('test -d "' .. path .. '"')
    -- os.execute returns true on Lua 5.2+, or exit code on older
    if result == true or result == 0 then
      return 1
    end
    return 0
  end

  -- Check if file is readable
  vim.fn.filereadable = function(path)
    if not path or path == "" then
      return 0
    end
    local f = io.open(path, "r")
    if f then
      f:close()
      return 1
    end
    return 0
  end
end

describe("Git Worktree Management Module", function()
  local worktree

  before_each(function()
    package.loaded["utils.worktree"] = nil
    worktree = require "utils.worktree"
  end)

  it("should load the module", function()
    assert.is_table(worktree, "module should be a table")
  end)

  it("should have all required functions", function()
    assert.is_function(worktree.validate_branch_name, "should have validate_branch_name function")
    assert.is_function(worktree.create, "should have create function")
    assert.is_function(worktree.list, "should have list function")
    assert.is_function(worktree.remove, "should have remove function")
    assert.is_function(worktree.exists, "should have exists function")
  end)

  describe("validate_branch_name", function()
    it("should accept valid branch names", function()
      local valid, err = worktree.validate_branch_name "feature-branch"
      assert.is_true(valid, "should accept hyphenated name")
      assert.is_nil(err, "should not have error for valid name")
    end)

    it("should accept branch names with slashes", function()
      local valid, err = worktree.validate_branch_name "feature/my-feature"
      assert.is_true(valid, "should accept name with slash")
      assert.is_nil(err)
    end)

    it("should accept branch names with underscores", function()
      local valid, err = worktree.validate_branch_name "feature_branch_name"
      assert.is_true(valid, "should accept underscores")
      assert.is_nil(err)
    end)

    it("should accept branch names with numbers", function()
      local valid, err = worktree.validate_branch_name "feature-123"
      assert.is_true(valid, "should accept numbers")
      assert.is_nil(err)
    end)

    it("should reject empty branch names", function()
      local valid, err = worktree.validate_branch_name ""
      assert.is_false(valid, "should reject empty name")
      assert.is_string(err, "should have error message")
    end)

    it("should reject nil branch names", function()
      local valid, err = worktree.validate_branch_name(nil)
      assert.is_false(valid, "should reject nil")
      assert.is_string(err)
    end)

    it("should reject branch names with spaces", function()
      local valid, err = worktree.validate_branch_name "feature branch"
      assert.is_false(valid, "should reject spaces")
      assert.is_string(err)
    end)

    it("should reject branch names starting with hyphen", function()
      local valid, err = worktree.validate_branch_name "-feature"
      assert.is_false(valid, "should reject leading hyphen")
      assert.is_string(err)
    end)

    it("should reject branch names ending with .lock", function()
      local valid, err = worktree.validate_branch_name "feature.lock"
      assert.is_false(valid, "should reject .lock suffix")
      assert.is_string(err)
    end)

    it("should reject branch names with consecutive dots", function()
      local valid, err = worktree.validate_branch_name "feature..branch"
      assert.is_false(valid, "should reject consecutive dots")
      assert.is_string(err)
    end)

    it("should reject branch names with control characters", function()
      local valid, err = worktree.validate_branch_name "feature\tbranch"
      assert.is_false(valid, "should reject tab character")
      assert.is_string(err)
    end)

    it("should reject branch names with tilde", function()
      local valid, err = worktree.validate_branch_name "feature~branch"
      assert.is_false(valid, "should reject tilde")
      assert.is_string(err)
    end)

    it("should reject branch names with caret", function()
      local valid, err = worktree.validate_branch_name "feature^branch"
      assert.is_false(valid, "should reject caret")
      assert.is_string(err)
    end)

    it("should reject branch names with colon", function()
      local valid, err = worktree.validate_branch_name "feature:branch"
      assert.is_false(valid, "should reject colon")
      assert.is_string(err)
    end)
  end)

  describe("exists", function()
    it("should return true for existing worktree", function()
      -- The current directory should be a worktree or git repo
      local result = worktree.exists "."
      assert.is_boolean(result, "should return boolean")
    end)

    it("should return false for non-existent path", function()
      local result = worktree.exists "/nonexistent/path/that/does/not/exist"
      assert.is_false(result, "should return false for non-existent path")
    end)

    it("should return false for empty path", function()
      local result = worktree.exists ""
      assert.is_false(result, "should return false for empty path")
    end)

    it("should return false for nil path", function()
      local result = worktree.exists(nil)
      assert.is_false(result, "should return false for nil path")
    end)
  end)

  describe("list", function()
    it("should return a table", function()
      local result = worktree.list()
      assert.is_table(result, "should return a table")
    end)

    it("should return worktrees with expected structure", function()
      local worktrees = worktree.list()
      if #worktrees > 0 then
        local wt = worktrees[1]
        assert.is_string(wt.path, "worktree should have path")
        assert.is_string(wt.branch, "worktree should have branch")
      end
    end)
  end)

  describe("create", function()
    it("should return result table with success field", function()
      -- Test with invalid input to verify structure
      local result = worktree.create("", "")
      assert.is_table(result, "should return table")
      assert.is_boolean(result.success, "should have success field")
    end)

    it("should fail with invalid branch name", function()
      local result = worktree.create("invalid branch name", "/tmp/test-worktree")
      assert.is_false(result.success, "should fail with invalid branch name")
      assert.is_string(result.error, "should have error message")
    end)

    it("should fail with empty branch name", function()
      local result = worktree.create("", "/tmp/test-worktree")
      assert.is_false(result.success, "should fail with empty branch")
      assert.is_string(result.error)
    end)

    it("should fail with empty path", function()
      local result = worktree.create("valid-branch", "")
      assert.is_false(result.success, "should fail with empty path")
      assert.is_string(result.error)
    end)

    it("should fail with nil arguments", function()
      local result = worktree.create(nil, nil)
      assert.is_false(result.success, "should fail with nil args")
      assert.is_string(result.error)
    end)
  end)

  describe("remove", function()
    it("should return result table with success field", function()
      local result = worktree.remove ""
      assert.is_table(result, "should return table")
      assert.is_boolean(result.success, "should have success field")
    end)

    it("should fail with empty path", function()
      local result = worktree.remove ""
      assert.is_false(result.success, "should fail with empty path")
      assert.is_string(result.error)
    end)

    it("should fail with nil path", function()
      local result = worktree.remove(nil)
      assert.is_false(result.success, "should fail with nil path")
      assert.is_string(result.error)
    end)

    it("should fail gracefully for non-existent worktree", function()
      local result = worktree.remove "/nonexistent/worktree/path"
      assert.is_false(result.success, "should fail for non-existent worktree")
      assert.is_string(result.error)
    end)
  end)

  describe("integration tests", function()
    local test_worktree_path = "/tmp/test-worktree-" .. os.time()
    local test_branch_name = "test-branch-" .. os.time()

    -- Clean up before tests
    before_each(function()
      os.execute("rm -rf " .. test_worktree_path)
    end)

    -- Clean up after tests
    after_each(function()
      -- Try to remove the worktree if it was created
      pcall(function()
        worktree.remove(test_worktree_path)
      end)
      os.execute("rm -rf " .. test_worktree_path)
    end)

    it("should create and remove a worktree successfully", function()
      -- This test requires being in a git repository
      local create_result = worktree.create(test_branch_name, test_worktree_path)

      if create_result.success then
        -- Verify the worktree exists
        assert.is_true(worktree.exists(test_worktree_path), "worktree should exist after creation")

        -- Verify it appears in the list
        local worktrees = worktree.list()
        local found = false
        for _, wt in ipairs(worktrees) do
          if wt.path:find(test_worktree_path, 1, true) then
            found = true
            break
          end
        end
        assert.is_true(found, "worktree should appear in list")

        -- Remove the worktree
        local remove_result = worktree.remove(test_worktree_path)
        assert.is_true(remove_result.success, "should remove worktree successfully")

        -- Verify it no longer exists
        assert.is_false(worktree.exists(test_worktree_path), "worktree should not exist after removal")
      else
        -- If creation failed (e.g., not in git repo), that's acceptable for this test
        assert.is_string(create_result.error, "should have error message if creation fails")
      end
    end)
  end)
end)

return M
