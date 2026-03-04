---
name: consolidate-audit-issues
description: >
  Use when audit issues from multiple branches need consolidation into a single tracking file,
  after merging feature branches, or when .ai/audit/ has unprocessed branch directories
---

# Consolidate Audit Issues

Scan `.ai/audit/` for branch issue files, merge into single dated `all-open-issues` file.

**Core principle:** One source of truth for all deferred audit issues. Branch audit files are inputs, dated consolidated file is output.

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

List all branch audit directories:

```bash
ls -d .ai/audit/feature-*/
```

For each directory, check if `issues.md` exists. Compare against already-processed list from Step 1.

**Unprocessed** = has `issues.md` but NOT listed in previous consolidation sources.

If no unprocessed branches → tell user and STOP.

### Step 3: Read All Issue Files

For each unprocessed branch, read `issues.md`. Extract rows from the markdown table.

For the previous consolidation file (if exists), read all existing issues.

### Step 4: Assign to Planned Branches

Read all feature files in `.ai/features/*.md` (skip `done/` subdirectory).

For each new issue, assign to a planned branch based on:
- **File path** — which domain does the file belong to?
- **Issue type** — security/auth → auth-cleanup, calls/analysis → calls-cleanup, offers → offer-hardening
- **Existing assignments** — follow patterns from previous consolidation

Mark unassignable issues as `nieprzypisane`.

### Step 5: Write Consolidated File

Create `.ai/audit/YYYY-MM-DD-open-issues.md` with today's date.

Format:

```markdown
# Wszystkie otwarte issues z audytów

> Skonsolidowane YYYY-MM-DD.
>
> **Źródła:**
> - `YYYY-MM-DD-open-issues.md` — N issues (previous consolidation)
> - `.ai/audit/<branch-1>/issues.md` — N issues (PR #X, merged YYYY-MM-DD)
> - `.ai/audit/<branch-2>/issues.md` — N issues (PR #X, merged YYYY-MM-DD)

---

## Przypisanie do planned branchy

| Branch | Issues (stare) | Issues (nowe) |
|--------|---------------|---------------|
| **branch-name** | #1,2,3 (N) | ID-1,ID-2 |

---

## Stare issues (z poprzedniej konsolidacji)

> Pełna lista z opisami: patrz `YYYY-MM-DD-open-issues.md`.
> Poniżej tylko numery i przypisania — opisy się nie zmieniły.

N issues, przypisane jak wyżej.

---

## Nowe issues — <branch-name> (PR #X)

Źródło: `.ai/audit/<branch-dir>/issues.md`

| ID | Round | Agent | Severity | Plik | Opis | Przypisanie |
|----|-------|-------|----------|------|------|-------------|
| PREFIX-1 | R1 | Agent | severity | file | description | planned-branch |

---

## Podsumowanie

| Źródło | Issues |
|--------|:------:|
| Stare (previous date) | N |
| branch-1 (PR #X) | N |
| **TOTAL** | **N** |
```

**Issue ID convention:** `PREFIX-N` where PREFIX = branch abbreviation (e.g., RLS, REL, GRD).

### Step 6: Verify Merge PR Numbers

For each new branch, find the merged PR number:

```bash
gh pr list --state merged --search "<branch-name>" --json number,mergedAt
```

Include PR number and merge date in the sources section.

### Step 7: Report

```
CONSOLIDATION COMPLETE
══════════════════════
Previous: YYYY-MM-DD-open-issues.md (N issues)
New branches processed: X
New issues added: Y
Total: Z issues

Output: .ai/audit/YYYY-MM-DD-open-issues.md
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Reprocessing already-consolidated branches | Check Sources section in previous file |
| Missing PR numbers | Use `gh pr list --state merged` to find them |
| Overwriting previous consolidation | Create NEW dated file, don't overwrite old one |
| Copying full descriptions from old file | Reference old file, only include new issues in full |
| Forgetting assignment to planned branches | Every issue must have `Przypisanie` — use `nieprzypisane` as fallback |

**READS:** `.ai/audit/*/issues.md`, `.ai/features/*.md`
**WRITES:** `.ai/audit/YYYY-MM-DD-open-issues.md`
