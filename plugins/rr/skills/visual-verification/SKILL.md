---
name: visual-verification
description: Use when finishing a feature that touches UI, templates, HTML, frontend code, landing pages, or any user-visible rendering, before creating PR or claiming work is complete
---

# Visual Verification

Screenshots prove features work. Text descriptions don't.

**Core principle:** If you changed something users can see, screenshot it before claiming it works.

**Decision rule:** If the feature has user-visible capabilities (from feature file) — visual verification required. Every capability = at least one screenshot.

**Announce at start:** "Running visual verification — taking Playwright screenshots of UI changes."

## The Process

### Task 1: Map Capabilities to Screenshots

Read feature file → section "Co można zrobić" (or equivalent capability list). Each capability = at least one screenshot.

```
Screenshot plan:
1. [Capability from feature file] → [page/URL] → [what to capture]
2. [Capability from feature file] → [page/URL] → [what to capture]
...
```

If feature file has no capability list — read "Co zrobione" or PR summary. Every user-visible thing that was built needs visual proof.

The goal: someone opening the PR sees exactly what was built without running the code.

### Task 2: Start App in Docker

<HARD-RULE>
Docker is the ONLY way. Staging/dev servers run `main`, not your feature branch. Docker has your code via volume mounts + controlled seed data. No excuses — start it.
</HARD-RULE>

Check if E2E Docker containers are already running (`docker compose -f docker-compose.e2e.yml ps`). If healthy — skip startup. Otherwise:

```bash
./cli.py e2e up --no-build           # Fast (cached images)
./cli.py e2e up                      # Full rebuild
```

`e2e up` includes backend + frontend + postgres + redis. `test up` does NOT have frontend — it won't work for screenshots.

| Service | Host port | URL |
|---------|-----------|-----|
| Backend API | 5002 | `http://localhost:5002` |
| React Frontend | 3003 | `http://localhost:3003` |

**Verify:** `docker compose -f docker-compose.e2e.yml ps` — all "healthy".

**Seed credentials** (`tests/fixtures/e2e-seed.sql`):

| User | Password | Role |
|------|----------|------|
| admin | Admin123456789! | super_admin |
| e2e_admin | Test123456!@# | tenant_admin |
| e2e_operator | Test123456!@# | operator |
| e2e_tenant_b_op | Test123456!@# | operator (tenant B) |

### Task 3: Playwright MCP Screenshots

1. Load Playwright MCP tools via ToolSearch
2. Navigate to `http://localhost:3003/`, login with seed credentials
3. For each capability from Task 1, screenshot:

<HARD-RULE>
Every capability from the screenshot plan MUST have at least one screenshot.
5 capabilities in plan = minimum 5 screenshots. Missing capability = incomplete verification.
</HARD-RULE>

| What to capture | Example |
|-----------------|---------|
| The capability working | User creates offer → screenshot of created offer |
| Before/after if relevant | Empty list → list with items |
| Key states | Active, inactive, error states |

Each screenshot must be self-explanatory — someone seeing ONLY the screenshot should understand what feature it demonstrates.

4. After EACH screenshot — read the image, confirm correctness. Fix if wrong.

**Save to:** `.ai/screenshots/<branch-name>/`
**Naming:** `<page>-<state>.png` (e.g., `users-edit-modal.png`)

### Task 4: Commit and Reference

```bash
git add .ai/screenshots/<branch-name>/
git commit -m "docs: visual verification screenshots"
```

**Do NOT run `./cli.py test down`** — the caller (finishing-a-development-branch) manages Docker lifecycle. Docker stays up for subsequent test steps.

PR body: add `## Screenshots` section. For private repos use `github.com/raw/` format:

```markdown
## Screenshots

![desc](https://github.com/<org>/<repo>/raw/<branch>/.ai/screenshots/<branch-name>/file.png)
```

`raw.githubusercontent.com` does NOT work for private repos. Only `github.com/raw/` works (session auth).

## Red Flags — STOP

| Thought | Reality |
|---------|---------|
| "I don't have a running instance" | `./cli.py e2e up`. Done. |
| "Staging doesn't have my branch" | Staging NEVER has your branch. Docker. |
| "This is primarily backend" | "Primarily" ≠ "purely". Frontend files changed? Screenshot. |
| "Unit tests cover this" | Unit tests don't verify visual rendering |
| "I'll describe what it looks like" | Description ≠ evidence. Screenshot it. |
| "Screenshots are too much work" | 5 minutes of screenshots save reviewer hours |
| "The feature is too complex" | Break into individual pages. Screenshot each. |
| "3 of 5 capabilities is enough" | Every capability needs visual proof. No partial. |
| "I'll describe the missing ones" | Description ≠ screenshot. Capture all or explain why impossible. |

## Integration

**Called by:** `finishing-a-development-branch` (Task 3)
**Pairs with:** `verification-before-completion`, `pre-merge-review`
