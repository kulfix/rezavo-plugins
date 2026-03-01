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

### Step 3: Update Feature File & Gate (REQUIRED)

After ALL tasks complete and verified:
1. Update feature file status (use `feature-context` skill)
2. **RUN `/pre-merge-review`** — this runs 3 audit rounds (6 auditors each), fixes between rounds, saves reports
3. Gate presents final summary and asks for user approval
4. After approval → `rrz:finishing-a-development-branch`

**DO NOT proceed to finishing-a-development-branch without completing /pre-merge-review.**

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
- After last task: update feature file → /pre-merge-review

## Integration

**Required workflow skills:**
- **feature-context** - REQUIRED: Load at start, update per task, update at end
- **pre-merge-review** - REQUIRED: Run after last task, 3 audit rounds (incl. Diogenes) + fixes + approval
- **rrz:using-git-worktrees** - Set up isolated workspace before starting
- **rrz:writing-plans** - Creates the plan this skill executes
- **rrz:finishing-a-development-branch** - Complete development after pre-merge-review passes
