---
name: visual-verification
description: Use when finishing a feature that touches UI, templates, HTML, frontend code, landing pages, or any user-visible rendering, before creating PR or claiming work is complete
---

# Visual Verification

Screenshots prove features work. Text descriptions don't.

**Core principle:** If you changed something users can see, screenshot it before claiming it works.

**Decision rule:** If ANY changed file (`.html`, `.jsx`, `.tsx`, `.jinja`, `.css`) produces HTML that a user sees — visual verification required.

**Announce at start:** "Running visual verification — taking Playwright screenshots of UI changes."

## The Process

### Step 1: Identify UI Touchpoints

From feature file (`files:`) and changed files, list every user-visible surface:

```
UI touchpoints for this feature:
1. [page/template] — [what changed]
2. [page/template] — [what changed]
```

### Step 2: Start App in Docker

<HARD-RULE>
Docker is the ONLY way. Staging/dev servers run `main`, not your feature branch. Docker has your code via volume mounts + controlled seed data. No excuses — start it.
</HARD-RULE>

Check if Docker test containers are already running (`docker compose -f docker-compose.test.yml ps`). If healthy — skip startup. Otherwise:

```bash
./cli.py test up --no-build          # Fast (cached images)
./cli.py test up                     # Full rebuild
```

| Service | Host port | URL |
|---------|-----------|-----|
| Backend API | 5002 | `http://localhost:5002` |
| React Frontend | 3003 | `http://localhost:3003` |

**Verify:** `docker compose -f docker-compose.test.yml ps` — all "healthy".

**Seed credentials** (`tests/fixtures/e2e-seed.sql`):

| User | Password | Role |
|------|----------|------|
| admin | Admin123456789! | super_admin |
| e2e_admin | Test123456!@# | tenant_admin |
| e2e_operator | Test123456!@# | operator |
| e2e_tenant_b_op | Test123456!@# | operator (tenant B) |

### Step 3: Playwright MCP Screenshots

1. Load Playwright MCP tools via ToolSearch
2. Navigate to `http://localhost:3003/`, login with seed credentials
3. For each touchpoint, screenshot:

| Capture | Why |
|---------|-----|
| Default state | Proves page renders |
| Key interaction | Proves feature works |
| Per-tenant variation | Proves multi-tenant works |
| Error/edge states | Proves error handling |

4. After EACH screenshot — read the image, confirm correctness. Fix if wrong.

**Save to:** `.ai/screenshots/<branch-name>/`
**Naming:** `<page>-<state>.png` (e.g., `users-edit-modal.png`)

### Step 4: Commit and Reference

```bash
git add .ai/screenshots/<branch-name>/
git commit -m "docs: visual verification screenshots"
```

**Do NOT run `./cli.py test down`** — the caller (finishing-a-development-branch) manages Docker lifecycle. Docker stays up for subsequent test steps.

PR body: add `## Screenshots` section with `![desc](.ai/screenshots/<branch-name>/file.png)`.

## Red Flags — STOP

| Thought | Reality |
|---------|---------|
| "I don't have a running instance" | `./cli.py test up`. Done. |
| "Staging doesn't have my branch" | Staging NEVER has your branch. Docker. |
| "This is primarily backend" | "Primarily" ≠ "purely". Frontend files changed? Screenshot. |
| "Unit tests cover this" | Unit tests don't verify visual rendering |
| "I'll describe what it looks like" | Description ≠ evidence. Screenshot it. |
| "Screenshots are too much work" | 5 minutes of screenshots save reviewer hours |
| "The feature is too complex" | Break into individual pages. Screenshot each. |

## Integration

**Called by:** `finishing-a-development-branch` (Step 3)
**Pairs with:** `verification-before-completion`, `pre-merge-review`
