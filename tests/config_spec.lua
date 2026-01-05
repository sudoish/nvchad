local M = {}

describe("NvChad Configuration", function()
  it("should load the main init.lua", function()
    local init_ok, init_err = pcall(loadfile, vim.fn.stdpath "config" .. "/init.lua")
    assert.is_true(init_ok, "init.lua should be loadable: " .. tostring(init_err))
  end)

  it("should load chadrc configuration", function()
    local chadrc_ok, chadrc = pcall(require, "chadrc")
    assert.is_true(chadrc_ok, "chadrc should be loadable")
    assert.is_table(chadrc, "chadrc should be a table")
  end)

  it("should load options configuration", function()
    local options_ok, options = pcall(require, "options")
    assert.is_true(options_ok, "options should be loadable")
    assert.is_table(options, "options should be a table")
  end)

  it("should load mappings configuration", function()
    local mappings_ok, mappings = pcall(require, "mappings")
    assert.is_true(mappings_ok, "mappings should be loadable")
    assert.is_table(mappings, "mappings should be a table")
  end)

  it("should load autocmds configuration", function()
    local autocmds_ok, autocmds = pcall(require, "autocmds")
    assert.is_true(autocmds_ok, "autocmds should be loadable")
    assert.is_table(autocmds, "autocmds should be a table")
  end)

  it("should load plugins init configuration", function()
    local plugins_ok, plugins = pcall(require, "plugins.init")
    assert.is_true(plugins_ok, "plugins.init should be loadable")
    assert.is_table(plugins, "plugins.init should be a table")
  end)
end)

return M
