---
name: audit
description: >
  Use after completing feature implementation, finishing executing-plans or subagent-driven-development,
  before merge or PR creation
---

# Audit

3 auditors in parallel produce findings. Findings become tasks.

**Core principle:** Feature file defines scope. Read it first. Dispatch agents. Triage findings. Done.

Fixing = separate step (user runs tasks manually or via executing-plans).

## Invocation

```
/audit           → feature file files: (default)
/audit branch    → git diff against base branch (full branch)
/audit <name>    → specific .ai/features/<name>.md
```

## The Process

### Step 1: Read Feature File

Find feature file matching current branch in `.ai/features/`.

```bash
git branch --show-current
# → feature/foo → look for .ai/features/foo.md or similar
```

Read the file. Extract from frontmatter:
- `files:` — review scope
- `plans:` — spec for Javert

If no feature file exists → **STOP.** Create one with `rr:feature-context` first.

### Step 2: Determine Scope

`<base-branch>` = value from `<branch-context>` injected at session start. If UNKNOWN → **ASK user.** Do NOT assume `main`.

**If `files:` has entries → THAT IS THE SCOPE.** Do NOT run git diff. Do NOT expand scope. Go to Step 3.

**If `files:` is empty/missing → fallback to diff:**
```bash
git diff $(git merge-base HEAD origin/<base-branch>)...HEAD --name-only
```

### Step 3: Dispatch 3 Agents

Send ONE message with 3 Agent tool calls in parallel:

| Agent | subagent_type | Reviews |
|-------|---------------|---------|
| Fletcher | `rr:Fletcher - code reviewer` | Code quality, simplicity, schema |
| Paranoik | `rr:Paranoik - security auditor` | Security, tenant isolation, migrations |
| Javert | `rr:Javert - completeness auditor` | Spec vs implementation + test quality gate |

Each agent prompt:
```
Review scope: [files from Step 2]
Feature: [name from feature file]
Spec/plans: [plans: paths from frontmatter]
Focus ONLY on scoped files, not legacy code.
```

### Step 4: Triage Findings

Collect all findings from all 3 agents. Mark each as exactly one of:

| Category | When | Action |
|----------|------|--------|
| **MUST FIX** | Real issue, fix in this PR | Create task (Step 5) |
| **FALSE POSITIVE** | Agent is wrong | Explain WHY it's wrong |
| **DEFERRED** | Real issue, not this PR | Write to issues.md (Step 6) |

No other categories. Ever.

**DEFERRED restrictions:**
- Security, tenant isolation, data loss → always MUST FIX, never DEFERRED
- "too hard" is NOT valid — break into steps
- DEFERRED is NOT a trash bin — every item must have a real proposed fix
- Every DEFERRED needs ALL of: source agent + finding ID, reason why not now, proposed fix

### Step 5: Create Tasks from MUST FIX

For each MUST FIX finding:

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

Group related findings in same file into single task.

### Step 6: Write Deferred Issues

For each DEFERRED finding, append a row to `.ai/audit/<branch-name>/issues.md`.

Create the file if it doesn't exist. Format:

```markdown
# Issues: <branch-name>

Deferred findings from pre-merge review — to verify after merge.

| # | Round | Agent | Finding | File | Problem | Proposed fix | Status |
|---|-------|-------|---------|------|---------|-------------|--------|
```

Each DEFERRED finding adds a row with status `open`.

`<branch-name>` = git branch with `/` → `-`.

### Step 7: Show Summary

```
AUDIT SUMMARY
═════════════
Feature: [name from feature file]
Branch: [current branch]
Scope: [N files]

Fletcher:  [TEMPO/DRAGGING/RUSHING]          — X findings
Paranoik:  [ISOLATED/SUSPICIOUS/COMPROMISED]  — X findings
Javert:    [DELIVERED/INCOMPLETE/ABANDONED]   — X/Y requirements met

Total: X findings → Y tasks created, Z false positives, W deferred

False positives (if any):
- [agent]: [finding] — REASON why false positive

Deferred (if any):
- [agent]: [finding] — REASON why deferred + proposed fix
```

Then present feature summary:

```
FEATURE SUMMARY
═══════════════
What was built:
- [bullet point summary]
- [key architectural decisions]

How it works:
- [brief flow description]
```

Build from: feature file, plans, and scoped files.

## After Audit

Tasks are created. User decides next step:
1. **Fix manually** — work through tasks one by one
2. **Run executing-plans** — batch execute tasks
3. **Re-audit** — run `/audit` again after fixes to check for regressions

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Running git diff before reading feature file | Step 1 is READ FEATURE FILE. Always. |
| Guessing base branch as `main` | Use `<base-branch>` from session context. If UNKNOWN → ASK. |
| No feature file exists | Create with **rr:feature-context** first |
| Empty `files:` | Update during executing-plans, or use `/audit branch` |
| Skipping findings as "pre-existing" | Use DEFERRED with proposed fix, not FALSE POSITIVE |
| Inventing triage categories | ONLY 3: MUST FIX, FALSE POSITIVE, DEFERRED |
| Fixing inside audit | Audit ONLY reports and creates tasks. Fixing is separate. |

**REQUIRES:** rr:feature-context (for scope resolution)
