-- Sidekick.nvim - Universal AI CLI integration

local DEFAULT_TOOL = "opencode"

return {
    "folke/sidekick.nvim",
    opts = {
        cli = {
            default = DEFAULT_TOOL,
            tools = {
                -- Custom tools for resume/continue with flags
                ["opencode-resume"] = {
                    cmd = { "opencode", "--resume" },
                },
                ["opencode-continue"] = {
                    cmd = { "opencode", "--continue" },
                },
            },
        },
    },
    keys = {
        { "<leader>ac", function() require("sidekick.cli").toggle { focus = true } end, desc = "Toggle Opencode", mode = { "n", "v" } },
        { "<leader>af", function() require("sidekick.cli").focus() end, desc = "Focus Opencode" },
        { "<leader>ar", function() require("sidekick.cli").toggle { name = "opencode-resume", focus = true } end, desc = "Resume Opencode" },
        { "<leader>aC", function() require("sidekick.cli").toggle { name = "opencode-continue", focus = true } end, desc = "Continue Opencode" },
        { "<leader>am", function() require("sidekick.cli").select { filter = { installed = true } } end, desc = "Select AI tool" },
        { "<leader>ab", function() require("sidekick.cli").send { msg = "{file}" } end, desc = "Add current buffer" },
        { "<leader>as", function() require("sidekick.cli").send { msg = "{position}" } end, mode = "v", desc = "Send to Opencode" },
        { "<leader>ay", function() require("sidekick.ui").accept() end, desc = "Accept diff" },
        { "<leader>ad", function() require("sidekick.ui").reject() end, desc = "Deny diff" },
        { "<c-.>", function() require("sidekick.cli").toggle() end, desc = "Sidekick Toggle", mode = { "n", "t", "i", "x" } },
        { "<c-h>", "<cmd>wincmd h<cr>", desc = "Navigate to left window", mode = { "n", "t" } },
        { "<tab>", function() if not require("sidekick").nes_jump_or_apply() then return "<Tab>" end end, expr = true, desc = "Goto/Apply Next Edit Suggestion" },
    },
}
