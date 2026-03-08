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

### Task 0: Load Feature Context (REQUIRED)

Before anything else:
1. Use `feature-context` skill to find and read the active feature file for this branch
2. Read the feature file content — understand status, blocked_by, plans
3. This step is NON-NEGOTIABLE — even after context restore

### Task 1: Baseline Tests (MANDATORY)

> **Tests:** Invoke `rr:running-tests` for full context on test groups, diagnostics, and best practices.

Run ALL tests (backend + E2E) BEFORE any implementation. Creates evidence of what passes/fails before you touch code.

```bash
mkdir -p .ai/test-results/<branch-name>
./cli.py test run -g all 2>&1 | tee .ai/test-results/<branch-name>/baseline-backend.log
./cli.py e2e test all 2>&1 | tee .ai/test-results/<branch-name>/baseline-e2e.log
```

Full suite auto-restarts the stack for clean state — no manual `test up`/`test down` needed.

Parse test summaries. Extract failed test names to `baseline-failures.txt`. Note failures but DO NOT STOP — this is the known state. Commit: `"test: baseline results"`.

### Task 2: Load and Review Plan
1. Read plan file (from feature file frontmatter `plans:`)
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Task 3: Execute ALL Tasks via Subagents

<HARD-RULE>
NEVER do task work in the main context. ALWAYS dispatch as Agent subagent.

Main context ONLY:
- Read plan file (once, in Task 2)
- Dispatch Agent subagent per task
- Read subagent result (returned text, not files)
- Update TodoList status
- Update feature file `files:` field
- Run git commit

FORBIDDEN in main context:
- Read implementation files (app/, frontend/, tests/)
- Edit any file
- Run tests or builds
- Debug failures
- Analyze test output

If subagent failed → dispatch fix subagent with error context.
If verification needed → dispatch verify subagent.
</HARD-RULE>

Dispatch each task as a subagent. Choose model based on task complexity.

### Model Selection per Task

| Complexity | subagent_type | Model | When |
|------------|--------------|-------|------|
| Routine | `rr:implementer` | Sonnet | Boilerplate, CRUD, proste fixy, step-by-step z planu z gotowym kodem |
| Complex | `general-purpose` | Opus (inherit) | Architektura, security, skomplikowana logika, debugging |

**Heurystyka:**
- Task ma gotowy kod w planie (copy-paste) → **Sonnet** (`rr:implementer`)
- Task to "Create X following pattern Y" → **Sonnet**
- Task wymaga decyzji architektonicznych → **Opus** (`general-purpose`)
- Task dotyka security/tenant isolation → **Opus**
- Task wymaga debugowania nieznanego problemu → **Opus**
- Nie wiesz? → **Opus** (bezpieczny default)

The plan is already written — subagent implements, you orchestrate.

For each task:
1. Mark as in_progress
2. Assess complexity → choose subagent_type
3. Dispatch as subagent with full task context:
   ```
   Agent tool call:
     subagent_type: rr:implementer  # lub general-purpose dla złożonych tasków
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

### Task 4: Finish Feature File (REQUIRED)

After ALL tasks complete and verified:

1. Use `feature-context` skill — follow the **Finishing branch** checklist
2. Set `status: done`, replace dev sections with business documentation sections
3. Verify feature file contains: Co to jest, Po co to, Co można zrobić, Jak używać, Decyzje, Nie w scope

### Task 5: Audit & PR (REQUIRED)

1. **RUN `/pre-merge-review`** — 2 audit rounds (R2 conditional), fixes between rounds, saves reports + summary + issues
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

## Red Flags — STOP

| Thought | Reality |
|---------|---------|
| "Let me read X to understand first" | Subagent will read it. You dispatch. |
| "Let me check the test results" | Subagent reports results. Trust or dispatch verify subagent. |
| "This task is too small for a subagent" | Subagent startup < context pollution. Always delegate. |
| "Let me quickly fix this myself" | Context pollution. Dispatch fix subagent. |
| "Let me refresh my memory on the plan" | You read the plan once in Task 2. Don't re-read. |

**All of these mean: You are doing subagent work in main context. STOP. Dispatch.**

## Remember
- Load feature context FIRST (Task 0)
- Run baseline tests (Task 1) — evidence before implementation
- Review plan critically at start
- Then execute ALL tasks without stopping
- Follow plan steps exactly
- Don't skip verifications
- Stop ONLY when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent
- After last task: finish feature file (Task 4) → /pre-merge-review → PR (Task 5)
- Main context = orchestrator ONLY. All implementation via subagents.

## Integration

**Required workflow skills:**
- **feature-context** - REQUIRED: Load at start, update per task, update at end
- **pre-merge-review** - REQUIRED: Run after last task, 2 audit rounds (R2 conditional) + fixes + approval
- **rr:using-git-worktrees** - Set up isolated workspace before starting
- **rr:writing-plans** - Creates the plan this skill executes
- **rr:finishing-a-development-branch** - For manual use (standalone branch completion with 4 options)
