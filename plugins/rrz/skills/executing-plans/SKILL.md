---
name: executing-plans
description: Use when you have a written implementation plan to execute — runs all tasks autonomously, stops only on blockers
---

# Executing Plans

## Overview

Load plan, review critically, execute ALL tasks autonomously. Stop only on blockers.

**Core principle:** The plan is already approved. Execute it fully without waiting for permission between tasks.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 0: Load Feature Context (REQUIRED)

Before anything else:
1. Use `feature-context` skill to find and read the active feature file for this branch
2. Read the feature file content — understand status, blocked_by, plans
3. This step is NON-NEGOTIABLE — even after context restore

### Step 1: Load and Review Plan
1. Read plan file (from feature file frontmatter `plans:`)
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Step 2: Execute ALL Tasks via Subagents

Dispatch each task as a subagent (`subagent_type: "general-purpose"`).
The plan is already written — subagents implement, orchestrator manages.

For each task:
1. Mark as in_progress
2. Dispatch as subagent with full task context:
   ```
   Agent tool call:
     subagent_type: general-purpose
     prompt: |
       Task: [task subject]
       [full task description from plan]
       Project root: [cwd]
       Feature file: [path]
       Verify: [verification steps from plan]
   ```
3. When subagent completes: review result, verify it worked
4. Mark as completed
5. Update feature file `files:` with changed files
6. Move to next task immediately

**Parallel dispatch:** If tasks are independent (no shared state), dispatch multiple subagents in parallel.
**Sequential tasks:** If task N depends on task N-1, wait for completion before dispatching.

**Only stop if blocked** — see "When to Stop" below.

### Step 3: Write Business Documentation (REQUIRED)

After ALL tasks complete and verified, **BEFORE audit**:

<HARD-RULE>
Replace dev sections (Co zrobione/TODO/Known issues) in feature file with business documentation.
The feature file MUST contain these sections BEFORE creating a PR:

```markdown
## Co to jest
1-2 zdania: co robi ten feature z perspektywy użytkownika/biznesu.

## Po co to
Jaki problem biznesowy rozwiązuje.

## Co można zrobić
Lista możliwości z perspektywy użytkownika — CO może zrobić, nie JAK zaimplementowane.

## Jak używać
Krok po kroku dla użytkownika.

## Decyzje
| Decyzja | Dlaczego |
|---------|----------|

## Nie w scope
Co świadomie pominięto.
```

This is NON-NEGOTIABLE. If feature file has no "Co to jest" section → STOP and write it.
PR body is generated FROM these sections — without them, PR will be empty/technical garbage.
</HARD-RULE>

### Step 4: Audit & PR (REQUIRED)

1. **RUN `/pre-merge-review`** — 3 audit rounds (6 auditors each), fixes between rounds, saves reports + summary + issues
2. **Verify feature file still has business sections** (audit fixes might have broken it)
3. Push branch and create PR (target: `base_branch` from feature file)

**PR body** is generated from 3 sources:

1. **Feature file** (`.ai/features/<name>.md`) → Summary + What was built
2. **Audit summary** (`.ai/audit/<branch>/summary.md`) → Quality Audit section
3. **Issues** (`.ai/audit/<branch>/issues.md`) → Deferred Issues section

PR body MUST start with business context (problem → solution → what user can do), NOT technical details.

```bash
gh pr create --base <base-branch> --title "<feature name>" --body "$(cat <<'EOF'
## Summary
[From feature file: Co to jest + Po co to — business problem and solution, 2-3 sentences]

## What was built
[From feature file: Co można zrobić — user-facing capabilities, bullet points]

## Quality Audit
[From summary.md: totals + per-agent ratings]

| Category | Count |
|----------|-------|
| Fixed | X |
| False positive | Y |
| Deferred | Z |

## Deferred Issues
[From issues.md: table, or "None"]

## Test Plan
- [ ] [verification steps from plan]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

If any source file doesn't exist, skip that section (don't crash).

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing. Then resume from where you stopped.**

Do NOT stop for:
- Routine progress updates (just keep going)
- Asking "should I continue?" (yes, always continue)
- Reporting what you just did (report at the end)

## Remember
- Load feature context FIRST (Step 0)
- Review plan critically at start
- Then execute ALL tasks without stopping
- Follow plan steps exactly
- Don't skip verifications
- Stop ONLY when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent
- After last task: **write business docs in feature file (Step 3)** → /pre-merge-review → PR (Step 4)
- PR body starts with BUSINESS context, not technical details

## Integration

**Required workflow skills:**
- **feature-context** - REQUIRED: Load at start, update per task, update at end
- **pre-merge-review** - REQUIRED: Run after last task, 3 audit rounds (incl. Diogenes) + fixes + approval
- **rrz:using-git-worktrees** - Set up isolated workspace before starting
- **rrz:writing-plans** - Creates the plan this skill executes
- **rrz:finishing-a-development-branch** - For manual use (standalone branch completion with 4 options)
