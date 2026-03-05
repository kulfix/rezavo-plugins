---
description: Consolidate deferred audit issues and spotted issues into planned features
args: mode
---

Consolidate open issues from all sources into planned features. Mode: `$ARGUMENTS` (empty = auto-detect, `all` = full rebuild).

## Process

### 1. Find Unprocessed Sources

**A) Audit branches** — `.ai/audit/feature-*/issues.md`
```bash
ls -d .ai/audit/feature-*/ 2>/dev/null
```
Skip branches already in `.ai/audit/done/`. Check `done/` consolidation `Sources:` section.

**B) Spotted issues** — `.ai/issues/SPOT-*.md`
Read `.ai/issues/INDEX.md` — include only rows with status `open`.

If no unprocessed branches AND no open spotted issues → tell user and STOP.

### 2. Read Issue Files

**Audit branches:** Read each `issues.md` — extract rows from markdown table. Find merged PR:
```bash
gh pr list --state merged --search "<branch-name>" --json number,mergedAt
```

**Spotted issues:** Read each open `SPOT-XXX.md` — extract severity, type, effort, root cause, proposed fix.

### 3. Read Planned Features

Read all `.ai/features/*.md` (skip `done/`). These are assignment targets. Note `audit_issues:` lists.

### 4. Present Triage to User

**STOP and involve the user.** Group all issues by theme:

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
- **File path** — which domain?
- **Issue type** — security/tenant → RLS feature, DRY/perf → cleanup
- **Existing patterns** — follow previous assignments

Wait for user confirmation before proceeding.

### 5. Handle Catch-All Features (if needed)

If issues don't fit existing features and user approved, create catch-all feature file in `.ai/features/`:

```yaml
---
status: planned
branch: null
base_branch: [ask user]
plans: []
files: []
audit_issues: []
---
```

Max 1-2 catch-alls. Zero unassigned at end.

### 6. Update Files

**Feature files:** Update `audit_issues:` in frontmatter for each feature that received issues.

**Spotted issues:** For each assigned SPOT-XXX:
1. Update status in `SPOT-XXX.md`: `open` → `assigned`
2. Add `Assigned to: feature-name` row in header table
3. Update `INDEX.md` row status: `open` → `assigned`

SPOT files stay in `.ai/issues/` — only status changes.

### 7. Archive Audit Branches

Write `.ai/audit/done/YYYY-MM-DD-open-issues.md` (archive record).

Move processed branches:
```bash
mkdir -p .ai/audit/done
mv .ai/audit/feature-branch/ .ai/audit/done/
```

### 8. Report

```
CONSOLIDATION COMPLETE
══════════════════════
Branches processed: X → done/
Spotted issues assigned: Y
Total issues: Z
Assigned to:
  feature-1: +N issues
  feature-2: +N issues

Archive: .ai/audit/done/YYYY-MM-DD-open-issues.md
```
