---
name: rr-subagent-driven-development
description: Use when a written plan exists and you want to execute it in the current session with fresh worker agents per task.
---

# Subagent-Driven Development

Execute the plan in the current session with one fresh worker agent per task when that helps.

## When to Use

Use this instead of `rr-executing-plans` when:

- you want to stay in the same session
- tasks are mostly independent
- you want tight human steering between worker runs

## Step 0: Prepare

1. Load the feature file.
2. Read the plan once.
3. Build an explicit checklist.
4. Capture the baseline test evidence.

## Step 1: Per-Task Loop

For each task:

1. mark it `in_progress`
2. dispatch a worker agent with the full task text and context
3. answer worker questions immediately
4. review the worker result
5. run the focused verification
6. update feature `files:`
7. commit
8. mark the task `completed`

Use `implementer-prompt.md` as the worker template.

## Fallback

If a worker stalls or fails twice, finish the task locally and note that the task fell back to main-context execution.

## Endgame

After the last task:

1. run `rr-pre-merge-review`
2. fix audit findings
3. run `rr-finishing-a-development-branch`

Do not create a PR before both gates are done.
