---
description: Show open spotted issues with quick triage — fix now or assign to feature branch
model: haiku
args: filter
---

Show open issues and help the user decide what to do with each one. Optional filter: `$ARGUMENTS` (severity, type, or ID).

## Process

### 1. Read INDEX

Read `.ai/issues/INDEX.md`. Filter rows by status `open` (or `assigned` if user passed `all`).

If `$ARGUMENTS` is a SPOT-XXX ID, show just that one (skip to step 3).
If `$ARGUMENTS` is a severity/type keyword, filter by it.
If empty, show all open.

If no open issues → tell user and STOP.

### 2. Show Dashboard

```
OPEN ISSUES
═══════════

| # | ID | Severity | Type | Effort | Title |
|---|----|----------|------|--------|-------|
| 1 | SPOT-001 | major | bug-logic | systemic | ... |
| 2 | SPOT-002 | minor | ui-ux | quick-fix | ... |
...

Total: N open issues
```

### 3. For Each Issue — Quick Review

Read each SPOT-XXX.md file. Present a compact summary per issue:

```
─── SPOT-001 (major / systemic) ──────────────────
Root cause:  <1 sentence>
Fix approach: <1 sentence>
Files: <count> files to modify

  [F] Fix now (/issue-fix SPOT-001)
  [B] Assign to branch (which feature?)
  [S] Skip
──────────────────────────────────────────────────
```

Options:
- **F (Fix)** — run `/issue-fix SPOT-001`
- **B (Branch)** — ask which feature branch, then update issue status to `assigned` + add `Assigned to:` in issue file + update INDEX.md
- **S (Skip)** — leave as open, move to next

### 4. Ask User

Present all issues, then ask:

```
What do you want to do? (e.g. "F1, B2 feature/dashboard-v2, S3" or one at a time)
```

Accept:
- Batch: `F1, B2 feature/dashboard-v2, S3`
- Single: just pick one and act
- `all skip` — leave everything open

### 5. Execute Decisions

For each decision:
- **F** → invoke `/issue-fix SPOT-XXX`
- **B** → update status to `assigned`, add `Assigned to: <branch>` row in issue file header, update INDEX.md status
- **S** → no action

### 6. Summary

```
TRIAGE COMPLETE
═══════════════
Fixed: N (SPOT-XXX, ...)
Assigned: N (SPOT-XXX → feature/..., ...)
Skipped: N
Still open: N
```
