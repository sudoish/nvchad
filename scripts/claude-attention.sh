#!/bin/bash
# Claude Code Attention Hook Script
# Triggered when Claude Code needs user attention
# Uses format-based approach to work with themed tmux configs

set -e

# Exit if not in tmux
if [ -z "$TMUX" ]; then
  exit 0
fi

CURRENT_WINDOW=$(tmux display-message -p '#I')

# Attention styling config (can be overridden via environment)
ATTENTION_ICON="${CLAUDE_ATTENTION_ICON:-󰚩 }"
ATTENTION_BG="${CLAUDE_ATTENTION_BG:-#ff9500}"
ATTENTION_FG="${CLAUDE_ATTENTION_FG:-#000000}"

# Theme colors to replace (Dracula theme defaults, can be overridden)
THEME_BG="${CLAUDE_THEME_BG:-#6272a4}"
THEME_FG="${CLAUDE_THEME_FG:-#f8f8f2}"
THEME_ACCENT="${CLAUDE_THEME_ACCENT:-#bd93f9}"

# Get the global window-status-current-format
ORIG_FORMAT=$(tmux show-options -gv window-status-current-format)

# Replace theme colors with attention colors and add icon
NEW_FORMAT=$(echo "$ORIG_FORMAT" | sed \
  -e "s/$THEME_BG/$ATTENTION_BG/g" \
  -e "s/$THEME_FG/$ATTENTION_FG/g" \
  -e "s/$THEME_ACCENT/$ATTENTION_FG/g" \
  -e "s/#I/#I $ATTENTION_ICON/")

# Apply the modified format to this window
tmux set-window-option -t "$CURRENT_WINDOW" window-status-current-format "$NEW_FORMAT"

# Optional: System notification
if [ "${CLAUDE_SYSTEM_NOTIFICATION:-false}" = "true" ]; then
  if command -v notify-send &> /dev/null; then
    notify-send "Claude Code" "Needs your attention" -i terminal
  elif command -v osascript &> /dev/null; then
    osascript -e 'display notification "Needs your attention" with title "Claude Code"'
  fi
fi

exit 0
