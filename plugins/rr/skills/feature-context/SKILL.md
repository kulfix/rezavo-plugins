---
name: feature-context
description: >
  Use when starting brainstorming, writing plans, executing plan tasks, finishing branches,
  or any workflow step that needs current feature state and file scope
---

# Feature Context

Track feature status, plans, and changed files in `.ai/features/*.md`.

## Overview

Living document per feature. Other skills read it to understand scope — especially **rr:audit** which uses `files:` to know what to review.

## Feature File Format

```yaml
---
status: planned | in_progress | done | blocked
branch: feature/my-feature
blocked_by: other-feature  # optional
plans:
  - docs/plans/2026-02-28-design.md
files:
  - app/models/foo.py
  - app/api/foo/routes.py
  - tests/api/test_foo.py
---
```

Sections:

```markdown
# Feature Name
## Co zrobione
## TODO
## Known issues
## Założenia / pomysły
```

## When to Update

| Workflow step | Action |
|---------------|--------|
| **Brainstorming** | Create file, `status: planned`, fill "Założenia" |
| **Writing plans** | Add plan path to `plans:` |
| **Executing plans** (after each task) | Update `files:`, "Co zrobione", "TODO", set `status: in_progress` |
| **Bug found** | Add to "Known issues" |
| **Finishing branch** | Set `status: done`, final "Co zrobione", clean "TODO" |

## Updating `files:`

After each completed task, add files your feature created or significantly modified:

```bash
git diff HEAD~1 --name-only
```

- Only files central to the feature (not incidental reformats)
- Keep sorted alphabetically
- Remove deleted files from list

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Not updating `files:` after tasks | rr:audit falls back to full branch diff — noisy |
| Adding every touched file | Only files central to feature |
| No feature file before executing plans | Create during brainstorming or manually |
| Missing `plans:` link | rr:audit (Javert) can't verify completeness |

**REQUIRED BY:** rr:audit, rr:brainstorming, rr:writing-plans, rr:executing-plans, rr:finishing-a-development-branch
