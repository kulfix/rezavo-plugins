---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify pre-merge-review → Update feature file → Verify tests → Visual verification → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## The Process

### Step 0: Verify Gate Was Run (REQUIRED)

Before finishing:
1. Check if `/pre-merge-review` was run on this branch (look for `.ai/audit/<branch-name>/summary.md`)
2. If NOT run — **STOP. Run `/pre-merge-review` first.** Do not proceed without it.
3. Gate must have been approved by user before proceeding

### Step 1: Update Feature File

Use `feature-context` skill to update the feature file:
- Set status to `done` (or appropriate status)
- Verify all plan items are reflected

### Step 2: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:** Stop. Fix before proceeding.

### Step 3: Visual Verification (if UI changes)

Check if feature touches any user-visible rendering (templates, HTML, frontend, CSS, landing pages).

**If YES:** Run `rr:visual-verification` skill. This will:
1. Identify UI touchpoints from feature file and changed files
2. Take Playwright MCP screenshots of each touchpoint
3. Verify screenshots visually
4. Commit screenshots to `.ai/screenshots/<branch-name>/`

**If NO (pure backend):** Skip — but verify decision. If changed files include `.html`, `.jsx`, `.tsx`, `.jinja`, `.liquid`, template strings, or CSS — it HAS UI changes.

Screenshots will be included in PR body (Step 6, Option 2).

### Step 4: Determine Base Branch

Read `base_branch` from feature file frontmatter (`.ai/features/<name>.md`).

If not set, determine from git:
```bash
# Find the branch this feature branched from
git log --oneline --decorate --first-parent | grep -m1 'origin/' | head -1
```

Or ask: "This branch appears to have split from `<branch>` - is that correct?"

**Important:** The base branch is NOT always `main`. Feature branches can chain:
`main → feature/A → feature/B`. In this case, feature/B's base is feature/A, not main.

### Step 5: Present Options

Present exactly these 4 options:

```
Implementation complete. What would you like to do?

Base branch: <base-branch>

1. Merge back to <base-branch> locally
2. Push and create a Pull Request (target: <base-branch>)
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 6: Execute Choice

#### Option 1: Merge Locally

```bash
git checkout <base-branch>
git pull
git merge <feature-branch>
# Verify tests on merged result
<test command>
# If tests pass
git branch -d <feature-branch>
```

Then: Cleanup worktree (Step 7)

#### Option 2: Push and Create PR

```bash
# Push branch
git push -u origin <feature-branch>

# Create PR targeting base branch (NOT always main!)
gh pr create --base <base-branch> --title "<title>" --body "<PR body>"
```

**Critical:** `--base <base-branch>` must be the actual base, not hardcoded `main`.

**PR body** — generate from available sources:

1. **Feature file** (`.ai/features/<name>.md`) → Summary + What was built
2. **Audit summary** (`.ai/audit/<branch-name>/summary.md`) → Quality Audit
3. **Issues** (`.ai/audit/<branch-name>/issues.md`) → Deferred Issues

```markdown
## Summary
[From feature file: Co to jest — 2-3 sentences]

## What was built
[From feature file: Co można zrobić — bullet points]

## Screenshots
[From .ai/screenshots/<branch-name>/ — if visual verification was done]

### [Page/Feature Name]
![Description](.ai/screenshots/<branch-name>/filename.png)

[If no UI changes: replace with "No UI changes in this feature."]

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
[EVERY checkbox MUST have evidence — screenshot reference, command output, or CI link]
- [x] [claim] — [evidence: screenshot above / command output / CI link]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

If any source file doesn't exist, skip that section.

Then: Cleanup worktree (Step 7)

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

#### Option 4: Discard

**Confirm first:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:
```bash
git checkout <base-branch>
git branch -D <feature-branch>
```

Then: Cleanup worktree (Step 7)

### Step 7: Cleanup Worktree

**For Options 1, 2, 4:**

Check if in worktree:
```bash
git worktree list | grep $(git branch --show-current)
```

If yes:
```bash
git worktree remove <worktree-path>
```

**For Option 3:** Keep worktree.

## Quick Reference

| Option | Merge | Push | PR Target | Keep Worktree | Cleanup Branch |
|--------|-------|------|-----------|---------------|----------------|
| 1. Merge locally | ✓ | - | - | - | ✓ |
| 2. Create PR | - | ✓ | base-branch | ✓ | - |
| 3. Keep as-is | - | - | - | ✓ | - |
| 4. Discard | - | - | - | - | ✓ (force) |

## Red Flags

**Never:**
- Hardcode `main` as PR target — always use the actual base branch
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request

**Always:**
- Verify pre-merge-review was run before finishing
- Read base branch from feature file or git history
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only

## Integration

**Called by:**
- **subagent-driven-development** — After all tasks + pre-merge-review complete
- **executing-plans** — After all tasks + pre-merge-review complete

**Pairs with:**
- **using-git-worktrees** - Cleans up worktree created by that skill
- **feature-context** - Reads base_branch, updates status to done
- **visual-verification** - Screenshots of UI changes (Step 3)
