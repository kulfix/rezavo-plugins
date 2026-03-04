---
name: consolidate-audit-issues
description: >
  Use when audit issues from multiple branches need consolidation into a single tracking file,
  after merging feature branches, or when .ai/audit/ has unprocessed branch directories
---

# Consolidate Audit Issues

Scan `.ai/audit/` for branch issue files, merge into single dated `all-open-issues` file. Assign to planned features. Move processed inputs to `done/`.

**Core principle:** One source of truth for all deferred audit issues. Every issue must land in a planned feature file. If no feature fits, create a thematic catch-all.

## Invocation

```
/consolidate-audit-issues           → auto-detect unprocessed branches
/consolidate-audit-issues all       → reprocess all branches (full rebuild)
```

## The Process

### Step 1: Find Previous Consolidation

Look for existing dated files in `.ai/audit/`:

```bash
ls .ai/audit/YYYY-MM-DD-open-issues.md
```

Read the latest one. Extract the `Sources:` section — these branches are already processed.

### Step 2: Find Unprocessed Branches

List all branch audit directories (skip `done/`):

```bash
ls -d .ai/audit/feature-*/
```

For each directory, check if `issues.md` exists. Compare against already-processed list from Step 1.

**Unprocessed** = has `issues.md` but NOT listed in previous consolidation sources.

If no unprocessed branches → tell user and STOP.

### Step 3: Read All Issue Files

For each unprocessed branch, read `issues.md`. Extract rows from the markdown table.

For the previous consolidation file (if exists), carry forward unresolved issues.

**Resolved issues** = issues assigned to branches that are now merged (check `.ai/features/done/`). Drop them from the new file.

### Step 4: Assign to Planned Features

Read all feature files in `.ai/features/*.md` (skip `done/` subdirectory). These are the available targets.

For each new issue, assign to a planned feature based on:
- **File path** — which domain does the file belong to?
- **Issue type** — security/auth → auth-cleanup, calls/analysis → calls-cleanup, offers → offer-hardening
- **Existing assignments** — follow patterns from previous consolidation
- **`audit_issues:` in feature frontmatter** — check if the issue's original number is already listed

### Step 5: Handle Unassignable Issues

If issues don't fit any existing planned feature:

1. **Group by theme** — find common thread (e.g., "CI/infra", "test hardening", "E2E improvements")
2. **Check if a catch-all feature already exists** for that theme
3. **If not — create 1-2 thematic feature files** in `.ai/features/`:

```yaml
---
status: planned
branch: null
base_branch: feature/multi-tenant-foundation
plans: []
files: []
audit_issues: []
---

# Theme Name

## Co to jest
Catch-all for [theme] issues discovered during audits.

## Issues
[table of assigned issues]
```

Keep the number of catch-all features minimal (1-2 max). Prefer assigning to existing features.

**Zero `nieprzypisane` at the end.** Every issue must have a home.

### Step 6: Update Feature Files

For each planned feature that received new issues, update its `audit_issues:` list in frontmatter to include the new issue IDs.

### Step 7: Write Consolidated File

Create `.ai/audit/YYYY-MM-DD-open-issues.md` with today's date.

Format:

```markdown
# Wszystkie otwarte issues z audytów

> Skonsolidowane YYYY-MM-DD.
>
> **Źródła:**
> - `done/YYYY-MM-DD-open-issues.md` — N issues (previous consolidation)
> - `done/<branch-1>/issues.md` — N issues (PR #X, merged YYYY-MM-DD)
> - `done/<branch-2>/issues.md` — N issues (PR #X, merged YYYY-MM-DD)

---

## Przypisanie do planned features

| Feature | Issues (stare) | Issues (nowe) | Total |
|---------|---------------|---------------|:-----:|
| **feature-name** | #1,2,3 | ID-1,ID-2 | N |

---

## Grupowanie tematyczne

### A. Theme Name (N issues)

| ID | Severity | Plik | Problem | Feature |
|----|----------|------|---------|---------|
| X | high | file.py | description | target-feature |

**Propozycja:** [how to address this group]

### B. Theme Name (N issues)
...

---

## Nowe issues — <branch-name> (PR #X)

Źródło: `done/<branch-dir>/issues.md`

| ID | Round | Agent | Severity | Plik | Opis | Feature |
|----|-------|-------|----------|------|------|---------|
| PREFIX-1 | R1 | Agent | severity | file | description | target-feature |

---

## Podsumowanie

| Źródło | Issues |
|--------|:------:|
| Stare (previous date) | N |
| branch-1 (PR #X) | N |
| **TOTAL** | **N** |
```

**Issue ID convention:** `PREFIX-N` where PREFIX = branch abbreviation (e.g., RLS, REL, GRD).

### Step 8: Move Processed to done/

```bash
mkdir -p .ai/audit/done
```

Move **all inputs** that were consumed:

1. **Previous consolidation file** → `done/`
2. **Processed branch directories** → `done/`

```bash
mv .ai/audit/YYYY-MM-DD-open-issues.md .ai/audit/done/
mv .ai/audit/feature-branch-1/ .ai/audit/done/
mv .ai/audit/feature-branch-2/ .ai/audit/done/
```

After this step, `.ai/audit/` contains ONLY:
- The new `YYYY-MM-DD-open-issues.md` (current)
- `done/` directory (archive)
- Unprocessed branches (if any remain)

### Step 9: Verify Merge PR Numbers

For each new branch, find the merged PR number:

```bash
gh pr list --state merged --search "<branch-name>" --json number,mergedAt
```

Include PR number and merge date in the sources section.

### Step 10: Present Report to User

Group issues by theme and present with actionable proposals:

```
CONSOLIDATION COMPLETE
══════════════════════
Previous: YYYY-MM-DD-open-issues.md (N issues) → done/
Branches processed: X → done/
New issues added: Y
Resolved (merged branches): Z dropped
Total open: N issues

ASSIGNMENT
──────────
feature-1: N issues (M new)
feature-2: N issues (M new)
[new-catch-all]: N issues (created)

THEMES + PROPOSALS
──────────────────
A. [Theme]: N issues → [proposal]
B. [Theme]: N issues → [proposal]

Output: .ai/audit/YYYY-MM-DD-open-issues.md
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Leaving issues as `nieprzypisane` | Every issue must land in a feature — create catch-all if needed |
| Creating too many catch-all features | Max 1-2 thematic catch-alls. Prefer existing features. |
| Reprocessing already-consolidated branches | Check Sources section in previous file |
| Not moving processed files to done/ | Step 8 is mandatory — inputs always go to done/ |
| Keeping resolved issues from merged branches | Drop issues assigned to branches now in `.ai/features/done/` |
| Not updating feature file `audit_issues:` | Step 6 — feature files must list their assigned issues |
| Presenting issues without thematic grouping | Step 10 — group by theme with actionable proposals |

**READS:** `.ai/audit/*/issues.md`, `.ai/features/*.md`
**WRITES:** `.ai/audit/YYYY-MM-DD-open-issues.md`, `.ai/features/*.md` (audit_issues update)
**MOVES:** processed inputs → `.ai/audit/done/`
