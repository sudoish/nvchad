# Code Review: `{branch}` vs `{base}`

Review the changes on branch `{branch}` compared to `{base}` by delegating to the `numa-make-core:reviewing` skill. Do not improvise your own review protocol — that skill already defines one and your job is to apply it to this specific branch.

## Step 1 — Load the skill

Invoke the skill via the Skill tool:

```
Skill(skill: "numa-make-core:reviewing")
```

Read its `SKILL.md`, plus `agents/code-reviewer.md` (the Stage 2 protocol you'll be applying). If the skill isn't available in this environment, say so up front and fall back to the seven-pass review described in that agent file (architecture → tests → error handling → security → naming → performance → maintainability) with Critical / Important / Minor severity tags.

## Step 2 — Gather the diff

The skill is PR-shaped by default; we're branch-scoped, so collect the inputs yourself:

- `git log --no-merges --oneline {base}..{branch}` — commits on the branch
- `git diff --stat {base}...{branch}` — files touched and churn
- `git diff {base}...{branch}` — the full diff
- For any non-trivial file, **read the whole file**, not just the hunk. You can't judge fit-with-surrounding-code from a diff alone.

Note the triple-dot (`...`) in the diff commands — that compares against the merge base, which is what you want for a branch review. The double-dot (`..`) in the log command lists commits reachable from `{branch}` but not `{base}`.

## Step 3 — Pick the review mode

- **Default: Tier 3 Quick Mode** (see the "Tier 3 Quick Mode" section in the skill's `SKILL.md`). Most branch reviews have no formal spec attached. Skip Stage 0 and Stage 1; go straight to code quality + correctness + regression checks.
- **Escalate to full two-stage** only if the branch has an associated spec (look for `project.md`, `spec.md`, a linked Linear/GitHub issue with acceptance criteria, or similar artifacts). If you escalate, run Stage 1 (spec compliance against those criteria) before Stage 2.

State which mode you chose and why in one sentence at the top of your review.

## Step 4 — Apply the Stage 2 protocol

Follow the seven passes in `agents/code-reviewer.md` literally. Don't skip passes because a branch "looks small" — the passes are cheap, and missing a security or test-quality issue is not. For each pass, note what you checked and what you found (or "nothing to flag" if clean).

Supplement with branch-review-specific checks the skill doesn't cover:

- **Test runs.** The skill assumes tests have been run. You likely can't run them here — flag tests that look wrong from reading, and flag behavior changes that lack a test, but don't execute the suite unless asked.
- **Scope creep.** Do the commit messages match the diff? A commit titled "fix typo" that also refactors a module is a review flag even if the refactor is fine on its own.
- **Commit hygiene.** Squash-worthy WIP commits, merge commits from the wrong direction, commits that shouldn't be on this branch.

## Step 5 — Output

Use the skill's exact output format from `agents/code-reviewer.md`:

```markdown
## Code Quality Review

### Critical
1. **[file:line]** [issue, impact, fix]

### Important
1. **[file:line]** [issue, impact, fix]

### Minor
1. **[file:line]** [issue, suggestion]

### Summary
- Critical: N (must fix)
- Important: N (should fix)
- Minor: N (developer discretion)

### Verdict: APPROVE | REQUEST_CHANGES
```

Prepend to this:
- The mode you used (Tier 3 vs full two-stage) and why
- A two-sentence description of what this branch does
- If you ran Stage 1: the spec-compliance table

## Ground rules

- **Follow the skill's communication style:** technical observations only; no "great job," no "just a few minor things," no softened hedging.
- **Be literal about severity.** Don't inflate Minor findings to Critical to look thorough, and don't deflate Critical findings to Important to avoid friction. When in doubt, go higher.
- **Reference `file:line` on every finding.** Vague findings get ignored.
- **Don't invent findings.** If a pass has nothing to flag, say so. Empty categories are a valid result, and padding dilutes the real findings.
- **Root causes over symptoms.** If a fix papers over a deeper bug, say so.
