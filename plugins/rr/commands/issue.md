---
description: Report and investigate a spotted issue — research root cause, classify, and document
args: description
---

The user spotted an issue and wants it investigated and documented. Their description: `$ARGUMENTS`

## Your Job

You are an issue investigator. You do NOT fix anything. You research, classify, and document.

**Anti-hack principle:** Every issue gets a systemic analysis. Never propose a quick fix without explaining why it's not a hack. If the root cause is deeper than the symptom, say so.

## Process

### 1. Assign ID

Read `.ai/issues/INDEX.md`. Find the highest `SPOT-XXX` number. Assign next. If INDEX.md doesn't exist, start with `SPOT-001`.

### 2. Research (dispatch Explore subagent)

Dispatch ONE Agent (subagent_type=Explore) with this prompt:

```
Investigate this issue in the codebase: "$ARGUMENTS"

Your job:
1. Find the code responsible (grep for keywords, find endpoints/services/templates)
2. Trace the data flow — where does the data come from? API? DB query? Cache? Hardcoded?
3. Identify the root cause — WHY does the symptom happen?
4. Check if this is connected to other known patterns (N+1 queries, stale cache, missing tenant filter, etc.)
5. Classify:
   - Type: bug-logic | bug-data | missing-feature | integration | ui-ux | config
   - Severity: critical | major | minor | cosmetic
   - Effort: quick-fix (1 file) | targeted (2-5 files) | systemic (needs plan)
6. Propose a SYSTEMIC fix (not a hack). Explain why simpler approaches would be wrong.

Return your findings structured as:
- Files examined (with line numbers)
- Data flow summary
- Root cause
- Classification (type, severity, effort)
- Proposed systemic fix
- Why not a quick fix (what would a hack look like and why it's wrong)
- Related issues (if any patterns match known audit issues OH-*, CA-*, AUC-*, MC-*)
```

### 3. Write Issue File

Create `.ai/issues/SPOT-XXX.md`:

```markdown
# SPOT-XXX: <title derived from research>

| Field | Value |
|-------|-------|
| Status | open |
| Severity | <from research> |
| Type | <from research> |
| Effort | <from research> |
| Reported | <today YYYY-MM-DD> |

## Symptom
<User's original description, verbatim>

## Investigation

### Files examined
<list with line numbers>

### Data flow
<how data gets from source to UI/output>

### Root cause
<why the symptom happens>

## Proposed fix

### Approach (systemic)
<what to change and why this is the right level of abstraction>

### Why not a quick fix
<what a hack would look like and why it's wrong>

### Files to modify
<list of files that need changes>

### Linked audit issues
<any related OH-*/CA-*/AUC-*/MC-* issues, or "None">
```

### 4. Update INDEX.md

Append a row to `.ai/issues/INDEX.md`. Create the file if it doesn't exist:

```markdown
# Spotted Issues

Issues discovered during manual testing, UI review, or log inspection.
Investigated with root cause analysis — no quick fixes.

| ID | Severity | Type | Effort | Title | Status |
|----|----------|------|--------|-------|--------|
```

Add the new issue row.

### 5. Show Summary

```
ISSUE LOGGED
════════════
ID:       SPOT-XXX
Title:    <title>
Severity: <severity>
Type:     <type>
Effort:   <effort>
Status:   open

Root cause: <1-sentence summary>
Fix approach: <1-sentence summary>
File: .ai/issues/SPOT-XXX.md
```
