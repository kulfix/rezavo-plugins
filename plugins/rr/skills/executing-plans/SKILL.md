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

### Step 2: Execute ALL Tasks

Execute every task from the plan sequentially. Do NOT stop between tasks to ask for feedback.

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed
5. Update feature file `files:` with changed files
6. Move to next task immediately

**Only stop if blocked** — see "When to Stop" below.

### Step 3: Simplify (REQUIRED)

After all tasks complete, before audit:
- Run `/simplify` to auto-fix code reuse, quality, and efficiency issues
- This cleans up implementation before audit reviewers see it

### Step 4: Update Feature File & Audit (REQUIRED)

After ALL tasks complete and verified:
1. Update feature file status (use `feature-context` skill)
2. **RUN `/audit`** — this runs 5 auditors in parallel (Fletcher, Javert, Paranoik, Dr. House, DBA)
3. Fix any Critical/Important findings from audit
4. Then use `rr:finishing-a-development-branch` to complete

**DO NOT create PR or merge without completing /audit.**

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
- After last task: simplify → update feature file → /audit

## Integration

**Required workflow skills:**
- **feature-context** - REQUIRED: Load at start, update per task, update at end
- **simplify** - REQUIRED: Run after last task, before audit
- **audit** - REQUIRED: Run after simplify, before merge/PR
- **rr:using-git-worktrees** - Set up isolated workspace before starting
- **rr:writing-plans** - Creates the plan this skill executes
- **rr:finishing-a-development-branch** - Complete development after audit passes
