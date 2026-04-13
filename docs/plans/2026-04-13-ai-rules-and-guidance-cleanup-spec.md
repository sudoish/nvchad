# AI Rules And Guidance Cleanup Spec

**Date:** 2026-04-13
**Status:** Draft

## Overview

This spec defines a step-by-step cleanup of the repository's AI tooling, prompts, safety settings, tests, and documentation so that the configured behavior matches the documented guidance.

The current setup is functional in parts, but several important pieces have drifted:
- branch review guidance depends on missing external skills and files
- Claude local permissions are broader than the written safety posture implies
- task workflow config, specs, and docs no longer agree on the intended defaults
- CI validates formatting and startup, but does not enforce the AI workflow specs
- local lint output is noisy because nested worktrees are included

## Problem Statement

The repository has accumulated AI-related behavior in multiple places:
- Neovim plugin specs under `lua/plugins/`
- task workflow logic under `lua/ai-tools/task-workflow/`
- review prompts under `prompts/`
- local agent policy under `.claude/settings.local.json`
- contributor and agent guidance in `README.md`, `CONTRIBUTING.md`, and `AGENTS.md`
- automated checks in `.github/workflows/ci.yml`, `.pre-commit-config.yaml`, and specs under `tests/` and `specs/`

Those layers are no longer aligned, which creates three concrete risks:
- agents are instructed to use workflows that do not exist locally
- tool permissions allow actions that the written rules are trying to discourage
- regressions in AI workflow behavior are not caught early enough

## Goals

1. Make all AI review and workflow guidance repo-local and executable in this environment.
2. Align tool permissions with the intended safety model.
3. Reconcile runtime config, tests, and docs around the task workflow.
4. Add automated enforcement for AI-related behavior in CI.
5. Reduce noisy quality signals so local checks reflect the main repo state.

## Non-Goals

1. Replacing the current AI tool architecture.
2. Redesigning the tmux/worktree workflow.
3. Adding new AI providers unless needed to preserve current behavior.
4. Building a generic prompt framework beyond the fixes needed here.

## Current State Summary

### Working Areas

- `claudecode.nvim` and `sidekick.nvim` responsibilities are clearly separated.
- The task workflow creates worktrees and tmux windows in a sensible sequence.
- There are existing specs for opencode and the task workflow.

### Misaligned Areas

- `prompts/review-branch.md` references `numa-make-core:reviewing`, `SKILL.md`, and `agents/code-reviewer.md`, none of which are present in this repo.
- `.claude/settings.local.json` allows broad commands such as `Bash(bash:*)` and broad git write operations.
- `lua/ai-tools/task-workflow/config.lua` does not match `specs/task_workflow_config_spec.lua`.
- `specs/task_workflow_spec.lua` uses config mocks that no longer match the runtime config shape.
- `README.md` still documents an AI layout that does not match the current filesystem.
- CI does not run the busted specs that cover the AI workflow.

## Decisions To Confirm

These decisions should be finalized during implementation and then reflected consistently in code, tests, and docs.

1. Default AI tool
Current runtime config uses `claude`, while some specs still expect `droid`.

2. Slug length policy
Specs still expect `max_slug_length = 15`, but runtime config no longer exposes it.

3. Config contract strictness
Decide whether `task-workflow` should require `git_flow` to exist, or should tolerate omitted config keys via defaults.

## Proposed Changes

### Phase 1: Localize Review Guidance

Replace the branch review prompt with repo-local instructions that:
- use the available tools and local conventions
- do not depend on missing skills or files
- still enforce a disciplined review structure
- produce output with severity, file references, and verdict

Expected files:
- `prompts/review-branch.md`

Acceptance criteria:
- prompt does not reference missing local files or unavailable skills as required dependencies
- prompt matches the review style expected by this repo
- `<leader>aR` continues to work with the updated prompt

### Phase 2: Tighten Local Agent Permissions

Reduce the allowed command set in `.claude/settings.local.json` so it supports the intended workflows without granting broad escape hatches.

Expected files:
- `.claude/settings.local.json`

Acceptance criteria:
- broad command allowances are removed or narrowed
- allowed commands still cover normal repo workflows such as linting, testing, validation, PR inspection, and explicit git operations
- settings remain valid JSON

### Phase 3: Reconcile Task Workflow Contract

Pick the intended behavior for the task workflow, then align implementation and tests.

Expected files:
- `lua/ai-tools/task-workflow/config.lua`
- `lua/ai-tools/task-workflow/init.lua`
- `specs/task_workflow_config_spec.lua`
- `specs/task_workflow_spec.lua`

Acceptance criteria:
- config keys expected by runtime and specs match
- the default AI tool is consistently defined across code and tests
- tests no longer error on missing `git_flow`
- relevant busted specs pass locally

### Phase 4: Enforce AI Workflow Checks In CI

Add the AI-related specs to CI so drift is caught automatically.

Expected files:
- `.github/workflows/ci.yml`

Acceptance criteria:
- CI runs busted specs for AI workflow coverage
- CI still runs on a clean environment with documented prerequisites

### Phase 5: Reduce Local Check Noise

Exclude nested worktrees from lint scope or otherwise ensure local quality commands operate on the active repo rather than archived worktrees.

Expected files:
- `.luacheckrc`
- possibly `AGENTS.md`, `CONTRIBUTING.md`, and pre-commit config if command guidance changes

Acceptance criteria:
- `luacheck .` or the documented replacement no longer reports stale warnings from `.trees/`
- local quality guidance matches actual behavior

### Phase 6: Refresh Documentation

Update human-facing and agent-facing docs so they describe the current AI architecture and quality workflow.

Expected files:
- `README.md`
- `CONTRIBUTING.md`
- `AGENTS.md`

Acceptance criteria:
- docs reflect the actual file layout and commands in use
- docs mention only workflows that exist in this repo
- docs are consistent with the cleaned-up runtime config and CI

## Implementation Order

1. Localize review guidance.
2. Tighten local agent permissions.
3. Reconcile task workflow code and specs.
4. Add AI workflow specs to CI.
5. Reduce lint noise.
6. Refresh docs.

## Validation Plan

At the end of the cleanup, validate with:

```bash
stylua .
luacheck .
nvim --headless -u init.lua -c "lua vim.cmd('quit')"
~/.luarocks/bin/busted tests/opencode_spec.lua specs/task_workflow_spec.lua specs/task_workflow_config_spec.lua
```

If lint scope changes, update this validation section to the final documented command.

## Risks

1. Tightening permissions too far could break established local workflows.
2. Changing the default AI tool may surprise existing users if the docs and keybindings are not updated together.
3. CI additions may require installing extra dependencies that are currently only available locally.

## Rollout Strategy

Implement one phase at a time and keep each phase independently reviewable.

Recommended commit boundaries:
1. review prompt cleanup
2. permission cleanup
3. task workflow contract sync
4. CI and lint scope updates
5. documentation refresh

## Success Criteria

This cleanup is complete when:
- all AI guidance refers only to available local workflows or clearly optional external integrations
- local agent permissions reflect the intended safety posture
- AI workflow specs pass and are enforced in CI
- local quality commands are low-noise and trustworthy
- repo documentation accurately describes the AI architecture and workflows
