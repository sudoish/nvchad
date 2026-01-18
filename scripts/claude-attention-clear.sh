#!/bin/bash
# Claude Code Attention Clear Script
# Triggered when user submits a new prompt (attention addressed)

set -e

# Exit if not in tmux
if [ -z "$TMUX" ]; then
  exit 0
fi

CURRENT_WINDOW=$(tmux display-message -p '#I')

# Reset window-status-current-format to default (inherit from global)
tmux set-window-option -t "$CURRENT_WINDOW" -u window-status-current-format

exit 0
