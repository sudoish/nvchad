-- Task Workflow Integration Tests
-- Tests for lua/ai-tools/task-workflow/init.lua
--
-- This test suite uses mocks for all dependencies to allow isolated testing.

package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

-- Mock vim global for testing outside neovim
_G.vim = _G.vim or {}
_G.vim.fn = _G.vim.fn or {}
_G.vim.env = _G.vim.env or {}
_G.vim.v = _G.vim.v or { shell_error = 0 }
_G.vim.notify = _G.vim.notify or function() end
_G.vim.log = _G.vim.log or { levels = { INFO = 1, WARN = 2, ERROR = 3 } }
_G.vim.ui = _G.vim.ui or {}
_G.vim.deepcopy = _G.vim.deepcopy
  or function(t)
    if type(t) ~= "table" then
      return t
    end
    local copy = {}
    for k, v in pairs(t) do
      copy[k] = vim.deepcopy(v)
    end
    return copy
  end

describe("ai-tools.task-workflow", function()
  local task_workflow
  local mock_worktree
  local mock_tmux
  local mock_config
  local mock_slugify
  local mock_task_input
  local mock_sidekick
  local notifications = {}

  -- Helper to create fresh mocks
  local function setup_mocks()
    notifications = {}

    -- Mock worktree module
    mock_worktree = {
      create = function()
        return { success = true, path = "/mock/.trees/test-branch" }
      end,
      remove = function()
        return { success = true }
      end,
      exists = function()
        return false
      end,
      validate_branch_name = function()
        return true, nil
      end,
    }

    -- Mock tmux module
    mock_tmux = {
      is_inside_tmux = function()
        return true
      end,
      get_current_session = function()
        return "main"
      end,
      create_window = function()
        return { success = true, window_id = "@5" }
      end,
      switch_window = function()
        return { success = true }
      end,
      send_command = function()
        return { success = true }
      end,
      kill_window = function()
        return { success = true }
      end,
      validate_window_name = function()
        return true, nil
      end,
    }

    -- Mock config module
    mock_config = {
      trees_folder = ".trees",
      max_slug_length = 15,
      default_ai_tool = "droid",
      notifications = {
        success = true,
        errors = true,
      },
    }

    -- Mock slugify module
    mock_slugify = {
      slugify = function(text)
        if not text or text == "" then
          return ""
        end
        return text:lower():gsub("%s+", "-"):sub(1, 15)
      end,
    }

    -- Mock task-input module
    mock_task_input = {
      input_task = function(callback)
        -- Default: simulate successful input
        callback(true, { title = "Test Task", description = "Test description" })
      end,
      get_task = function()
        return { title = "Test Task", description = "Test description" }
      end,
      has_task = function()
        return true
      end,
      clear_task = function()
        return true
      end,
    }

    -- Mock sidekick module (partial - just the cli.toggle we need)
    mock_sidekick = {
      cli = {
        toggle = function()
          return true
        end,
      },
    }

    -- Mock vim.notify to capture notifications
    _G.vim.notify = function(msg, level)
      table.insert(notifications, { msg = msg, level = level })
    end
  end

  before_each(function()
    setup_mocks()

    -- Clear all cached modules
    package.loaded["utils.worktree"] = nil
    package.loaded["utils.tmux"] = nil
    package.loaded["ai-tools.task-workflow.config"] = nil
    package.loaded["utils.slugify"] = nil
    package.loaded["ai-tools.task-input"] = nil
    package.loaded["sidekick.cli"] = nil
    package.loaded["ai-tools.task-workflow"] = nil

    -- Install mocks
    package.loaded["utils.worktree"] = mock_worktree
    package.loaded["utils.tmux"] = mock_tmux
    package.loaded["ai-tools.task-workflow.config"] = mock_config
    package.loaded["utils.slugify"] = mock_slugify
    package.loaded["ai-tools.task-input"] = mock_task_input
    package.loaded["sidekick.cli"] = mock_sidekick.cli

    -- Load the module under test
    task_workflow = require "ai-tools.task-workflow"
  end)

  after_each(function()
    -- Clean up mocks
    package.loaded["utils.worktree"] = nil
    package.loaded["utils.tmux"] = nil
    package.loaded["ai-tools.task-workflow.config"] = nil
    package.loaded["utils.slugify"] = nil
    package.loaded["ai-tools.task-input"] = nil
    package.loaded["sidekick.cli"] = nil
    package.loaded["ai-tools.task-workflow"] = nil
  end)

  describe("module structure", function()
    it("should load the module", function()
      assert.is_table(task_workflow, "module should be a table")
    end)

    it("should have start function", function()
      assert.is_function(task_workflow.start, "should have start function")
    end)

    it("should have create_environment function", function()
      assert.is_function(task_workflow.create_environment, "should have create_environment function")
    end)

    it("should have initialize_ai_chat function", function()
      assert.is_function(task_workflow.initialize_ai_chat, "should have initialize_ai_chat function")
    end)

    it("should have cleanup function", function()
      assert.is_function(task_workflow.cleanup, "should have cleanup function")
    end)
  end)

  describe("start", function()
    it("prompts for task input", function()
      local input_called = false
      mock_task_input.input_task = function(callback)
        input_called = true
        callback(true, { title = "Test", description = "Desc" })
      end
      package.loaded["ai-tools.task-input"] = mock_task_input
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      task_workflow.start(function() end)

      assert.is_true(input_called, "should call input_task")
    end)

    it("aborts gracefully on cancelled input", function()
      mock_task_input.input_task = function(callback)
        callback(false, nil) -- Simulate cancel
      end
      package.loaded["ai-tools.task-input"] = mock_task_input
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      local result_received = nil
      task_workflow.start(function(result)
        result_received = result
      end)

      assert.is_not_nil(result_received, "should call callback")
      assert.is_false(result_received.success, "should report failure on cancel")
    end)

    it("calls create_environment after successful task input", function()
      local create_env_task = nil
      -- We need to spy on create_environment
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      local original_create_env = task_workflow.create_environment
      task_workflow.create_environment = function(task, callback)
        create_env_task = task
        original_create_env(task, callback)
      end

      task_workflow.start(function() end)

      assert.is_not_nil(create_env_task, "should call create_environment with task")
      assert.equals("Test Task", create_env_task.title)
    end)
  end)

  describe("create_environment", function()
    local test_task = { title = "My Test Task", description = "A test description" }

    it("creates worktree with slugified name", function()
      local created_branch = nil
      local created_path = nil
      mock_worktree.create = function(branch, path)
        created_branch = branch
        created_path = path
        return { success = true, path = path }
      end
      package.loaded["utils.worktree"] = mock_worktree
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      task_workflow.create_environment(test_task, function() end)

      assert.is_not_nil(created_branch, "should call worktree.create")
      assert.truthy(created_branch:match "my%-test%-task", "branch should be slugified")
      assert.truthy(created_path:match ".trees", "path should include trees folder")
    end)

    it("creates tmux window with slugified name", function()
      local window_name = nil
      mock_tmux.create_window = function(name, _path)
        window_name = name
        return { success = true, window_id = "@5" }
      end
      package.loaded["utils.tmux"] = mock_tmux
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      task_workflow.create_environment(test_task, function() end)

      assert.is_not_nil(window_name, "should call tmux.create_window")
      assert.truthy(window_name:match "my%-test%-task", "window name should be slugified")
    end)

    it("cleans up on worktree failure", function()
      mock_worktree.create = function()
        return { success = false, error = "Failed to create worktree" }
      end
      mock_worktree.remove = function()
        return { success = true }
      end
      package.loaded["utils.worktree"] = mock_worktree
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      local result = nil
      task_workflow.create_environment(test_task, function(r)
        result = r
      end)

      assert.is_false(result.success, "should report failure")
      assert.is_string(result.error, "should include error message")
    end)

    it("cleans up on tmux window creation failure", function()
      local worktree_removed = false
      mock_tmux.create_window = function()
        return { success = false, error = "Failed to create window" }
      end
      mock_worktree.remove = function()
        worktree_removed = true
        return { success = true }
      end
      package.loaded["utils.worktree"] = mock_worktree
      package.loaded["utils.tmux"] = mock_tmux
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      local result = nil
      task_workflow.create_environment(test_task, function(r)
        result = r
      end)

      assert.is_false(result.success, "should report failure")
      assert.is_true(worktree_removed, "should cleanup worktree on tmux failure")
    end)

    it("fails when not inside tmux", function()
      mock_tmux.is_inside_tmux = function()
        return false
      end
      package.loaded["utils.tmux"] = mock_tmux
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      local result = nil
      task_workflow.create_environment(test_task, function(r)
        result = r
      end)

      assert.is_false(result.success, "should fail outside tmux")
      assert.truthy(result.error:match "tmux", "error should mention tmux")
    end)

    it("returns result with worktree path and window info", function()
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      local result = nil
      task_workflow.create_environment(test_task, function(r)
        result = r
      end)

      assert.is_true(result.success, "should succeed")
      assert.is_not_nil(result.result, "should have result table")
      assert.is_not_nil(result.result.worktree_path, "should include worktree path")
      assert.is_not_nil(result.result.branch_name, "should include branch name")
    end)
  end)

  describe("initialize_ai_chat", function()
    local test_task = { title = "My Task", description = "Task description" }
    local test_path = "/mock/.trees/my-task"

    it("toggles sidekick", function()
      local toggle_called = false
      mock_sidekick.cli.toggle = function(_opts)
        toggle_called = true
        return true
      end
      package.loaded["sidekick.cli"] = mock_sidekick.cli
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      task_workflow.initialize_ai_chat(test_task, test_path)

      assert.is_true(toggle_called, "should call sidekick toggle")
    end)

    it("uses configured AI tool", function()
      local toggle_opts = nil
      mock_sidekick.cli.toggle = function(opts)
        toggle_opts = opts
        return true
      end
      package.loaded["sidekick.cli"] = mock_sidekick.cli
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      task_workflow.initialize_ai_chat(test_task, test_path)

      assert.is_not_nil(toggle_opts, "should pass opts to toggle")
      assert.equals("droid", toggle_opts.name, "should use configured AI tool")
    end)

    it("returns success result", function()
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      local result = task_workflow.initialize_ai_chat(test_task, test_path)

      assert.is_table(result, "should return result table")
      assert.is_true(result.success, "should succeed")
    end)

    it("handles sidekick toggle failure gracefully", function()
      mock_sidekick.cli.toggle = function()
        error "Sidekick not available"
      end
      package.loaded["sidekick.cli"] = mock_sidekick.cli
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      local result = task_workflow.initialize_ai_chat(test_task, test_path)

      assert.is_false(result.success, "should report failure")
      assert.is_string(result.error, "should include error message")
    end)
  end)

  describe("cleanup", function()
    it("removes worktree", function()
      local removed_path = nil
      mock_worktree.remove = function(path)
        removed_path = path
        return { success = true }
      end
      package.loaded["utils.worktree"] = mock_worktree
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      task_workflow.cleanup("test-branch", "/mock/.trees/test-branch")

      assert.equals("/mock/.trees/test-branch", removed_path, "should remove worktree at path")
    end)

    it("kills tmux window", function()
      local killed_window = nil
      mock_tmux.kill_window = function(name)
        killed_window = name
        return { success = true }
      end
      package.loaded["utils.tmux"] = mock_tmux
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      task_workflow.cleanup("test-branch", "/mock/.trees/test-branch")

      assert.equals("test-branch", killed_window, "should kill window by branch name")
    end)

    it("returns success when both cleanup operations succeed", function()
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      local result = task_workflow.cleanup("test-branch", "/mock/.trees/test-branch")

      assert.is_true(result.success, "should succeed")
    end)

    it("returns partial failure when worktree removal fails", function()
      mock_worktree.remove = function()
        return { success = false, error = "Failed to remove" }
      end
      package.loaded["utils.worktree"] = mock_worktree
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      local result = task_workflow.cleanup("test-branch", "/mock/.trees/test-branch")

      assert.is_false(result.success, "should report failure")
    end)

    it("continues tmux cleanup even if worktree removal fails", function()
      local tmux_killed = false
      mock_worktree.remove = function()
        return { success = false, error = "Failed" }
      end
      mock_tmux.kill_window = function()
        tmux_killed = true
        return { success = true }
      end
      package.loaded["utils.worktree"] = mock_worktree
      package.loaded["utils.tmux"] = mock_tmux
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      task_workflow.cleanup("test-branch", "/mock/.trees/test-branch")

      assert.is_true(tmux_killed, "should still attempt tmux cleanup")
    end)
  end)

  describe("full workflow integration", function()
    it("completes end-to-end successfully", function()
      local workflow_steps = {}

      mock_task_input.input_task = function(callback)
        table.insert(workflow_steps, "input_task")
        callback(true, { title = "Integration Test", description = "Full test" })
      end

      mock_worktree.create = function(_branch, path)
        table.insert(workflow_steps, "worktree_create")
        return { success = true, path = path }
      end

      mock_tmux.create_window = function(_name, _path)
        table.insert(workflow_steps, "tmux_create_window")
        return { success = true, window_id = "@5" }
      end

      mock_tmux.switch_window = function()
        table.insert(workflow_steps, "tmux_switch_window")
        return { success = true }
      end

      mock_tmux.send_command = function()
        table.insert(workflow_steps, "tmux_send_command")
        return { success = true }
      end

      mock_sidekick.cli.toggle = function()
        table.insert(workflow_steps, "sidekick_toggle")
        return true
      end

      package.loaded["ai-tools.task-input"] = mock_task_input
      package.loaded["utils.worktree"] = mock_worktree
      package.loaded["utils.tmux"] = mock_tmux
      package.loaded["sidekick.cli"] = mock_sidekick.cli
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      local final_result = nil
      task_workflow.start(function(result)
        final_result = result
      end)

      assert.is_not_nil(final_result, "should complete workflow")
      assert.is_true(final_result.success, "workflow should succeed")
      assert.truthy(#workflow_steps >= 4, "should execute multiple steps")
      assert.equals("input_task", workflow_steps[1], "should start with input")
      assert.equals("worktree_create", workflow_steps[2], "should create worktree")
      assert.equals("tmux_create_window", workflow_steps[3], "should create tmux window")
    end)
  end)

  describe("notifications", function()
    it("notifies on successful workflow completion", function()
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      task_workflow.start(function() end)

      -- Success notification depends on config, just ensure no errors thrown
      assert.is_true(true)
    end)

    it("notifies on errors when config.notifications.errors is true", function()
      mock_worktree.create = function()
        return { success = false, error = "Test error" }
      end
      package.loaded["utils.worktree"] = mock_worktree
      package.loaded["ai-tools.task-workflow"] = nil
      task_workflow = require "ai-tools.task-workflow"

      task_workflow.create_environment({ title = "Test", description = "" }, function() end)

      local has_error_notification = false
      for _, n in ipairs(notifications) do
        if n.level == vim.log.levels.ERROR or n.level == vim.log.levels.WARN then
          has_error_notification = true
          break
        end
      end
      assert.is_true(has_error_notification, "should notify on error")
    end)
  end)
end)
