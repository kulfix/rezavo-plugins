---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute tasks in batches, report for review between batches.

**Core principle:** Batch execution with checkpoints for architect review.

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

### Step 2: Execute Batch
**Default: First 3 tasks**

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Report
When batch complete:
- Show what was implemented
- Show verification output
- Say: "Ready for feedback."

### Step 4: Continue
Based on feedback:
- Apply changes if needed
- Execute next batch
- Repeat until complete

### Step 5: Update Feature File & Audit (REQUIRED)

After ALL tasks complete and verified:
1. Update feature file status (use `feature-context` skill)
2. **RUN `/audit`** — this runs 5 auditors in parallel (Fletcher, Javert, Paranoik, Dr. House, DBA)
3. Fix any Critical/Important findings from audit
4. Then use `rr:finishing-a-development-branch` to complete

**DO NOT create PR or merge without completing /audit.**

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker mid-batch (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Load feature context FIRST (Step 0)
- Review plan critically
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Between batches: just report and wait
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent
- After last task: update feature file + run /audit

## Integration

**Required workflow skills:**
- **feature-context** - REQUIRED: Load at start, update at end
- **audit** - REQUIRED: Run after last task, before merge/PR
- **rr:using-git-worktrees** - Set up isolated workspace before starting
- **rr:writing-plans** - Creates the plan this skill executes
- **rr:finishing-a-development-branch** - Complete development after audit passes
