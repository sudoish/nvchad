# Team Feature Plugin Design

**Date:** 2026-02-07
**Status:** Approved

## Overview

A Claude Code plugin that orchestrates parallel feature development using agent teams. The command analyzes a feature description, proposes a decomposition into parallel workstreams, and spawns dedicated teammates—each in their own tmux window for visibility.

## Plugin Structure

```
~/.claude/plugins/cache/pacheco-plugins/team-feature/1.0.0/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── commands/
│   └── develop.md            # Main /team-feature:develop command
├── skills/
│   └── team-workflow/
│       └── SKILL.md          # Guidance for the lead agent
└── README.md
```

## Command Workflow

### Invocation
```
/team-feature:develop "Add user authentication with OAuth"
```

### Phases

**Phase 1: Analysis**
- Read the feature description argument
- Explore the codebase to understand relevant areas
- Identify natural boundaries for parallel work

**Phase 2: Decomposition Proposal**
- Present 2-5 proposed teammates with:
  - Role name (e.g., "backend-api", "frontend-ui", "tests")
  - Responsibility summary
  - Key files/areas they'll own
  - Dependencies on other teammates
- Ask user to approve, modify, or reject

**Phase 3: Documentation**
- Write `docs/plans/YYYY-MM-DD-<feature>-design.md`
- Commit the design doc

**Phase 4: Team Spawn**
- Create agent team with descriptive name
- Spawn each approved teammate with detailed prompts
- Open a tmux window for each teammate
- Set up shared task list with dependencies

**Phase 5: Coordination**
- Monitor teammate progress
- Synthesize results when complete
- Update design doc with completion status

## Tmux Integration

**Requirements:**
- Must run inside a tmux session
- Each teammate gets their own tmux window

**Window creation:**
```bash
tmux new-window -n "feat:<role-name>" "claude --resume <agent-id>"
```

**User workflow:**
- `Ctrl-b w` - List all windows
- `Ctrl-b <n>` - Jump to teammate
- `Ctrl-b 0` - Return to lead

## Decomposition Principles

1. Each teammate owns files exclusively (no overlap)
2. Prefer 2-4 teammates
3. Define clear interfaces between work
4. Identify dependencies upfront
5. 3-6 tasks per teammate

## Dependencies

- Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings
- Requires running inside tmux

## Success Criteria

- All tasks marked complete
- Tests passing
- Design doc updated with final status
