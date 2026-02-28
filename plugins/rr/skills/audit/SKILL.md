---
name: audit
description: >
  Use after completing feature implementation, finishing executing-plans or subagent-driven-development,
  before merge or PR creation
---

# Audit Gate

5 auditors in parallel to verify implementation quality before merge.

## Overview

Dispatch 5 Agent tool calls in ONE message. Each reviews a different aspect.
Scope = feature file `files:` field (preferred) or full branch diff (fallback).

## Scope Resolution

```
/audit           → feature file files: (default)
/audit branch    → git diff against main/master (full branch)
/audit <name>    → specific .ai/features/<name>.md
```

### Resolve steps

1. Find feature file: `.ai/features/` matching current branch
2. Read `files:` from frontmatter — **this is the scope**
3. If `files:` empty/missing → fallback:
   ```bash
   git diff $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)...HEAD --name-only
   ```
4. Read `plans:` from frontmatter — spec for Javert

## Agents

| Agent | subagent_type | Reviews |
|-------|---------------|---------|
| Fletcher | Fletcher - code reviewer | Code quality on scoped files |
| Javert | Javert - completeness auditor | Spec (`plans:`) vs implementation |
| Paranoik | Paranoik - tenant debugger | Tenant isolation on scoped files |
| Dr. House | Dr. House - test auditor | Test quality for new/changed tests |
| DBA | DBA - migration reviewer | New Alembic migrations only |

## Agent Prompt

Each agent gets:

```
Review scope: [files from scope resolution]
Feature: [name from feature file]
Spec/plans: [plans: from frontmatter]
Focus ONLY on scoped files, not legacy code.
```

## Execution

1. Resolve scope
2. Dispatch 5 Agent tool calls — ONE message, parallel
3. Wait for all results
4. Show summary
5. **Critical = MUST FIX.** Suggestion = report to user

## Results Format

```
AUDIT RESULTS
─────────────
Fletcher:  [TEMPO/DRAGGING/RUSHING]          — X issues (Y critical)
Javert:    [DELIVERED/INCOMPLETE]             — X/Y requirements met
Paranoik:  [ISOLATED/SUSPICIOUS/COMPROMISED]  — X findings
Dr. House: [HEALTHY/SYMPTOMATIC/TERMINAL]     — X findings
DBA:       [SAFE/RISKY/DANGEROUS]             — X findings
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| No feature file exists | Create with **rr:feature-context** first |
| Empty `files:` | Update during executing-plans, or use `/audit branch` |
| Not fixing Critical issues | Critical = blocker before merge |
| Running on wrong branch | Verify branch matches feature file `branch:` field |

**REQUIRES:** rr:feature-context (for scope resolution)
