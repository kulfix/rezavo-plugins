---
name: rr-audit
description: Use when a finished feature or scoped file set needs rr audit findings from Fletcher, tenant-debugger, and Javert.
---

# Audit

Generate findings. Do not silently fix code during this skill.

## Step 1: Resolve Scope

1. Read the feature file with `rr-feature-context`.
2. Use `files:` as the primary review scope.
3. Fall back to the branch diff only if `files:` is empty.

Do not widen scope just because the legacy codebase is noisy.

## Step 2: Dispatch Auditors

Run these auditors in parallel:

- `rr-fletcher`
- `rr-tenant-debugger`
- `rr-javert`

Give each auditor:

- scoped files
- feature name
- linked plans or design docs
- instruction to ignore unrelated legacy code

## Step 3: Triage Findings

Every finding must become exactly one of:

- `MUST FIX`
- `FALSE POSITIVE`
- `DEFERRED`

Rules:

- security, tenant isolation, data loss, destructive migration mistakes -> always `MUST FIX`
- `DEFERRED` needs a concrete proposed fix
- `FALSE POSITIVE` needs a concrete reason

## Step 4: Record Deferred Issues

Write deferred findings to `.ai/audit/<branch-name>/issues.md`.

Each row must include:

- round
- agent
- finding id
- file
- problem
- proposed fix
- status

## Step 5: Return a Usable Summary

Summarize:

- scope
- per-agent rating
- must-fix findings
- false positives with reasons
- deferred findings with reasons and proposed fixes

If the caller needs task tracking, convert `MUST FIX` findings into explicit checklist items in the conversation or task tracker.
