---
name: rr-finishing-a-development-branch
description: Use when implementation and pre-merge-review are complete and the branch needs final verification, visual checks, and PR creation.
---

# Finishing a Development Branch

Run the final verification gate after `rr-pre-merge-review`.

## Step 0: Verify the Audit Gate

Require `.ai/audit/<branch-name>/summary.md` to exist before continuing.

## Step 1: Update Feature Context

Use `rr-feature-context` to mark the feature `done` and verify the business-facing sections are current.

## Step 2: Visual Verification

If the diff contains frontend files, run `rr-visual-verification`.

Do not ask whether visual verification is needed.

## Step 3: Final Test Loops

Run the repo's full backend suite and full E2E suite.

Use baseline evidence from execution time:

- if a failure is new, fix it
- if a failure is pre-existing and documented in baseline artifacts, keep it documented

Loop until the final state is clean or fully explained by baseline evidence.

## Step 4: Push and Create PR

Create the PR only after:

- final tests are done
- visual verification is done or explicitly skipped by diff
- audit summary exists

Build the PR body from:

- feature file summary
- feature file capabilities
- audit summary
- deferred issues
- final verification notes

Use neutral Codex wording. Do not inject Claude branding.
