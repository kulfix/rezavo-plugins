---
name: visual-verification
description: Use when finishing a feature that touches UI, templates, HTML, frontend code, landing pages, or any user-visible rendering, before creating PR or claiming work is complete
---

# Visual Verification

## Overview

Screenshots prove features work. Text descriptions don't.

**Core principle:** If you changed something users can see, screenshot it before claiming it works.

**Announce at start:** "Running visual verification — taking Playwright screenshots of UI changes."

## When to Use

**Use when feature changes ANY of:**
- Frontend components (React, Vue, etc.)
- HTML templates (Jinja, Liquid, etc.)
- Landing pages, email templates rendered in browser
- Admin panels, dashboards
- Error pages, status pages
- CSS/styling changes

**Skip when:**
- Pure backend (API-only, migrations, background jobs, CLI tools)
- No user-visible rendering changes
- Feature file `files:` contains zero template/frontend files

**Decision rule:** If ANY changed file produces HTML that a user sees — visual verification required.

## The Process

### Step 1: Identify UI Touchpoints

From feature file (`files:`) and changed files, list every user-visible surface:

```
UI touchpoints for this feature:
1. [page/template] — [what changed]
2. [page/template] — [what changed]
```

If you think there are zero UI touchpoints but changed files include `.html`, `.jsx`, `.tsx`, `.jinja`, `.liquid`, template strings, or CSS — you are wrong. Re-check.

### Step 2: Load Playwright and Navigate

1. Load Playwright MCP tools via ToolSearch
2. Navigate to dev environment URL (from CLAUDE.md or project config)
3. Login if required (credentials from CLAUDE.md)
4. Seed test data if needed

### Step 3: Screenshot Each Touchpoint

For each UI touchpoint:

| What to capture | Why |
|-----------------|-----|
| Default/loaded state | Proves page renders |
| Key interaction result | Proves feature works |
| Per-tenant variation | Proves multi-tenant works |
| Error/edge states | Proves error handling works |

**Save to:** `.ai/screenshots/<branch-name>/`
**Naming:** `<page>-<state>-<variant>.png`
**Example:** `landing-default-tenant1.png`, `offer-error-expired.png`

### Step 4: Verify Each Screenshot

After EACH screenshot, read the image and confirm:
- Page rendered correctly (no broken layout, missing elements)
- Content is correct (right data, right tenant branding)
- No visual errors (console errors, 500 pages, blank sections)

If something is wrong — FIX before proceeding. Screenshots are evidence, not decoration.

### Step 5: Commit and Reference

```bash
git add .ai/screenshots/<branch-name>/
git commit -m "docs: visual verification screenshots"
```

For PR body, add Screenshots section:

```markdown
## Screenshots

### [Feature/Page Name]
![Description](.ai/screenshots/<branch-name>/filename.png)
```

GitHub renders images from branch — relative paths work.

## Test Plan Evidence Rule

<HARD-RULE>
Every Test Plan checkbox MUST have evidence. Bare `[x]` without proof = lie.
</HARD-RULE>

| Evidence type | Use for |
|---------------|---------|
| Screenshot reference | UI/visual claims |
| Command output with counts | Test pass claims |
| CI run link | CI validation claims |
| curl/API output | API behavior claims |

```markdown
## Test Plan

- [x] Landing page renders correctly — see screenshots above
- [x] All tests pass (79/79) — `./cli.py test run` output attached
- [x] CI validates — [Run #42](link)
```

NEVER:
```markdown
- [x] Landing page renders correctly
- [x] Tests pass
```

## Red Flags — STOP

| Thought | Reality |
|---------|---------|
| "Unit tests cover this" | Unit tests don't verify visual rendering |
| "I don't have a running instance" | Dev environment exists — use it |
| "It needs real data" | Seed test data, use fixtures |
| "Playwright isn't set up" | MCP Playwright is available — ToolSearch for it |
| "Screenshots are too much work" | 5 minutes of screenshots save reviewer hours |
| "This is backend-only" | If ANY template/HTML/frontend changed — NOT backend-only |
| "I'll describe what it looks like" | Description ≠ evidence. Screenshot it. |
| "Test Plan checkboxes are enough" | Checkboxes without evidence are unverified claims |
| "The feature is too complex to screenshot" | Break into individual pages. Screenshot each. |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Screenshot only happy path | Include error states, per-tenant variations |
| Screenshot but don't verify image | READ each screenshot, confirm it's correct |
| Save screenshots but skip PR reference | Add `## Screenshots` section with image links |
| Skip for "small" UI changes | Small changes break layouts. Screenshot. |
| Login page screenshot instead of feature | Navigate to the ACTUAL feature page |
| Screenshot after PR is created | Screenshots BEFORE PR — they go in PR body |

## Integration

**Called by:** `finishing-a-development-branch` (Step 3, after test verification)

**Pairs with:**
- `verification-before-completion` — screenshots ARE verification evidence
- `pre-merge-review` — code quality + visual quality = complete review
