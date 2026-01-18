return {
  trees_folder = ".trees",
  default_ai_tool = "claude",
  git_flow = {
    enabled = true,
    default_type = "feature",
    types = {
      "feature",
      "bugfix",
      "hotfix",
      "release",
      "support",
    },
  },
  notifications = {
    success = true,
    errors = true,
    -- Claude Code attention notifications
    claude_attention = {
      enabled = true,
      -- Tmux styling when attention needed
      -- Uses format-based approach to work with themed tmux configs
      tmux_style = {
        -- Icon added to window format
        icon = "󰚩 ", -- Nerd Font: robot face
        -- Attention colors (replaces theme colors)
        fg_color = "#000000", -- Black text for contrast
        bg_color = "#ff9500", -- Orange background
        -- Theme colors to replace (Dracula theme defaults)
        theme_bg = "#6272a4", -- Purple background in theme
        theme_fg = "#f8f8f2", -- White text in theme
        theme_accent = "#bd93f9", -- Purple accent in theme
      },
      -- System notification (optional, desktop notification)
      system_notification = {
        enabled = false,
        -- Command to run for system notification (platform-specific)
        -- Linux: notify-send "Claude Code" "Needs attention"
        -- macOS: osascript -e 'display notification ...'
        command = nil, -- Auto-detect platform if nil
      },
      -- Events that trigger attention
      events = {
        permission_prompt = true, -- Claude needs permission
        idle_prompt = true, -- Claude idle for 60s+
        stop = true, -- Claude finished responding
      },
    },
  },
}
