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

### Step 2: Execute ALL Tasks via Sonnet Subagents

Dispatch each task as a **Sonnet subagent** (`model: "sonnet"`, `subagent_type: "general-purpose"`).
The plan is already written — Sonnet implements, Opus orchestrates.

For each task:
1. Mark as in_progress
2. Dispatch as Sonnet subagent with full task context:
   ```
   Agent tool call:
     subagent_type: general-purpose
     model: sonnet
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

**Parallel dispatch:** If tasks are independent (no shared state), dispatch multiple Sonnet subagents in parallel.
**Sequential tasks:** If task N depends on task N-1, wait for completion before dispatching.

**Only stop if blocked** — see "When to Stop" below.

### Step 3: Finish Feature File (REQUIRED)

After ALL tasks complete and verified:

1. Use `feature-context` skill — follow the **Finishing branch** checklist
2. Set `status: done`, replace dev sections with business documentation sections
3. Verify feature file contains: Co to jest, Po co to, Co można zrobić, Jak używać, Decyzje, Nie w scope

### Step 4: Audit & PR (REQUIRED)

1. **RUN `/pre-merge-review`** — 3 audit rounds, fixes between rounds, saves reports + summary + issues
2. Push branch and create PR (target: `base_branch` from feature file)

**PR body** — generated from 3 sources:

| Source | PR section |
|--------|-----------|
| Feature file (`Co to jest` + `Po co to`) | **Summary** — business problem and solution |
| Feature file (`Co można zrobić`) | **What was built** — user-facing capabilities |
| `.ai/audit/<branch>/summary.md` | **Quality Audit** — totals + per-agent ratings |
| `.ai/audit/<branch>/issues.md` | **Deferred Issues** — table, or "None" |

```bash
gh pr create --base <base-branch> --title "<feature name>" --body "$(cat <<'EOF'
## Summary
[From feature file: Co to jest + Po co to]

## What was built
[From feature file: Co można zrobić]

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

If any source file doesn't exist, skip that section.

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
- After last task: finish feature file (Step 3) → /pre-merge-review → PR (Step 4)

## Integration

**Required workflow skills:**
- **feature-context** - REQUIRED: Load at start, update per task, update at end
- **pre-merge-review** - REQUIRED: Run after last task, 3 audit rounds (incl. Diogenes) + fixes + approval
- **rr:using-git-worktrees** - Set up isolated workspace before starting
- **rr:writing-plans** - Creates the plan this skill executes
- **rr:finishing-a-development-branch** - For manual use (standalone branch completion with 4 options)
