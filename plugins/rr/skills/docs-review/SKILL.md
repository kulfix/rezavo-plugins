---
name: docs-review
description: >
  Use when finishing a feature branch, after implementation is complete, to check if
  docs/kb/ needs updates. Also use when user asks to review documentation coverage,
  check for stale docs, or verify knowledge base completeness.
---

# Docs Review

Check if `docs/kb/` needs updates after feature work. Fix automatically.

**Core principle:** Docs are for the AGENT (future Claude), not humans reading code.
Write what the agent needs to know to work correctly — pitfalls, gotchas, patterns
that aren't obvious from code. Never copy code into docs. Never explain the obvious.

<HARD-RULE>
Docs = agent cheat sheet. Short. Dense. Actionable.

DO write:
- "Phone() constructor throws — use try_parse() for external input"
- "unscoped() objects are unsafe outside the block — eagerly load attrs"
- "rate_limit uses Lua script — EXPIRE only on count==1 (fixed window)"

DO NOT write:
- Code snippets that just mirror the source file
- "This function takes X and returns Y" (agent can read the code)
- Explanations of standard patterns (CQRS, REST, ORM)
- Multi-paragraph descriptions of how something works internally
</HARD-RULE>

## The Process

### Task 1: Identify What Changed

```bash
git diff $(git merge-base HEAD origin/develop)...HEAD --name-only
```

### Task 2: Cross-Reference kb/ with Code

Skip `docs/kb/generated/` — refreshed by commit hook.

For each `docs/kb/*.md`: verify file paths, function signatures, import paths still correct.

### Task 3: Identify Gaps

Only flag if:
- Agent would make a mistake without knowing this (pitfall, gotcha)
- Pattern is used in 3+ files and has non-obvious behavior
- There's a trap that cost debugging time

Don't flag: CRUD, self-documenting code, one-offs, internals.

### Task 4: Fix

<HARD-RULE>
Do NOT ask. Just update the files and commit.
</HARD-RULE>

For each stale section or gap:
1. Edit kb file — fix paths, add pitfalls, update tables
2. Keep it SHORT — one line per fact, tables over prose
3. Commit: `docs: update kb/{file} — {what changed}`

### Task 5: Report

```
DOCS REVIEW — [branch]
UPDATED: kb/X.md (reason), kb/Y.md (reason)
SKIPPED: [what didn't need docs and why]
```
