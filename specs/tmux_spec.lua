local M = {}

package.path = package.path .. ";./lua/?.lua"

-- Mock vim global for testing outside neovim
_G.vim = _G.vim or {}
_G.vim.fn = _G.vim.fn or {}
_G.vim.env = _G.vim.env or {}
_G.vim.v = _G.vim.v or { shell_error = 0 }

describe("Tmux Window Management Module", function()
  local tmux
  local original_vim_fn_system
  local original_vim_env
  local original_vim_v

  before_each(function()
    -- Store original vim globals
    original_vim_fn_system = vim.fn.system
    original_vim_env = vim.env
    original_vim_v = vim.v

    -- Reset vim.env to a fresh table for each test
    vim.env = {}
    -- Reset vim.v with default shell_error of 0 (success)
    vim.v = { shell_error = 0 }

    -- Clear the module cache to get fresh instance
    package.loaded["utils.tmux"] = nil
    tmux = require "utils.tmux"
  end)

  after_each(function()
    -- Restore original vim globals
    vim.fn.system = original_vim_fn_system
    vim.env = original_vim_env
    vim.v = original_vim_v
  end)

  describe("module structure", function()
    it("should load the module", function()
      assert.is_table(tmux, "module should be a table")
    end)

    it("should have is_inside_tmux function", function()
      assert.is_function(tmux.is_inside_tmux, "should have is_inside_tmux function")
    end)

    it("should have validate_window_name function", function()
      assert.is_function(tmux.validate_window_name, "should have validate_window_name function")
    end)

    it("should have get_current_session function", function()
      assert.is_function(tmux.get_current_session, "should have get_current_session function")
    end)

    it("should have create_window function", function()
      assert.is_function(tmux.create_window, "should have create_window function")
    end)

    it("should have switch_window function", function()
      assert.is_function(tmux.switch_window, "should have switch_window function")
    end)

    it("should have send_command function", function()
      assert.is_function(tmux.send_command, "should have send_command function")
    end)

    it("should have kill_window function", function()
      assert.is_function(tmux.kill_window, "should have kill_window function")
    end)
  end)

  describe("is_inside_tmux", function()
    it("should return true when TMUX env var is set", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      -- Reload module to pick up new env
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"
      local result = tmux.is_inside_tmux()
      assert.is_true(result, "should return true when TMUX is set")
    end)

    it("should return false when TMUX env var is not set", function()
      vim.env.TMUX = nil
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"
      local result = tmux.is_inside_tmux()
      assert.is_false(result, "should return false when TMUX is not set")
    end)

    it("should return false when TMUX env var is empty string", function()
      vim.env.TMUX = ""
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"
      local result = tmux.is_inside_tmux()
      assert.is_false(result, "should return false when TMUX is empty")
    end)
  end)

  describe("validate_window_name", function()
    it("should accept valid alphanumeric names", function()
      local valid, err = tmux.validate_window_name "mywindow"
      assert.is_true(valid, "should accept alphanumeric name")
      assert.is_nil(err, "should have no error for valid name")
    end)

    it("should accept names with hyphens", function()
      local valid, err = tmux.validate_window_name "my-window"
      assert.is_true(valid, "should accept name with hyphens")
      assert.is_nil(err)
    end)

    it("should accept names with underscores", function()
      local valid, err = tmux.validate_window_name "my_window"
      assert.is_true(valid, "should accept name with underscores")
      assert.is_nil(err)
    end)

    it("should accept names with numbers", function()
      local valid, err = tmux.validate_window_name "window123"
      assert.is_true(valid, "should accept name with numbers")
      assert.is_nil(err)
    end)

    it("should reject empty string", function()
      local valid, err = tmux.validate_window_name ""
      assert.is_false(valid, "should reject empty string")
      assert.is_string(err, "should return error message")
      assert.truthy(err:match "empty", "error should mention empty")
    end)

    it("should reject nil", function()
      local valid, err = tmux.validate_window_name(nil)
      assert.is_false(valid, "should reject nil")
      assert.is_string(err, "should return error message")
    end)

    it("should reject names with spaces", function()
      local valid, err = tmux.validate_window_name "my window"
      assert.is_false(valid, "should reject name with spaces")
      assert.is_string(err, "should return error message")
    end)

    it("should reject names with special characters", function()
      local valid, err = tmux.validate_window_name "my@window!"
      assert.is_false(valid, "should reject name with special chars")
      assert.is_string(err, "should return error message")
    end)

    it("should reject names starting with hyphen", function()
      local valid, err = tmux.validate_window_name "-mywindow"
      assert.is_false(valid, "should reject name starting with hyphen")
      assert.is_string(err, "should return error message")
    end)
  end)

  describe("get_current_session", function()
    it("should return session name when inside tmux", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      vim.fn.system = function(cmd)
        if cmd:match "display%-message" and cmd:match "#S" then
          return "mysession\n"
        end
        return ""
      end
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local session = tmux.get_current_session()
      assert.equals("mysession", session, "should return session name")
    end)

    it("should return nil when not inside tmux", function()
      vim.env.TMUX = nil
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local session = tmux.get_current_session()
      assert.is_nil(session, "should return nil when not in tmux")
    end)

    it("should trim whitespace from session name", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      vim.fn.system = function(cmd)
        if cmd:match "display%-message" then
          return "  mysession  \n"
        end
        return ""
      end
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local session = tmux.get_current_session()
      assert.equals("mysession", session, "should trim whitespace")
    end)
  end)

  describe("create_window", function()
    it("should succeed with valid name and path inside tmux", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      vim.fn.system = function(cmd)
        if cmd:match "new%-window" then
          return ""
        end
        if cmd:match "display%-message" and cmd:match "#I" then
          return "@5\n"
        end
        return ""
      end
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.create_window("test-window", "/tmp")
      assert.is_true(result.success, "should succeed")
      assert.is_string(result.window_id, "should return window_id")
      assert.is_nil(result.error, "should have no error")
    end)

    it("should fail when not inside tmux", function()
      vim.env.TMUX = nil
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.create_window("test-window", "/tmp")
      assert.is_false(result.success, "should fail")
      assert.is_nil(result.window_id, "should have no window_id")
      assert.is_string(result.error, "should return error message")
      assert.truthy(result.error:match "tmux", "error should mention tmux")
    end)

    it("should fail with invalid window name", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.create_window("", "/tmp")
      assert.is_false(result.success, "should fail with empty name")
      assert.is_string(result.error, "should return error message")
    end)

    it("should fail with invalid path", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.create_window("test-window", nil)
      assert.is_false(result.success, "should fail with nil path")
      assert.is_string(result.error, "should return error message")
    end)

    it("should include window name in tmux command", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      local captured_cmd = nil
      vim.fn.system = function(cmd)
        if cmd:match "new%-window" then
          captured_cmd = cmd
          return ""
        end
        if cmd:match "display%-message" then
          return "@5\n"
        end
        return ""
      end
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      tmux.create_window("my-task-window", "/tmp")
      assert.truthy(captured_cmd:match "my%-task%-window", "should include window name in command")
    end)

    it("should include path in tmux command", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      local captured_cmd = nil
      vim.fn.system = function(cmd)
        if cmd:match "new%-window" then
          captured_cmd = cmd
          return ""
        end
        if cmd:match "display%-message" then
          return "@5\n"
        end
        return ""
      end
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      tmux.create_window("test-window", "/home/user/project")
      assert.truthy(captured_cmd:match "/home/user/project", "should include path in command")
    end)
  end)

  describe("switch_window", function()
    it("should succeed for existing window inside tmux", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      vim.fn.system = function(cmd)
        if cmd:match "select%-window" then
          return ""
        end
        if cmd:match "list%-windows" then
          return "0: bash*\n1: test-window\n"
        end
        return ""
      end
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.switch_window "test-window"
      assert.is_true(result.success, "should succeed")
      assert.is_nil(result.error, "should have no error")
    end)

    it("should fail when not inside tmux", function()
      vim.env.TMUX = nil
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.switch_window "test-window"
      assert.is_false(result.success, "should fail")
      assert.is_string(result.error, "should return error message")
    end)

    it("should fail for non-existent window", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      vim.fn.system = function(cmd)
        if cmd:match "select%-window" then
          return "can't find window: nonexistent"
        end
        return ""
      end
      -- Simulate vim.v.shell_error being non-zero
      vim.v = vim.v or {}
      vim.v.shell_error = 1
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.switch_window "nonexistent"
      assert.is_false(result.success, "should fail for non-existent window")
      assert.is_string(result.error, "should return error message")

      vim.v.shell_error = 0
    end)

    it("should fail with invalid window name", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.switch_window ""
      assert.is_false(result.success, "should fail with empty name")
      assert.is_string(result.error, "should return error message")
    end)
  end)

  describe("send_command", function()
    it("should succeed delivering command to target window", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      local captured_cmd = nil
      vim.fn.system = function(cmd)
        if cmd:match "send%-keys" then
          captured_cmd = cmd
          return ""
        end
        return ""
      end
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.send_command("test-window", "echo hello")
      assert.is_true(result.success, "should succeed")
      assert.is_nil(result.error, "should have no error")
      assert.truthy(captured_cmd, "should have called tmux command")
    end)

    it("should fail when not inside tmux", function()
      vim.env.TMUX = nil
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.send_command("test-window", "echo hello")
      assert.is_false(result.success, "should fail")
      assert.is_string(result.error, "should return error message")
    end)

    it("should fail with invalid window name", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.send_command("", "echo hello")
      assert.is_false(result.success, "should fail with empty window name")
      assert.is_string(result.error, "should return error message")
    end)

    it("should fail with empty command", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.send_command("test-window", "")
      assert.is_false(result.success, "should fail with empty command")
      assert.is_string(result.error, "should return error message")
    end)

    it("should fail with nil command", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.send_command("test-window", nil)
      assert.is_false(result.success, "should fail with nil command")
      assert.is_string(result.error, "should return error message")
    end)

    it("should include window name in tmux command", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      local captured_cmd = nil
      vim.fn.system = function(cmd)
        captured_cmd = cmd
        return ""
      end
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      tmux.send_command("my-target-window", "ls -la")
      assert.truthy(captured_cmd:match "my%-target%-window", "should target correct window")
    end)

    it("should include command in tmux send-keys", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      local captured_cmd = nil
      vim.fn.system = function(cmd)
        captured_cmd = cmd
        return ""
      end
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      tmux.send_command("test-window", "npm test")
      assert.truthy(captured_cmd:match "npm test", "should include the command")
    end)
  end)

  describe("kill_window", function()
    it("should succeed closing existing window", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      vim.fn.system = function(cmd)
        if cmd:match "kill%-window" then
          return ""
        end
        return ""
      end
      vim.v = vim.v or {}
      vim.v.shell_error = 0
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.kill_window "test-window"
      assert.is_true(result.success, "should succeed")
      assert.is_nil(result.error, "should have no error")
    end)

    it("should fail when not inside tmux", function()
      vim.env.TMUX = nil
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.kill_window "test-window"
      assert.is_false(result.success, "should fail")
      assert.is_string(result.error, "should return error message")
    end)

    it("should fail gracefully for non-existent window", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      vim.fn.system = function(cmd)
        if cmd:match "kill%-window" then
          return "can't find window: nonexistent"
        end
        return ""
      end
      vim.v = vim.v or {}
      vim.v.shell_error = 1
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.kill_window "nonexistent"
      assert.is_false(result.success, "should fail for non-existent window")
      assert.is_string(result.error, "should return error message")
      -- But it should not throw an exception
      assert.truthy(result.error:match "window" or result.error:match "exist", "error should be descriptive")

      vim.v.shell_error = 0
    end)

    it("should fail with invalid window name", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      local result = tmux.kill_window ""
      assert.is_false(result.success, "should fail with empty name")
      assert.is_string(result.error, "should return error message")
    end)

    it("should include window name in tmux command", function()
      vim.env.TMUX = "/tmp/tmux-501/default,12345,0"
      local captured_cmd = nil
      vim.fn.system = function(cmd)
        if cmd:match "kill%-window" then
          captured_cmd = cmd
          return ""
        end
        return ""
      end
      vim.v = vim.v or {}
      vim.v.shell_error = 0
      package.loaded["utils.tmux"] = nil
      tmux = require "utils.tmux"

      tmux.kill_window "cleanup-window"
      assert.truthy(captured_cmd:match "cleanup%-window", "should target correct window")

      vim.v.shell_error = 0
    end)
  end)
end)

return M
