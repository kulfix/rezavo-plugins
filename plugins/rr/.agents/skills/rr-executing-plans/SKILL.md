---
name: rr-executing-plans
description: Use when a written implementation plan already exists and Codex should execute it end-to-end with explicit task tracking and verification.
---

# Executing Plans

Execute an approved plan without waiting for permission between tasks.

## Step 0: Load Context

1. Load the active feature file with `rr-feature-context`.
2. Read every plan listed in `plans:`.
3. Build an explicit checklist of plan tasks with `pending`, `in_progress`, `completed`.

## Step 1: Capture Baseline

Run the repo's full backend and E2E baseline before code changes. Save logs under `.ai/test-results/<branch-name>/`.

Record:

- command used
- pass/fail summary
- named failures in `baseline-failures.txt`

Baseline failures are evidence, not permission to skip later verification.

## Step 2: Review the Plan

Challenge the plan once, before implementation starts.

- If the plan has a real gap, raise it immediately.
- If the plan is sound, start execution.

Do not keep re-planning after every task.

## Step 3: Execute Tasks

Default loop:

1. Mark one task `in_progress`.
2. Implement it locally or dispatch a worker agent if the slice is long-running, isolated, or parallelizable.
3. Run the focused verification named in the plan.
4. Update the feature file `files:` list.
5. Commit the task work.
6. Mark the task `completed`.

Parallelize only independent tasks with disjoint write sets.

## Subagent Fallback

Prefer worker agents for isolated slices, but do not let orchestration become a blocker.

If an agent stalls, misunderstands the task, or fails to produce usable changes:

1. retry once with tighter context
2. if it still stalls, finish the task in the main context
3. note the deviation in your checklist or feature notes

## Step 4: Finish the Feature File

After all tasks are complete:

1. run the finishing checklist from `rr-feature-context`
2. set the feature status to `done`
3. replace dev notes with business-facing documentation where the feature workflow expects it

## Step 5: Mandatory Gates

After the last task:

1. run `rr-pre-merge-review`
2. fix findings until the audit cycle is complete
3. run `rr-finishing-a-development-branch`

Do not stop between these gates unless you hit a real blocker.

## Stop Conditions

Stop and ask only when:

- the repo state contradicts the plan
- a required dependency or environment is missing
- verification keeps failing and the root cause is unclear
- the user changes the target outcome

Do not ask routine "continue?" questions.
