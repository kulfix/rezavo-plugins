---
name: pre-merge-review
description: >
  Use as the final quality step before PR creation, after implementation is complete
---

# Pre-Merge Review

2-round audit cycle: audit → fix → report, then conditional R2, then summary.

**Core principle:** Orchestrate audits. All scope resolution is done by `rr:audit` — this skill only manages rounds, fixes, and reports.

Pre-merge-review does NOT create PRs — that's the caller's responsibility.

## Invocation

```
/pre-merge-review           → feature file from current branch (default)
/pre-merge-review branch    → full branch diff scope
/pre-merge-review <name>    → specific .ai/features/<name>.md
```

Pass arguments through to `rr:audit`.

## The Process

### Step 1: Setup

1. Get branch name: `git branch --show-current`
2. Convert to directory name (replace `/` with `-`)
3. Create `.ai/audit/<branch-name>/` directory
4. Clean old reports in that directory (if re-run). Preserve other branches' directories.

### Step 2: Round 1 — Audit

Invoke `rr:audit` skill (pass scope arguments through).

Audit handles everything: reads feature file, resolves scope, dispatches agents, triages findings, creates tasks.

### Step 3: Round 1 — Fix Tasks

Execute all MUST FIX tasks from Round 1 as subagents:

```
Agent tool call per task:
  subagent_type: general-purpose
  prompt: "Fix: [task description]. File: [path]. Problem: [what]. Fix: [how]."
```

Run independent tasks in parallel. Wait for all to complete.

### Step 4: Round 1 — Commit + Report

1. Commit fixes: `fix: audit round 1 — [summary of fixes]`
2. Save report to `.ai/audit/<branch-name>/round-1.md`

Report format:

```markdown
# Audit Round 1

**Date:** YYYY-MM-DD
**Feature:** [name]
**Branch:** [branch]
**Scope:** [N files]

## Findings

| # | Agent | Severity | File | Problem | Status |
|---|-------|----------|------|---------|--------|
| 1 | Fletcher | Critical | app/foo.py:42 | N+1 query | FIXED |
| 2 | Paranoik | Important | app/bar.py:10 | Missing tenant check | FIXED |
| 3 | Fletcher | Minor | app/baz.py:5 | Naming | FALSE POSITIVE — [reason] |

## Per-Agent Summary

Fletcher:  [TEMPO/DRAGGING/RUSHING] — X findings
Paranoik:  [ISOLATED/SUSPICIOUS/COMPROMISED] — X findings
Javert:    [DELIVERED/INCOMPLETE/ABANDONED] — X/Y requirements

## Result

X findings total: Y fixed, Z false positives, W deferred
```

### Step 5: Round 2 Decision

**Skip R2 if:** R1 had 0 MUST FIX AND 0 DEFERRED → go to Step 8.

**Run R2 if:** R1 had ANY MUST FIX or DEFERRED.

### Step 6: Round 2 — Audit (regression check)

Invoke `rr:audit` with ONLY Fletcher + Paranoik (2 agents). Focus: verify R1 fixes didn't introduce regressions.

### Step 7: Round 2 — Fix + Commit + Report

Same as Steps 3-4 but for Round 2:
1. Execute fix tasks as subagents
2. Commit: `fix: audit round 2 — [summary]`
3. Save report: `.ai/audit/<branch-name>/round-2.md`
4. Note which findings are NEW vs REMAINING from R1

### Step 8: Generate Summary

Write `.ai/audit/<branch-name>/summary.md`:

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
[same format, or "Skipped — R1 clean"]

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
Paranoik:  [final rating] — X total findings
Javert:    [final rating] — X/Y requirements met
```

### Step 9: Present to User

```
PRE-MERGE REVIEW COMPLETE
═════════════════════════
Feature: [name]
Branch: [branch]

2-ROUND AUDIT
─────────────
Round 1: X findings → Y fixed, Z false positive, W deferred
Round 2: X findings → Y fixed, Z false positive, W deferred
         (or: "Skipped — R1 clean")

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
| Running git diff yourself | Audit handles scope. Step 1 is directory setup only. |
| Skipping R2 prematurely | R2 required if R1 had ANY MUST FIX or DEFERRED |
| Running R2 when R1 clean | Skip R2 if 0 MUST FIX and 0 DEFERRED |
| Not saving reports | Every round MUST produce a report file |
| Reports in wrong directory | Use `.ai/audit/<branch-name>/` |
| Fixing inside audit | Audit reports. This skill fixes between audits. |
| Not committing between rounds | Each round's fixes get their own commit |

**USES:** rr:audit
