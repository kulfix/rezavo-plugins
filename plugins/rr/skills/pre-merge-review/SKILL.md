---
name: pre-merge-review
description: >
  Use as the final quality step before PR creation.
  Runs 3 audit rounds with fixes between them, produces reports and summary.
---

# Pre-Merge Review

3-round audit cycle: audit → fix → report × 3, then summary.

## Overview

Orchestrate 3 rounds of `/audit` + fix. Each round:
1. Run `rr:audit` (6 agents, findings, triage, tasks)
2. Execute all tasks (fix findings)
3. Commit fixes
4. Save audit report to file

After 3 rounds: generate summary + present to user. Done.

Pre-merge-review does NOT create PRs — that's the caller's responsibility (executing-plans or user).

## Invocation

```
/pre-merge-review           → feature file from current branch (default)
/pre-merge-review branch    → full branch diff scope
/pre-merge-review <name>    → specific .ai/features/<name>.md
```

Pass arguments through to `rr:audit`.

## Directory Structure

All reports go in `.ai/audit/<branch-name>/` (branch `/` → `-`):

```
.ai/audit/<branch-name>/
├── round-1.md
├── round-2.md
├── round-3.md
├── summary.md      ← generated after 3 rounds
└── issues.md        ← deferred findings (created by audit skill)
```

Clean up the branch directory before starting (if re-run). Preserve other branches.

## Execution

### Setup

1. Determine `<branch-name>` from current git branch (replace `/` with `-`)
2. Create `.ai/audit/<branch-name>/` directory
3. Clean up old reports in that directory (if re-run)

### Round 1

1. Invoke `rr:audit` skill (pass scope arguments through)
2. Audit creates tasks from MUST FIX findings, writes DEFERRED to issues.md
3. Execute all tasks as subagents (one Agent per task)
4. Commit: `fix: audit round 1 — [summary of fixes]`
5. Save report: `.ai/audit/<branch-name>/round-1.md`

### Round 2

1. Invoke `rr:audit` again (same scope)
2. New findings = new tasks
3. Execute all tasks as subagents
4. Commit: `fix: audit round 2 — [summary of fixes]`
5. Save report: `.ai/audit/<branch-name>/round-2.md`
6. In report, note which findings are NEW vs REMAINING from round 1

### Round 3

1. Invoke `rr:audit` again (same scope)
2. If clean → note "clean pass" in report
3. If findings remain → fix them as subagents, commit: `fix: audit round 3 — final cleanup`
4. Save report: `.ai/audit/<branch-name>/round-3.md`

### Fixing Tasks — Subagents

Dispatch each fix task as a `general-purpose` Agent.

```
Agent tool call per task:
  subagent_type: general-purpose
  prompt: "Fix: [task description from TaskCreate]. File: [path]. Problem: [what]. Fix: [how]."
```

Run independent fix tasks in parallel where possible. Wait for all to complete before committing.

### Report File Format

Each `round-N.md`:

```markdown
# Audit Round N

**Date:** YYYY-MM-DD
**Feature:** [name]
**Branch:** [branch]
**Scope:** [N files]

## Findings

| # | Agent | Severity | File | Problem | Status |
|---|-------|----------|------|---------|--------|
| 1 | Fletcher | Critical | app/foo.py:42 | N+1 query | FIXED |
| 2 | Paranoik | Important | app/bar.py:10 | Missing tenant check | FIXED |
| 3 | Dr. House | Minor | tests/test_foo.py:5 | Weak assertion | FALSE POSITIVE — [reason] |
| 4 | Fletcher | Important | app/bar.py:20 | Hardcoded URL | DEFERRED — pre-existing, extract to settings |

## Per-Agent Summary

Fletcher:  [TEMPO/DRAGGING/RUSHING] — X findings
Javert:    [DELIVERED/INCOMPLETE] — X/Y requirements
Paranoik:  [ISOLATED/SUSPICIOUS/COMPROMISED] — X findings
Dr. House: [HEALTHY/SYMPTOMATIC/TERMINAL] — X findings
DBA:       [SAFE/RISKY/DANGEROUS] — X findings
Diogenes:  [CLEAN/SIMPLIFIED/COMPLEX] — X findings

## Result

X findings total: Y fixed, Z false positives, W deferred
```

### Generate Summary

After all 3 rounds, generate `.ai/audit/<branch-name>/summary.md`:

```markdown
# Pre-Merge Review Summary

**Feature:** [name]
**Branch:** [branch]
**Date:** YYYY-MM-DD

## Round 1
X findings: Y fixed, Z false positive, W deferred

| # | Agent | Severity | File | Problem | Status |
|---|-------|----------|------|---------|--------|
| ... full table from round-1.md ... |

## Round 2
[same format]

## Round 3
[same format]

## Totals

| Category | Count |
|----------|-------|
| Fixed | X |
| False positive | Y |
| Deferred | Z |
| **Total findings** | **N** |

## Deferred Issues

→ See `issues.md` in this directory (X items)

## Per-Agent Final Rating

Fletcher:  [final rating] — X total findings
Javert:    [final rating] — X/Y requirements met
Paranoik:  [final rating] — X total findings
Dr. House: [final rating] — X total findings
DBA:       [final rating] — X total findings
Diogenes:  [final rating] — X total findings
```

### Present to User

After generating summary, show the user:

```
PRE-MERGE REVIEW COMPLETE
═════════════════════════
Feature: [name]
Branch: [branch]

3-ROUND AUDIT
─────────────
Round 1: X findings → Y fixed, Z false positive, W deferred
Round 2: X findings → Y fixed, Z false positive, W deferred
Round 3: X findings (should be 0)

TOTALS: X fixed, Y false positive, Z deferred

DEFERRED ISSUES (Z items)
─────────────────────────
[list from issues.md, or "None"]

REPORTS
───────
.ai/audit/<branch-name>/summary.md
.ai/audit/<branch-name>/issues.md
```

Do NOT ask "Approve for PR?" — the caller decides what to do next.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Skipping rounds | ALWAYS run 3 rounds — fixes may introduce new issues |
| Not saving reports | Every round MUST produce a report file |
| Reports in wrong directory | Use `.ai/audit/<branch-name>/`, not `.ai/audit/` |
| Asking for PR approval | Pre-merge-review does NOT create PRs, just reports |
| Fixing inside audit | Audit reports. Pre-merge-review orchestrates fixing between audits. |
| Not committing between rounds | Each round's fixes get their own commit |

**USES:** rr:audit
