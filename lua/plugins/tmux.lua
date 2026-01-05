return {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<leader>tm",
      function()
        local pickers = require "telescope.pickers"
        local finders = require "telescope.finders"
        local conf = require("telescope.config").values
        local actions = require "telescope.actions"
        local action_state = require "telescope.actions.state"

        -- Get tmux sessions
        local handle = io.popen "tmux list-sessions -F '#{session_name}'"
        if not handle then
          vim.notify("Failed to get tmux sessions", vim.log.levels.ERROR)
          return
        end
        local result = handle:read "*a"
        handle:close()

        local sessions = {}
        for session in result:gmatch "[^\n]+" do
          table.insert(sessions, session)
        end

        if #sessions == 0 then
          vim.notify("No tmux sessions found", vim.log.levels.WARN)
          return
        end

        pickers
          .new({}, {
            prompt_title = "Tmux Sessions",
            finder = finders.new_table {
              results = sessions,
            },
            sorter = conf.generic_sorter {},
            attach_mappings = function(prompt_bufnr, _)
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                  vim.fn.system("tmux switch-client -t " .. vim.fn.shellescape(selection[1]))
                end
              end)
              return true
            end,
          })
          :find()
      end,
      desc = "Tmux sessions",
    },
  },
}
