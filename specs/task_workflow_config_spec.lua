package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

describe("ai-tools.task-workflow.config", function()
  local config

  before_each(function()
    -- Clear cached module to ensure fresh load each test
    package.loaded["ai-tools.task-workflow.config"] = nil
    config = require "ai-tools.task-workflow.config"
  end)

  describe("module loading", function()
    it("loads without error", function()
      assert.is_not_nil(config)
    end)

    it("returns a table", function()
      assert.is_table(config)
    end)
  end)

  describe("trees_folder", function()
    it("exists", function()
      assert.is_not_nil(config.trees_folder)
    end)

    it("equals '.trees'", function()
      assert.are.equal(".trees", config.trees_folder)
    end)

    it("is a string", function()
      assert.is_string(config.trees_folder)
    end)
  end)

  describe("default_ai_tool", function()
    it("exists", function()
      assert.is_not_nil(config.default_ai_tool)
    end)

    it("equals 'claude'", function()
      assert.are.equal("claude", config.default_ai_tool)
    end)

    it("is a string", function()
      assert.is_string(config.default_ai_tool)
    end)
  end)

  describe("notifications", function()
    it("exists", function()
      assert.is_not_nil(config.notifications)
    end)

    it("is a table", function()
      assert.is_table(config.notifications)
    end)

    describe("notifications.success", function()
      it("exists", function()
        assert.is_not_nil(config.notifications.success)
      end)

      it("equals true", function()
        assert.is_true(config.notifications.success)
      end)

      it("is a boolean", function()
        assert.is_boolean(config.notifications.success)
      end)
    end)

    describe("notifications.errors", function()
      it("exists", function()
        assert.is_not_nil(config.notifications.errors)
      end)

      it("equals true", function()
        assert.is_true(config.notifications.errors)
      end)

      it("is a boolean", function()
        assert.is_boolean(config.notifications.errors)
      end)
    end)
  end)

  describe("git_flow", function()
    it("exists", function()
      assert.is_not_nil(config.git_flow)
    end)

    it("is a table", function()
      assert.is_table(config.git_flow)
    end)

    it("is enabled", function()
      assert.is_true(config.git_flow.enabled)
    end)

    it("uses feature as the default type", function()
      assert.are.equal("feature", config.git_flow.default_type)
    end)
  end)

  describe("expected keys are present", function()
    it("has all required top-level keys", function()
      local expected_keys = { "trees_folder", "default_ai_tool", "git_flow", "notifications" }
      for _, key in ipairs(expected_keys) do
        assert.is_not_nil(config[key], "Missing key: " .. key)
      end
    end)

    it("has all required git_flow keys", function()
      local expected_keys = { "enabled", "default_type", "types" }
      for _, key in ipairs(expected_keys) do
        assert.is_not_nil(config.git_flow[key], "Missing git_flow key: " .. key)
      end
    end)

    it("has all required notification keys", function()
      local expected_keys = { "success", "errors" }
      for _, key in ipairs(expected_keys) do
        assert.is_not_nil(config.notifications[key], "Missing notification key: " .. key)
      end
    end)
  end)
end)
