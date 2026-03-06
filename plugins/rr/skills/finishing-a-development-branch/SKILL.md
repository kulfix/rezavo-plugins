---
name: finishing-a-development-branch
description: Use when implementation and pre-merge-review are complete, to run final tests, visual verification, E2E, and create PR
---

# Finishing a Development Branch

## Overview

Final gate before PR: verify tests, take screenshots, run E2E, auto-create PR.

**Core principle:** Verify gate → Update feature file → Docs review → Visual verification (automatic) → Final tests + compare with baseline → E2E → Auto-PR.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## The Process

### Task 0: Verify Gate (REQUIRED)

`<base-branch>` = value from `<branch-context>` injected at session start. If UNKNOWN or missing → **ASK user.** Do NOT assume `main`.

1. Check if `/pre-merge-review` was run (look for `.ai/audit/<branch-name>/summary.md`)
2. If NOT — **STOP. Run `/pre-merge-review` first.**

All subsequent steps use `<base-branch>` — NEVER hardcode `main`.

### Task 1: Update Feature File

Use `feature-context` skill: set `status: done`, verify all plan items reflected.

### Task 2: Docs Review

Run `rr:docs-review` skill — checks if `docs/kb/` needs updates based on what was built.
Only suggests additions where a future developer would be confused without them.
Does NOT block the flow — review suggestions, apply if useful, skip if not.

### Task 3: Start Docker Environment

```bash
./cli.py e2e up    # builds + starts backend, frontend, postgres, redis
```

Verify containers healthy before proceeding. Keep running through Tasks 4-7.

`e2e up` includes everything `test up` has PLUS frontend — needed for visual verification (Task 4). Full suite commands auto-restart the stack for clean state.

### Task 4: Visual Verification (AUTOMATIC)

<HARD-RULE>
NEVER ask if visual verification is needed. Check the diff automatically.
If ANY frontend file changed — run visual verification. No exceptions.
</HARD-RULE>

```bash
git diff <base-branch>...HEAD --name-only | grep -E 'frontend/|\.(tsx|jsx|html|css|scss|jinja)$'
```

- **Matches found:** Run `rr:visual-verification` skill. Docker is already running — skill should skip startup.
- **No matches:** Skip. Log: "No frontend files in diff — skipping visual verification."

### Task 5: Final Backend Tests

> **Tests:** Invoke `rr:running-tests` for full context on test groups, diagnostics, and best practices.

```bash
./cli.py test run -g all 2>&1 | tee .ai/test-results/<branch-name>/final.log
```

Full suite auto-restarts the stack for clean state. Parse test summary. Extract failed test names to `final-failures.txt`.

### Task 6: Fix Loop — Backend Tests

<HARD-RULE>
This is an AUTOMATIC workflow. No "present options to user". No "create PR with warnings".
Failures → FIX → retest → loop until clean. Then proceed.
</HARD-RULE>

Baseline file: `.ai/test-results/<branch-name>/baseline-failures.txt` (created by executing-plans/subagent-driven-development).

- **Baseline exists with listed failures** → those specific tests are pre-existing, acceptable. All OTHER failures must be fixed.
- **No baseline file** → everything was passing during execution. ALL failures are regressions — fix them all.

```
FIX LOOP:
1. Parse failed test names (exclude pre-existing from baseline if it exists)
2. Fix the code (not the test — unless test itself is wrong)
3. Re-run: ./cli.py test run -g all
4. Still failing? → back to 1
5. Clean? → continue to Task 6
```

### Task 7: Fix Loop — E2E Tests

E2E Docker is already running from Task 2.

```bash
./cli.py e2e test all 2>&1 | tee .ai/test-results/<branch-name>/final-e2e.log
```

Same fix loop as Task 6. Baseline: `baseline-e2e.log`. No baseline = all were passing = fix everything.

After E2E passes:
```bash
./cli.py e2e down
```

### Task 8: Push + Auto-PR

```bash
git push -u origin <feature-branch>
```

At this point ALL tests pass (or only have documented pre-existing failures with baseline evidence). Auto-create PR — no questions asked.

**PR body template:**

```markdown
## Summary
[From feature file: Co to jest — 2-3 sentences]

## What was built
[From feature file: Co można zrobić — bullet points]

## Screenshots
[From .ai/screenshots/<branch-name>/ — use github.com/raw/ URLs for private repos]
![Description](https://github.com/<org>/<repo>/raw/<branch>/.ai/screenshots/<branch-name>/filename.png)
[If no UI changes: "No frontend changes in this feature."]

## Test Results

### Backend
| Metric | Baseline | Final |
|--------|----------|-------|
| Passed | X | X |
| Failed | Y | Y |
| New failures | — | **0** |

<details><summary>Pre-existing failures (N)</summary>

- test_name_1
- test_name_2

Evidence: .ai/test-results/<branch>/baseline.log
</details>

### E2E
- **Status:** PASSED (X passed, 0 failed)
- **Log:** .ai/test-results/<branch>/e2e.log

## Quality Audit
[From summary.md: totals + per-agent ratings]

| Category | Count |
|----------|-------|
| Fixed | X |
| False positive | Y |
| Deferred | Z |

## Deferred Issues
[From issues.md: table, or "None"]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Task 9: Monitor GH Actions (MANDATORY — ALL CHECKS GREEN)

<HARD-RULE>
The feature is NOT done until ALL GitHub Actions checks are GREEN.
No partial passes. No "it's just a flaky test". No skipping.
ALL checks GREEN = done. Anything else = fix loop.
</HARD-RULE>

After PR is created, CI must pass — not just local tests.

1. Spawn `rr:workflow-monitor` agent to wait for PR checks
2. **ALL GREEN** → proceed to Task 10
3. **ANY RED** → spawn `rr:workflow-fixer` agent with error logs → fix → commit → push → back to monitor

```
FIX LOOP:
1. workflow-monitor reports failure + error logs
2. workflow-fixer reads logs, fixes code, verifies locally, commits
3. git push (triggers new CI run)
4. workflow-monitor waits for new run
5. Still failing? → back to 2
6. ALL GREEN? → Task 10
```

**If a check is genuinely flaky:** Re-run it ONCE. If it fails again — it's real. Fix it.
**If a check is unrelated to your changes:** Fix it anyway or get user approval to proceed.

### Task 10: Cleanup

Clean up worktree if applicable. If Option 4 (discard) was chosen, confirm first.

## Red Flags — STOP

| Thought | Reality |
|---------|---------|
| "Tests passed during execution" | Per-task ≠ full suite. Run `-g all`. |
| "These failures are pre-existing" | Without baseline evidence? Fix them. |
| "E2E is slow, skip it" | E2E is mandatory. Full suite. |
| "Only 1 .css changed, skip visual" | Any frontend file = visual verification. |
| "Let me ask if visual is needed" | NEVER ask. Check diff. Act. |
| "No baseline, these are pre-existing" | No baseline = all were passing. Every failure is a regression. Fix it. |
| "0 new failures" (no baseline) | No baseline means everything passed before. Any failure = new. |
| "Let me ask what to do" | This is automatic. Fix → retest → loop → PR. |
| "Create PR with warnings" | NO. Fix first. PR only when clean. |
| "GH Actions will pass, skip monitoring" | Local passing ≠ CI passing. Monitor. Always. |
| "CI failure is flaky, ignore it" | Re-run once. Still failing = real issue. Fix it. |

## Integration

**Called by:** `subagent-driven-development`, `executing-plans` — after pre-merge-review
**Requires:** `pre-merge-review` completed (Task 0), `feature-context` (Task 1)
**Uses:** `docs-review` (Task 2), `visual-verification` (Task 4, automatic), `rr:workflow-monitor` (Task 9), `rr:workflow-fixer` (Task 9, on failure)
**Reads:** `.ai/test-results/<branch>/baseline-failures.txt` from executor skills
