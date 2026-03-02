---
name: finishing-a-development-branch
description: Use when implementation and pre-merge-review are complete, to run final tests, visual verification, E2E, and create PR
---

# Finishing a Development Branch

## Overview

Final gate before PR: verify tests, take screenshots, run E2E, auto-create PR.

**Core principle:** Verify gate → Update feature file → Visual verification (automatic) → Final tests + compare with baseline → E2E → Auto-PR.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## The Process

### Step 0: Verify Gate (REQUIRED)

`<base-branch>` = value from `<branch-context>` injected at session start. If UNKNOWN or missing → **ASK user.** Do NOT assume `main`.

1. Check if `/pre-merge-review` was run (look for `.ai/audit/<branch-name>/summary.md`)
2. If NOT — **STOP. Run `/pre-merge-review` first.**

All subsequent steps use `<base-branch>` — NEVER hardcode `main`.

### Step 1: Update Feature File

Use `feature-context` skill: set `status: done`, verify all plan items reflected.

### Step 2: Start Docker Environment

```bash
./cli.py e2e up    # rebuild — has backend + frontend + postgres + redis
```

Verify containers healthy before proceeding. Keep running through Steps 3-5.

`e2e up` includes everything `test up` has PLUS frontend — needed for visual verification (Step 3).

### Step 3: Visual Verification (AUTOMATIC)

<HARD-RULE>
NEVER ask if visual verification is needed. Check the diff automatically.
If ANY frontend file changed — run visual verification. No exceptions.
</HARD-RULE>

```bash
git diff <base-branch>...HEAD --name-only | grep -E 'frontend/|\.(tsx|jsx|html|css|scss|jinja)$'
```

- **Matches found:** Run `rr:visual-verification` skill. Docker is already running — skill should skip startup.
- **No matches:** Skip. Log: "No frontend files in diff — skipping visual verification."

### Step 4: Final Backend Tests

```bash
./cli.py test run -g all 2>&1 | tee .ai/test-results/<branch-name>/final.log
```

Parse pytest summary. Extract failed test names to `final-failures.txt`.

### Step 5: Compare Baseline vs Final

<HARD-RULE>
Never claim failures are "pre-existing" without baseline evidence.
If baseline doesn't exist — ALL failures are unverified. WARN loudly.
</HARD-RULE>

Read `.ai/test-results/<branch-name>/baseline-failures.txt` (created by executing-plans/subagent-driven-development).

<HARD-RULE>
Failures without baseline evidence = UNVERIFIED = gate NOT passed.
You CANNOT claim "0 new failures" when there is no baseline to compare against.
No baseline + any failures → present options to user. NEVER auto-create PR.
</HARD-RULE>

| Situation | Action |
|-----------|--------|
| Zero failures | All green. Continue. |
| Pre-existing only (in both baseline AND final) | Document with evidence. Continue. |
| NEW failures (in final, not in baseline) | **STOP.** Must fix before proceeding. |
| No baseline + any failures | **STOP.** Gate NOT passed. Present to user (Step 7 fallback). |
| No baseline + zero failures | Continue (nothing to verify). |

Print summary:
```
Backend tests: X passed, Y failed
New failures: N (must fix) / 0 (clean)
Pre-existing: M (evidence: .ai/test-results/<branch>/baseline-backend.log)
```

### Step 6: E2E Tests

E2E Docker is already running from Step 2.

```bash
./cli.py e2e test all 2>&1 | tee .ai/test-results/<branch-name>/final-e2e.log
./cli.py e2e down
```

Compare with baseline E2E (`baseline-e2e.log`) — same HARD-RULE as Step 5:
- Zero failures → Continue.
- Pre-existing (in both baseline AND final) → Document with evidence. Continue.
- NEW failures (not in baseline) → **STOP.** Must fix.
- No baseline + any failures → **STOP.** Gate NOT passed. Present to user.

### Step 7: Push + Auto-PR (or Fallback)

```bash
git push -u origin <feature-branch>
```

**All gates pass → auto-create PR** (ONLY if zero failures OR all failures have baseline evidence):

```
All gates passed. Creating PR.

Audit: 3 rounds complete
Backend: X passed, 0 new failures (Y pre-existing)
E2E: PASSED
Visual: N screenshots (or "skipped — no frontend changes")
```

**Any gate fails → present options:**

```
Some gates did not fully pass:

[x] Pre-merge review: DONE
[x] Feature file: status=done
[ ] Backend tests: 2 NEW failures
[x] E2E: PASSED
[x] Visual verification: 6 screenshots

1. Create PR anyway (with warnings)
2. Fix failures first
3. Keep branch as-is
4. Discard work
```

**PR body template:**

```markdown
## Summary
[From feature file: Co to jest — 2-3 sentences]

## What was built
[From feature file: Co można zrobić — bullet points]

## Screenshots
[From .ai/screenshots/<branch-name>/ — use raw GitHub URLs, NOT file paths]
![Description](https://raw.githubusercontent.com/<org>/<repo>/<branch>/.ai/screenshots/<branch-name>/filename.png)
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

### Step 8: Cleanup

Clean up worktree if applicable. If Option 4 (discard) was chosen, confirm first.

## Red Flags — STOP

| Thought | Reality |
|---------|---------|
| "Tests passed during execution" | Per-task ≠ full suite. Run `-g all`. |
| "These failures are pre-existing" | Without baseline evidence? Hallucination. |
| "E2E is slow, skip it" | E2E is mandatory. Full suite. |
| "Only 1 .css changed, skip visual" | Any frontend file = visual verification. |
| "Let me ask if visual is needed" | NEVER ask. Check diff. Act. |
| "Baseline not found, assume clean" | No baseline + failures = gate FAILED. Present to user. |
| "0 new failures" (no baseline) | You can't have "0 new" without a baseline to compare. Gate FAILED. |

## Integration

**Called by:** `subagent-driven-development`, `executing-plans` — after pre-merge-review
**Requires:** `pre-merge-review` completed (Step 0), `feature-context` (Step 1)
**Uses:** `visual-verification` (Step 3, automatic), `rr:workflow-monitor` (optional, E2E)
**Reads:** `.ai/test-results/<branch>/baseline-failures.txt` from executor skills
