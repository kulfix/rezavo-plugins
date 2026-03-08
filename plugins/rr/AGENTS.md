# AGENTS.md

This repository ships two parallel rr instruction sets:

- Claude source: `skills/`, `agents/`, `commands/`, `hooks/`
- Codex source of truth: `.agents/skills/rr-*`

## Rules for Codex work

- Do not rewrite Claude-facing source when the task is to improve Codex behavior.
- Edit Codex-native skills directly in `.agents/skills/rr-*`.
- Keep Codex skills concise. Put long references in bundled files only when they are truly needed.
- Prefer explicit workflow instructions over hidden automation assumptions.
- Test skills with real pressure scenarios in Codex. Do not rely on semantic transformers or text linters to make bad skills behave.
- If a change affects a shared workflow concept, update every affected Codex skill in the same change.

## Layout

- Canonical Codex skills live in `.agents/skills/rr-*`
- Consumer repositories vendor those folders as snapshots
- Cross-repo sync should be a dumb copy, not a semantic rewrite step
