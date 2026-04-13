# Code Review: `{branch}` vs `{base}`

Review the changes on branch `{branch}` compared to `{base}` using only the tools and files available in this repository. Treat this as a branch-scoped code review, not a conversational summary.

## Scope

Collect the full branch context before reviewing:

- `git log --no-merges --oneline {base}..{branch}` to inspect commit history on the branch
- `git diff --stat {base}...{branch}` to understand touched files and churn
- `git diff {base}...{branch}` to inspect the full patch against the merge base
- For every non-trivial changed file, read the full file, not just the diff hunk

Use the triple-dot diff form for branch review so the comparison is made against the merge base.

## Review Method

Apply this review in seven passes:

1. Architecture and fit with surrounding code
2. Correctness and behavioral regressions
3. Tests and missing coverage
4. Error handling and edge cases
5. Security and unsafe behavior
6. Naming, clarity, and maintainability
7. Performance and unnecessary complexity

Use the seven passes to drive your inspection, but do not emit a pass-by-pass section in the final answer. Fold the resulting findings into the required severity buckets below.

## Ground Rules

- Findings come first. Keep summaries brief.
- Use severity levels: `Critical`, `Important`, `Minor`.
- Every finding must include `file:line`.
- Focus on bugs, regressions, risky behavior, and missing tests.
- Do not invent findings to fill categories.
- If the branch changes behavior without test coverage, flag it.
- If commit messages do not match the actual diff scope, flag that as commit hygiene.
- Prefer root causes over surface symptoms.
- Use direct technical language only.

## Output Format

Start with two short lines:

- One sentence describing what the branch does
- One sentence stating whether this was a quick branch review or whether the branch appeared to have explicit acceptance criteria

If one of the seven passes found nothing worth flagging, do not add filler text for that pass.

Then use this format exactly:

```markdown
## Findings

### Critical
1. **[file:line]** Issue, impact, and recommended fix.

### Important
1. **[file:line]** Issue, impact, and recommended fix.

### Minor
1. **[file:line]** Issue and suggestion.

## Open Questions
- Question or `None`.

## Summary
- Critical: N
- Important: N
- Minor: N

## Verdict
REQUEST_CHANGES | APPROVE
```

If a section has no items, write `None`.
