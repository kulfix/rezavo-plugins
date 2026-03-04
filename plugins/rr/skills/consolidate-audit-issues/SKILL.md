---
name: consolidate-audit-issues
description: >
  Use when audit issues from multiple branches need consolidation into a single tracking file,
  after merging feature branches, or when .ai/audit/ has unprocessed branch directories
---

# Consolidate Audit Issues

Scan `.ai/audit/` for branch issue files, triage with user, assign to planned features, archive inputs.

**Core principle:** Every deferred audit issue must land in a planned feature file. Source of truth = `.ai/features/*.md` (`audit_issues:` in frontmatter). The audit directory is just a processing pipeline.

## Invocation

```
/consolidate-audit-issues           → auto-detect unprocessed branches
/consolidate-audit-issues all       → reprocess all branches (full rebuild)
```

## The Process

### Step 1: Find Unprocessed Branches

List branch audit directories (skip `done/`):

```bash
ls -d .ai/audit/feature-*/
```

For each, check if `issues.md` exists. If previous consolidation exists in `done/`, check its `Sources:` section — skip already-processed branches.

If no unprocessed branches → tell user and STOP.

### Step 2: Read Issue Files + Find PR Numbers

For each unprocessed branch:
1. Read `issues.md` — extract rows from markdown table
2. Find merged PR number:
```bash
gh pr list --state merged --search "<branch-name>" --json number,mergedAt
```

### Step 3: Read Planned Features

Read all feature files in `.ai/features/*.md` (skip `done/`). These are assignment targets. Note their `audit_issues:` lists.

### Step 4: Present Triage to User

**STOP here and involve the user.** Group new issues by theme and present with assignment proposals:

```
TRIAGE — N new issues from X branches
══════════════════════════════════════

A. [Theme] (N issues)
   ID | Severity | File | Problem
   → Proposal: assign to [feature] — [why]

B. [Theme] (N issues)
   ...

Unassignable (N issues):
   → Proposal: create catch-all "[name]"

Approve assignments?
```

Assignment heuristics:
- **File path** — which domain? auth/users, calls/analysis, offers
- **Issue type** — security/tenant → RLS feature, DRY/perf → domain cleanup
- **Existing patterns** — follow previous assignments in feature files

Wait for user to confirm or adjust before proceeding.

### Step 5: Handle Catch-All Features (if needed)

If issues don't fit any existing feature and user approved creating a catch-all:

```yaml
---
status: planned
branch: null
base_branch: [ask user or infer from other features]
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

Max 1-2 catch-alls. Zero `nieprzypisane` at the end.

### Step 6: Update Feature Files

For each feature that received new issues, update `audit_issues:` in frontmatter.

### Step 7: Write Consolidated File + Archive

Write `.ai/audit/done/YYYY-MM-DD-open-issues.md` (directly to `done/` — it's an archive record, not living data).

Move processed branch directories to `done/`:

```bash
mkdir -p .ai/audit/done
mv .ai/audit/feature-branch-1/ .ai/audit/done/
mv .ai/audit/feature-branch-2/ .ai/audit/done/
```

After this, `.ai/audit/` contains ONLY:
- `done/` (archive)
- Unprocessed branches (if any remain)

### Step 8: Report

```
CONSOLIDATION COMPLETE
══════════════════════
Branches processed: X → done/
New issues: Y
Assigned to:
  feature-1: +N issues
  feature-2: +N issues

Archive: .ai/audit/done/YYYY-MM-DD-open-issues.md
```

## Consolidated File Format (archive)

```markdown
# Wszystkie otwarte issues z audytów

> Skonsolidowane YYYY-MM-DD.
>
> **Źródła:**
> - `done/<branch-1>/issues.md` — N issues (PR #X, merged YYYY-MM-DD)
> - `done/<branch-2>/issues.md` — N issues (PR #X, merged YYYY-MM-DD)

## Przypisanie do planned features

| Feature | Issues (nowe) | Total w feature |
|---------|---------------|:---------------:|
| **feature-name** | ID-1, ID-2 | N |

## Nowe issues — <branch-name> (PR #X)

Źródło: `done/<branch-dir>/issues.md`

| ID | Round | Agent | Severity | Plik | Opis | Feature |
|----|-------|-------|----------|------|------|---------|
| PREFIX-1 | R1 | Agent | severity | file | description | target-feature |
```

**Issue ID convention:** `PREFIX-N` where PREFIX = branch abbreviation (e.g., RLS, REL, GRD).

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Updating feature files before user approves | Step 4 first — triage with user, then update |
| Leaving issues as `nieprzypisane` | Every issue must have a home — create catch-all if needed |
| Creating too many catch-all features | Max 1-2. Prefer existing features. |
| Writing consolidated file to .ai/audit/ root | Write directly to `done/` — it's archive, not living data |
| Reprocessing already-consolidated branches | Check `done/` for previous consolidation sources |
| Not updating feature file `audit_issues:` | Step 6 — feature files ARE the source of truth |

**READS:** `.ai/audit/*/issues.md`, `.ai/features/*.md`
**WRITES:** `.ai/audit/done/YYYY-MM-DD-open-issues.md` (archive), `.ai/features/*.md` (audit_issues)
**MOVES:** processed branches → `.ai/audit/done/`
