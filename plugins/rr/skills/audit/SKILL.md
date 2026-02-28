---
name: audit
description: >
  Use after completing feature implementation, finishing executing-plans or subagent-driven-development,
  before merge or PR creation
---

# Audit

6 auditors in parallel produce findings. Findings become tasks.

## Overview

Dispatch 6 Agent tool calls in ONE message. Each reviews a different aspect.
Collect findings. Create TaskCreate per finding. Done.

Fixing = separate step (user runs tasks manually or via executing-plans).

## Scope Resolution

```
/audit           → feature file files: (default)
/audit branch    → git diff against base branch (full branch)
/audit <name>    → specific .ai/features/<name>.md
```

### Resolve steps

1. Find feature file: `.ai/features/` matching current branch
2. Read `files:` from frontmatter — **this is the scope**
3. If `files:` empty/missing → fallback: detect base branch, then diff
   ```bash
   # Detect base branch (do NOT hardcode main/master)
   BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@refs/remotes/origin/@@') \
     || BASE=$(git branch -r | grep -oP 'origin/\K(main|master)' | head -1) \
     || BASE="main"
   git diff $(git merge-base HEAD "$BASE")...HEAD --name-only
   ```
4. Read `plans:` from frontmatter — spec for Javert

<HARD-RULE>
If `files:` has entries → THAT IS THE SCOPE. Do NOT run git diff. Do NOT expand scope.
Git diff fallback is ONLY for when `files:` is empty or missing.
</HARD-RULE>

## Agents

| Agent | subagent_type | Reviews |
|-------|---------------|---------|
| Fletcher | Fletcher - code reviewer | Code quality on scoped files |
| Javert | Javert - completeness auditor | Spec (`plans:`) vs implementation |
| Paranoik | Paranoik - tenant debugger | Tenant isolation on scoped files |
| Dr. House | Dr. House - test auditor | Test quality for new/changed tests |
| DBA | DBA - migration reviewer | New Alembic migrations only |
| Diogenes | Diogenes - simplicity auditor | Code clarity, reuse, efficiency — produces REPORT (does NOT edit files) |

## Agent Prompt

Each agent gets:

```
Review scope: [files from scope resolution]
Feature: [name from feature file]
Spec/plans: [plans: from frontmatter]
Focus ONLY on scoped files, not legacy code.
```

## Execution

1. Resolve scope (files + plans)
2. Dispatch 6 Agent tool calls — ONE message, parallel
3. Wait for all results
4. Collect all findings from all agents
5. Triage (main session / Opus): mark each finding as MUST FIX or FALSE POSITIVE (with reason)
6. Create tasks from findings (see below)
7. Show audit summary

## Finding Policy

<HARD-RULE>
Every finding = MUST FIX or FALSE POSITIVE. No other categories.

BANNED excuses:
- "pre-existing" — if it's in scope, fix it
- "out of scope" — if agent found it in scoped files, it's in scope
- "too hard" — break it into steps, but fix it
- "nice to have" / "deferred" — does not exist, fix now or mark false positive
- "suggestion" — there are no suggestions, only findings

The ONLY valid reason to skip a finding is FALSE POSITIVE (agent is wrong about the issue).
If you disagree with a finding, explain WHY it's a false positive, don't just skip it.
</HARD-RULE>

## Creating Tasks from Findings

For each MUST FIX finding, create a task:

```
TaskCreate:
  subject: "[Agent] Finding-ID: brief description"
  description: |
    Source: [agent name] finding [ID]
    Severity: [Critical/Important/Minor]
    File: [path:lines]
    Problem: [what's wrong]
    Fix: [agent's suggested fix]
  activeForm: "Fixing [brief description]"
```

Group related findings into single tasks where it makes sense (e.g. 3 Fletcher findings in same file = 1 task).

## Output

### Audit Summary

```
AUDIT SUMMARY
═════════════
Feature: [name from feature file]
Branch: [current branch]
Scope: [N files]

Fletcher:  [TEMPO/DRAGGING/RUSHING]          — X findings
Javert:    [DELIVERED/INCOMPLETE]             — X/Y requirements met
Paranoik:  [ISOLATED/SUSPICIOUS/COMPROMISED]  — X findings
Dr. House: [HEALTHY/SYMPTOMATIC/TERMINAL]     — X findings
DBA:       [SAFE/RISKY/DANGEROUS]             — X findings
Diogenes:  [CLEAN/SIMPLIFIED/COMPLEX]         — X findings

Total: X findings → Y tasks created, Z false positives

False positives (if any):
- [agent]: [finding] — REASON why false positive
```

### Feature Summary

After audit, also present what was built:

```
FEATURE SUMMARY
═══════════════
What was built:
- [bullet point summary of what the feature does]
- [key architectural decisions]
- [key files created/modified]

How it works:
- [brief flow description]
```

Build this from: feature file, plans, and scoped files. Read them if needed.

## After Audit

Tasks are created. User decides next step:

1. **Fix manually** — work through tasks one by one
2. **Run executing-plans** — batch execute tasks
3. **Re-audit** — run `/audit` again after fixes to check for regressions

Recommend running `/audit` again after fixing all tasks to verify no regressions.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| No feature file exists | Create with **rr:feature-context** first |
| Empty `files:` | Update during executing-plans, or use `/audit branch` |
| Skipping findings as "pre-existing" | BANNED — fix it or mark false positive with reason |
| Diogenes editing files directly | Diogenes produces REPORT only |
| Running on wrong branch | Verify branch matches feature file `branch:` field |
| Fixing inside audit | Audit ONLY reports and creates tasks. Fixing is separate. |

**REQUIRES:** rr:feature-context (for scope resolution)
