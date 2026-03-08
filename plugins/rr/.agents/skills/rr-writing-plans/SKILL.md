---
name: rr-writing-plans
description: Use when requirements are understood and you need a decision-complete implementation plan that another Codex agent can execute without choosing details.
---

# Writing Plans

Write plans that are safe to hand to another engineer or agent immediately.

## Step 0: Load Feature Context

1. Load the active feature file.
2. Verify or fill in `base_branch`.
3. Save the plan path back to `plans:`.

## Plan Quality Bar

Every task must be decision-complete:

- exact files
- exact commands
- expected outputs
- dependencies on earlier tasks spelled out explicitly
- verification step

Do not write "same as above" or "analogicznie".

## Task Granularity

Prefer small tasks that can be verified and committed independently.

Typical shape:

1. write or update test
2. run it and capture expected fail or pass
3. implement the minimal change
4. rerun verification
5. commit

## Required Plan Header

Start with:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [one sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [key tools]
```

## Required Gate Task

End with a gate task that says:

1. run `rr-pre-merge-review`
2. fix findings until the audit is complete
3. run `rr-finishing-a-development-branch`

Do not describe this gate with slash commands.

## Remember

- include ops tasks if the design requires post-deploy actions
- include E2E tasks if the design defines acceptance scenarios
- reference rr skills by name
- optimize for implementation safety, not prose beauty
