local M = {}

package.path = package.path .. ";./lua/?.lua"

-- Mock vim global for testing outside neovim
_G.vim = _G.vim or {}
_G.vim.g = _G.vim.g or {}
_G.vim.o = _G.vim.o or {}
_G.vim.fn = _G.vim.fn or {}
_G.vim.keymap = _G.vim.keymap or {}
_G.vim.log = _G.vim.log or { levels = { ERROR = 1 } }

-- Track keymaps that are set
local keymaps_set = {}

-- Mock vim.keymap.set
_G.vim.keymap.set = function(mode, lhs, rhs, opts)
  table.insert(keymaps_set, {
    mode = mode,
    lhs = lhs,
    rhs = rhs,
    opts = opts or {},
  })
end

describe("Opencode Plugin Configuration", function()
  local original_package_loaded
  local original_vim_g
  local original_vim_o

  before_each(function()
    -- Store original values
    original_package_loaded = package.loaded["opencode"]
    original_vim_g = vim.g.opencode_opts
    original_vim_o = vim.o.autoread

    -- Clear keymaps tracking
    keymaps_set = {}

    -- Mock the opencode module
    package.loaded["opencode"] = {
      toggle = function()
        return "toggle_called"
      end,
      ask = function()
        return "ask_called"
      end,
      select = function()
        return "select_called"
      end,
      operator = function(text)
        return text .. "_operator_called"
      end,
      command = function(cmd)
        return cmd .. "_command_called"
      end,
    }

    -- Clear the plugin module cache
    package.loaded["plugins.opencode"] = nil
  end)

  after_each(function()
    -- Restore original values
    package.loaded["opencode"] = original_package_loaded
    vim.g.opencode_opts = original_vim_g
    vim.o.autoread = original_vim_o
  end)

  describe("module structure", function()
    it("should load the plugin module", function()
      local plugin = require "plugins.opencode"
      assert.is_table(plugin, "plugin should be a table")
    end)

    it("should have correct plugin name", function()
      local plugin = require "plugins.opencode"
      assert.equals("nickjvandyke/opencode.nvim", plugin[1], "should have correct plugin name")
    end)

    it("should not be lazy loaded", function()
      local plugin = require "plugins.opencode"
      assert.is_false(plugin.lazy, "should not be lazy loaded")
    end)

    it("should have version set to wildcard", function()
      local plugin = require "plugins.opencode"
      assert.equals("*", plugin.version, "should use wildcard version")
    end)

    it("should have dependencies", function()
      local plugin = require "plugins.opencode"
      assert.is_table(plugin.dependencies, "should have dependencies")
      assert.equals(1, #plugin.dependencies, "should have one dependency")
    end)

    it("should have snacks.nvim as optional dependency", function()
      local plugin = require "plugins.opencode"
      local snacks_dep = plugin.dependencies[1]
      assert.equals("folke/snacks.nvim", snacks_dep[1], "should depend on snacks.nvim")
      assert.is_true(snacks_dep.optional, "snacks.nvim should be optional")
    end)
  end)

  describe("configuration function", function()
    it("should set vim.g.opencode_opts", function()
      local plugin = require "plugins.opencode"
      -- Call the config function
      plugin.config()
      assert.is_table(vim.g.opencode_opts, "should set opencode_opts")
    end)

    it("should set vim.o.autoread to true", function()
      local plugin = require "plugins.opencode"
      -- Reset autoread
      vim.o.autoread = false
      plugin.config()
      assert.is_true(vim.o.autoread, "should set autoread to true")
    end)
  end)

  describe("keymaps", function()
    before_each(function()
      local plugin = require "plugins.opencode"
      plugin.config()
    end)

    it("should set toggle keymap", function()
      local found = false
      for _, km in ipairs(keymaps_set) do
        if km.lhs == "<leader>oc" then
          found = true
          assert.equals("n", km.mode, "should be normal mode")
          assert.equals("Toggle Opencode", km.opts.desc, "should have correct description")
        end
      end
      assert.is_true(found, "should set <leader>oc keymap")
    end)

    it("should set ask keymap", function()
      local found = false
      for _, km in ipairs(keymaps_set) do
        if km.lhs == "<leader>oa" then
          found = true
          assert.equals("n", km.mode, "should be normal mode")
          assert.equals("Ask Opencode", km.opts.desc, "should have correct description")
        end
      end
      assert.is_true(found, "should set <leader>oa keymap")
    end)

    it("should set send keymap", function()
      local found = false
      for _, km in ipairs(keymaps_set) do
        if km.lhs == "<leader>os" then
          found = true
          assert.same({ "n", "x" }, km.mode, "should be normal and visual mode")
          assert.equals("Send to Opencode", km.opts.desc, "should have correct description")
        end
      end
      assert.is_true(found, "should set <leader>os keymap")
    end)

    it("should set select keymap", function()
      local found = false
      for _, km in ipairs(keymaps_set) do
        if km.lhs == "<leader>ox" then
          found = true
          assert.same({ "n", "x" }, km.mode, "should be normal and visual mode")
          assert.equals("Execute Opencode action", km.opts.desc, "should have correct description")
        end
      end
      assert.is_true(found, "should set <leader>ox keymap")
    end)

    it("should set operator keymap 'go'", function()
      local found = false
      for _, km in ipairs(keymaps_set) do
        if km.lhs == "go" then
          found = true
          assert.same({ "n", "x" }, km.mode, "should be normal and visual mode")
          assert.equals("Add range to opencode", km.opts.desc, "should have correct description")
          assert.is_true(km.opts.expr, "should be expression mapping")
        end
      end
      assert.is_true(found, "should set go keymap")
    end)

    it("should set operator keymap 'goo'", function()
      local found = false
      for _, km in ipairs(keymaps_set) do
        if km.lhs == "goo" then
          found = true
          assert.equals("n", km.mode, "should be normal mode")
          assert.equals("Add line to opencode", km.opts.desc, "should have correct description")
          assert.is_true(km.opts.expr, "should be expression mapping")
        end
      end
      assert.is_true(found, "should set goo keymap")
    end)

    it("should set scroll up keymap", function()
      local found = false
      for _, km in ipairs(keymaps_set) do
        if km.lhs == "<S-C-u>" then
          found = true
          assert.equals("n", km.mode, "should be normal mode")
          assert.equals("Scroll opencode up", km.opts.desc, "should have correct description")
        end
      end
      assert.is_true(found, "should set <S-C-u> keymap")
    end)

    it("should set scroll down keymap", function()
      local found = false
      for _, km in ipairs(keymaps_set) do
        if km.lhs == "<S-C-d>" then
          found = true
          assert.equals("n", km.mode, "should be normal mode")
          assert.equals("Scroll opencode down", km.opts.desc, "should have correct description")
        end
      end
      assert.is_true(found, "should set <S-C-d> keymap")
    end)

    it("should set all 8 keymaps", function()
      assert.equals(8, #keymaps_set, "should set 8 keymaps total")
    end)
  end)

  describe("snacks integration", function()
    it("should configure snacks picker actions", function()
      local plugin = require "plugins.opencode"
      local snacks_opts = plugin.dependencies[1].opts

      assert.is_table(snacks_opts.picker.actions, "should have picker actions")
      assert.is_function(snacks_opts.picker.actions.opencode_send, "should have opencode_send action")
    end)

    it("should configure snacks input", function()
      local plugin = require "plugins.opencode"
      local snacks_opts = plugin.dependencies[1].opts

      assert.is_table(snacks_opts.input, "should have input configuration")
    end)

    it("should bind Alt+a in snacks picker", function()
      local plugin = require "plugins.opencode"
      local snacks_opts = plugin.dependencies[1].opts

      local keys = snacks_opts.picker.win.input.keys
      assert.is_table(keys["<a-a>"], "should have Alt+a binding")
      assert.same({ "opencode_send", mode = { "n", "i" } }, keys["<a-a>"], "should bind to opencode_send")
    end)
  end)
end)

return M
