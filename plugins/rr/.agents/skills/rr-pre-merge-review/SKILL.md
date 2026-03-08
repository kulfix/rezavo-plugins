---
name: rr-pre-merge-review
description: Use when implementation is complete and the branch needs the mandatory rr two-round audit cycle before final verification.
---

# Pre-Merge Review

Run the mandatory two-round audit cycle before the branch enters final verification.

## Step 1: Prepare Audit Artifacts

1. Get the current branch name.
2. Create `.ai/audit/<branch-name>/`.
3. Clear only old reports for this branch.

## Step 2: Round 1

1. Run `rr-audit`.
2. Convert `MUST FIX` findings into checklist items.
3. Fix them locally or with worker agents.
4. Save `round-1.md`.
5. Commit the round-1 fixes.

## Step 3: Decide on Round 2

Skip round 2 only if round 1 produced:

- zero `MUST FIX`
- zero `DEFERRED`

Otherwise round 2 is mandatory.

## Step 4: Round 2

1. Re-run audit for regression checking with:
   - `rr-fletcher`
   - `rr-tenant-debugger`
2. Fix new or remaining `MUST FIX` findings.
3. Save `round-2.md`.
4. Commit the round-2 fixes.

## Step 5: Summary

Write `.ai/audit/<branch-name>/summary.md` with:

- totals by category
- round-by-round findings
- final per-agent ratings
- link to `issues.md`

Present the summary to the caller. Do not create a PR here.
