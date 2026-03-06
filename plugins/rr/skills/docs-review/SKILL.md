---
name: docs-review
description: >
  Use when finishing a feature branch, after implementation is complete, to check if
  docs/kb/ needs updates. Also use when user asks to review documentation coverage,
  check for stale docs, or verify knowledge base completeness.
---

# Docs Review

Analyze what was built on the current branch and update documentation automatically.

**Core principle:** Don't force docs. Only update where a future developer would be
confused without them. Keep docs minimal, practical, and aligned with existing kb style.
Fix stale docs and fill gaps autonomously — don't ask, just do it.

## When to Run

- After finishing feature implementation (before PR)
- Periodically to check staleness
- When user asks `/docs-review`

## The Process

### Task 1: Identify What Changed

```bash
# Get branch diff scope
git diff $(git merge-base HEAD origin/develop)...HEAD --name-only
```

Categorize changed files by domain:
- New patterns/utilities → may need kb page
- Modified existing patterns → may need kb update
- New integrations → may need integrations.md update
- New models/handlers → auto-generated docs handle this

### Task 2: Cross-Reference kb/ with Code

Auto-generated docs (`docs/kb/generated/`) are refreshed by commit hook — skip them.

For each `docs/kb/*.md`, check if the patterns described still match the code:

| Check | How |
|-------|-----|
| File paths mentioned | Verify files still exist at those paths |
| Function signatures | Verify params/return types match |
| Patterns described | Verify code still follows the pattern |
| Import paths | Verify imports are correct |

**Flag stale sections** — where docs describe old code that's been refactored.

### Task 3: Identify Documentation Gaps

Scan for new patterns that have NO kb coverage:

1. **New decorators/utilities** in `app/utils/` → should they be documented?
2. **New service domains** in `app/services/` → missing from architecture.md?
3. **New middleware** in `app/middleware/` → missing from request flow?
4. **New CLI commands** → missing from development.md?
5. **New guardrails rules** → missing from security.md?

**Gap criteria — only flag if:**
- A developer would need 10+ minutes to figure out usage from code alone
- The pattern is reused across 3+ files
- There's a non-obvious pitfall that cost debugging time

**Don't flag:**
- Standard CRUD endpoints
- Self-documenting code (clear naming, type hints)
- One-off implementations
- Internal implementation details

### Task 4: Fix Stale Docs

<HARD-RULE>
Do NOT ask user "shall I update?". Just update the files.
If a doc is stale or has gaps — fix it. Commit the changes.
The only reason to skip is if the gap doesn't meet the criteria from Task 3.
</HARD-RULE>

For each stale section or gap found:
1. Edit the kb file directly — fix paths, signatures, add missing patterns
2. Follow existing kb style (see Writing Style below)
3. Commit: `docs: update kb/{file} — {what changed}`

### Task 5: Report What Was Done

```
DOCS REVIEW
===========
Branch: [current branch]

UPDATED
-------
- kb/architecture.md — added cqrs/ to directory tree, updated request flow
- kb/security.md:42 — fixed rate_limit.py path

NO ACTION NEEDED
----------------
- New endpoint /api/foo — self-documenting, no kb needed
```

## What NOT to Update

- Every new function or class
- kb pages for features that are still in_progress
- Patterns already covered by existing kb
- Content that duplicates auto-generated docs
- Implementation details that change frequently

## Writing Style (for updates)

Follow existing kb style:
- **Practical, not theoretical** — show code, not concepts
- **Pitfalls section** — what goes wrong, numbered list
- **See Also links** — cross-reference related kb pages
- **Tables for reference** — parameters, options, rules
- **Minimal prose** — let code examples speak

## Integration

This skill is called:
- Manually via user request
- As part of `rr:finishing-a-development-branch` (optional step)
- During `rr:pre-merge-review` by Javert agent (documentation completeness)
