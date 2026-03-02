---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Step 0: Load Feature Context (REQUIRED)

Before writing any plan:
1. Use `feature-context` skill to find the active feature file
2. Read the feature file — understand status, existing plans, dependencies
3. Verify `base_branch:` is set in feature file. If missing, use value from `<branch-context>` (session start) and add it.
4. After saving the plan, update feature file frontmatter with new plan path

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use rr:executing-plans to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Last Task: Gate

**Every plan MUST end with this task:**

```markdown
### Task N: Gate

Run `/pre-merge-review` skill. This runs 2 audit rounds with fixes between them:
Round 1-2: 3 auditors (Fletcher, Paranoik, Javert). R2 conditional.
→ fix findings → commit → re-audit.

Reports saved to `.ai/audit/round-{1,2}.md`.
Final summary + user approval before PR.
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## E2E Task Structure

If design doc has Acceptance Scenarios → plan MUST include E2E task(s). Place AFTER implementation, BEFORE Gate. Use `rr:writing-tests` for Playwright patterns.

````markdown
### Task N: E2E Tests (SC-01, SC-02, SC-03)

**Files:**
- Create: `tests/e2e/features/<feature-name>.spec.ts`
- Reference: `tests/e2e/fixtures/config.ts`

**Scenarios from design:** SC-01 (atomic), SC-02 (atomic), SC-03 (journey)

**Step 1: Write E2E spec** — one test per SC-XX, loginViaAPI in beforeEach

**Step 2: Run:** `./cli.py e2e test features`

**Step 3: Commit:** `git commit -m "test(e2e): add SC-01..SC-03 for <feature>"`
````

## Remember
- Load feature context FIRST (Step 0)
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Reference relevant skills with @ syntax
- DRY, YAGNI, TDD, frequent commits
- If design doc has Acceptance Scenarios → plan MUST include E2E task(s) after implementation, before Gate
- Always end plan with Audit Gate task

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use rr:subagent-driven-development
- Stay in this session
- Fresh subagent per task + code review

**If Parallel Session chosen:**
- Guide them to open new session in worktree
- **REQUIRED SUB-SKILL:** New session uses rr:executing-plans
