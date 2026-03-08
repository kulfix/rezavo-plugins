---
name: rr-using-rr
description: Use when starting work in a repo that ships rr skills and you need to choose the right rr workflow before acting.
---

# Using RR

## Core Rule

Load the relevant rr skill before you explore, code, test, or answer in detail. If multiple rr skills apply, choose the smallest set that fully determines the workflow.

Announce the choice in one short sentence:

`I'm using rr-<skill-name> to <purpose>.`

## Skill Order

Use process skills first. They decide how to work.

1. `rr-brainstorming`
2. `rr-writing-plans`
3. `rr-executing-plans` or `rr-subagent-driven-development`
4. `rr-pre-merge-review`
5. `rr-finishing-a-development-branch`

Use supporting skills only after the process skill is chosen:

- `rr-systematic-debugging`
- `rr-running-tests`
- `rr-writing-tests`
- `rr-feature-context`
- `rr-fletcher`
- `rr-javert`
- `rr-tenant-debugger`

## Checklist Discipline

If the chosen skill has ordered steps or a real gate, keep an explicit checklist in the conversation or task tracker with `pending`, `in_progress`, and `completed`.

Do not keep the checklist in your head.

## Red Flags

Stop and load the skill if you catch yourself thinking:

- "This is simple enough to skip the workflow."
- "I'll inspect the repo first and pick the skill later."
- "I remember how this skill works."
- "I'll do one quick step before choosing the process."

## Remember

- User instructions define the goal, not the process.
- The skill body is the contract. Follow it literally unless the repo or user has stronger constraints.
- If a skill no longer matches the environment, fix the skill instead of inventing a private workflow.
