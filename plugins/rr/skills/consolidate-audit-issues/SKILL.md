---
name: consolidate-audit-issues
description: >
  Use when audit issues from multiple branches need consolidation into a single tracking file,
  after merging feature branches, when .ai/audit/ has unprocessed branch directories,
  or when .ai/issues/ has open spotted issues (SPOT-XXX) that need assignment to features
---

# Consolidate Audit Issues

Scan `.ai/audit/` for branch issue files AND `.ai/issues/` for open spotted issues (SPOT-XXX), triage with user, assign to planned features, archive/update status.

**Core principle:** Every deferred audit issue must land in a planned feature file. Source of truth = `.ai/features/*.md` (`audit_issues:` in frontmatter). The audit directory is just a processing pipeline.

## Invocation

```
/consolidate-audit-issues           → auto-detect unprocessed branches
/consolidate-audit-issues all       → reprocess all branches (full rebuild)
```

## The Process

### Step 1: Find Unprocessed Sources

**Two input sources:**

**A) Audit branches** — `.ai/audit/feature-*/issues.md`
```bash
ls -d .ai/audit/feature-*/
```
Skip branches already in `done/`. Check `done/` consolidation `Sources:` section.

**B) Spotted issues** — `.ai/issues/SPOT-*.md`
```bash
ls .ai/issues/SPOT-*.md
```
Read `INDEX.md` — include only rows with status `open`.

If no unprocessed branches AND no open spotted issues → tell user and STOP.

### Step 2: Read Issue Files + Find PR Numbers

**For audit branches:**
1. Read `issues.md` — extract rows from markdown table
2. Find merged PR number:
```bash
gh pr list --state merged --search "<branch-name>" --json number,mergedAt
```

**For spotted issues:**
1. Read each open `SPOT-XXX.md` — extract severity, type, effort, root cause, proposed fix
2. No PR needed — these are discovered bugs, not audit deferrals

### Step 3: Read Planned Features

Read all feature files in `.ai/features/*.md` (skip `done/`). These are assignment targets. Note their `audit_issues:` lists.

### Step 4: Present Triage to User

**STOP here and involve the user.** Group all issues (audit + spotted) by theme and present with assignment proposals:

```
TRIAGE — N issues (X from audits, Y spotted)
══════════════════════════════════════════════

A. [Theme] (N issues)
   ID | Source | Severity | File | Problem
   → Proposal: assign to [feature] — [why]

B. [Theme] (N issues)
   ...

Unassignable (N issues):
   → Proposal: create catch-all "[name]"

Approve assignments?
```

Source column: `audit/<branch>` or `SPOT-XXX`.

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

### Step 6: Update Feature Files + Spotted Issue Status

**Feature files:** For each feature that received new issues, update `audit_issues:` in frontmatter.

**Spotted issues:** For each assigned SPOT-XXX issue:
1. Update status in `SPOT-XXX.md` header table: `open` → `assigned`
2. Add `Assigned to: feature-name` row to the header table
3. Update status in `INDEX.md` row: `open` → `assigned`

SPOT issue files stay in `.ai/issues/` (they are permanent records, not pipeline artifacts). Only their status changes.

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
> - `.ai/issues/` — N spotted issues (SPOT-XXX)

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

**READS:** `.ai/audit/*/issues.md`, `.ai/issues/INDEX.md`, `.ai/issues/SPOT-*.md`, `.ai/features/*.md`
**WRITES:** `.ai/audit/done/YYYY-MM-DD-open-issues.md` (archive), `.ai/features/*.md` (audit_issues), `.ai/issues/SPOT-*.md` (status), `.ai/issues/INDEX.md` (status)
**MOVES:** processed audit branches → `.ai/audit/done/`
