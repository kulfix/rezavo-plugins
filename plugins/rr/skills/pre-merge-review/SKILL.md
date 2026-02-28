---
name: pre-merge-review
description: >
  Use as the final quality step before merge or PR creation.
  Runs 3 audit rounds with fixes between them, produces reports,
  and presents final summary for user approval.
---

# Pre-Merge Review

3-round audit cycle: audit → fix → report × 3, then summary for user approval.

## Overview

Orchestrate 3 rounds of `/audit` + fix. Each round:
1. Run `rr:audit` (6 agents, findings, triage, tasks)
2. Execute all tasks (fix findings)
3. Commit fixes
4. Save audit report to file

After 3 rounds: present final summary. Wait for user approval. Then proceed to PR.

## Invocation

```
/pre-merge-review           → feature file from current branch (default)
/pre-merge-review branch    → full branch diff scope
/pre-merge-review <name>    → specific .ai/features/<name>.md
```

Pass arguments through to `rr:audit`.

## Execution

### Round 1

1. Invoke `rr:audit` skill (pass scope arguments through)
2. Audit creates tasks from findings
3. Execute all tasks as **Sonnet subagents** (one Agent per task, `model: "sonnet"`)
4. Commit: `fix: audit round 1 — [summary of fixes]`
5. Save report: `.ai/audit/round-1.md`

### Round 2

1. Invoke `rr:audit` again (same scope)
2. New findings = new tasks
3. Execute all tasks as **Sonnet subagents**
4. Commit: `fix: audit round 2 — [summary of fixes]`
5. Save report: `.ai/audit/round-2.md`
6. In report, note which findings are NEW vs REMAINING from round 1

### Round 3

1. Invoke `rr:audit` again (same scope)
2. If clean → note "clean pass" in report
3. If findings remain → fix them as **Sonnet subagents**, commit: `fix: audit round 3 — final cleanup`
4. Save report: `.ai/audit/round-3.md`

### Fixing Tasks — Dispatch Mode

Fix tasks follow the same dispatch mode as audit (check `ZAI_API_KEY`).

**Agent tool mode** (no ZAI_API_KEY):
```
Agent tool call per task:
  subagent_type: general-purpose
  model: sonnet
  prompt: "Fix: [task description]. File: [path]. Problem: [what]. Fix: [how]."
```

**Z.AI dispatch mode** (ZAI_API_KEY set):
```bash
# Per task — run independent fixes in parallel (run_in_background: true)
${CLAUDE_PLUGIN_ROOT}/scripts/zai-dispatch.sh \
  "Fix: [task description]. File: [path]. Problem: [what]. Fix: [how]." \
  /opt/pytek
```

Run independent fix tasks in parallel where possible. Wait for all to complete before committing.

**SEQUENTIAL fixes:** If fix B depends on fix A (same file), run them sequentially.

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

## Per-Agent Summary

Fletcher:  [TEMPO/DRAGGING/RUSHING] — X findings
Javert:    [DELIVERED/INCOMPLETE] — X/Y requirements
Paranoik:  [ISOLATED/SUSPICIOUS/COMPROMISED] — X findings
Dr. House: [HEALTHY/SYMPTOMATIC/TERMINAL] — X findings
DBA:       [SAFE/RISKY/DANGEROUS] — X findings
Diogenes:  [CLEAN/SIMPLIFIED/COMPLEX] — X findings

## Result

X findings total: Y fixed, Z false positives
```

### Final Summary

After all 3 rounds, present to user:

```
PRE-MERGE REVIEW SUMMARY
═════════════════════════
Feature: [name]
Branch: [branch]

WHAT WAS BUILT
──────────────
- [bullet points: what the feature does]
- [key architectural decisions]
- [key files created/modified]
- [how it works — brief flow]

3-ROUND AUDIT
─────────────
Round 1: X findings → Y fixed, Z false positive
Round 2: X findings → Y fixed, Z false positive
Round 3: X findings (should be 0)

PER-AGENT ACROSS ALL ROUNDS
────────────────────────────
Fletcher:  [final rating] — X total findings
Javert:    [final rating] — X/Y requirements met
Paranoik:  [final rating] — X total findings
Dr. House: [final rating] — X total findings
DBA:       [final rating] — X total findings
Diogenes:  [final rating] — X total findings

REPORTS
───────
- .ai/audit/round-1.md
- .ai/audit/round-2.md
- .ai/audit/round-3.md
```

Then ask user: **"Pre-merge review complete. Approve for PR?"**

- **Yes** → invoke `rr:finishing-a-development-branch`
- **No** → user gives feedback, address it, re-run or fix specific issues

## Directory Structure

Reports go in `.ai/audit/` relative to project root:

```
.ai/
├── features/
│   └── my-feature.md
└── audit/
    ├── round-1.md
    ├── round-2.md
    └── round-3.md
```

Clean up old audit reports before starting (from previous runs on same branch).

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Skipping rounds | ALWAYS run 3 rounds — fixes may introduce new issues |
| Not saving reports | Every round MUST produce a `.ai/audit/round-N.md` file |
| Proceeding without approval | ALWAYS wait for user to approve before PR |
| Fixing inside audit | Audit reports. Pre-merge-review orchestrates fixing between audits. |
| Not committing between rounds | Each round's fixes get their own commit |

**USES:** rr:audit, rr:finishing-a-development-branch
