---
description: Fix a spotted issue (SPOT-XXX) — read investigation, route to appropriate workflow, track status
args: issue_id
---

The user wants to fix a spotted issue. Issue ID: `$ARGUMENTS`

## Your Job

Read the investigated issue, understand root cause and proposed fix, then route to the right workflow based on effort level.

**Anti-hack principle:** The issue file already explains why quick fixes are wrong. Follow the proposed systemic approach.

## Process

### 1. Read Issue

Read `.ai/issues/$ARGUMENTS.md`. If it doesn't exist, list available issues from `.ai/issues/INDEX.md` and ask the user which one.

Extract:
- **Status** — must be `open` or `assigned`. If already `fixed` or `wontfix` → tell user and STOP.
- **Effort** — determines workflow routing (step 3)
- **Proposed fix** — the approach section
- **Files to modify** — scope of changes
- **Root cause** — context for the fix

### 2. Update Status

Set status to `in-progress` in both:
- `.ai/issues/$ARGUMENTS.md` header table
- `.ai/issues/INDEX.md` row

### 3. Route by Effort

```
┌─────────────────────────────────────────────┐
│ Effort from issue file                      │
├──────────────┬──────────────┬───────────────┤
│ quick-fix    │ targeted     │ systemic      │
│ (1 file)     │ (2-5 files)  │ (needs plan)  │
├──────────────┼──────────────┼───────────────┤
│ Fix directly │ Create tasks │ Invoke        │
│ in current   │ from "Files  │ brainstorming │
│ branch       │ to modify",  │ with issue    │
│              │ execute      │ as input      │
└──────────────┴──────────────┴───────────────┘
```

**quick-fix:** Read the file, apply the fix from proposed approach, run tests. No branch needed.

**targeted:** Create one task per file/change from the "Files to modify" and "Approach" sections. Execute sequentially. Run tests after each.

**systemic:** Tell the user this needs a design phase. Invoke `rr:brainstorming` with context:
```
Fix for $ARGUMENTS: <title>

Root cause: <from issue>
Proposed approach: <from issue>
Files to modify: <from issue>

The issue investigation is in .ai/issues/$ARGUMENTS.md
```
Then STOP — brainstorming takes over the workflow.

### 4. Verify Fix

After implementing (quick-fix or targeted only):
1. Run relevant tests (`./cli.py test run` with appropriate filters)
2. If the issue has specific verification steps, run those
3. If it touches frontend, verify visually

### 5. Update Status

After verification passes:
- Update `.ai/issues/$ARGUMENTS.md`: status → `fixed`, add `Fixed | <today YYYY-MM-DD>` row
- Update `.ai/issues/INDEX.md`: status → `fixed`
- Commit with message: `fix: $ARGUMENTS — <brief description>`

### 6. Show Summary

```
ISSUE FIXED
═══════════
ID:       $ARGUMENTS
Title:    <title>
Effort:   <effort>
Status:   fixed

What was done: <1-2 sentence summary>
Files changed: <list>
Tests: <pass/fail>
```
