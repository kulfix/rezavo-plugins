---
name: rr-receiving-code-review
description: Codex port of rr:receiving-code-review workflow. Use when task matches the original rr skill intent.
---


# Code Review Reception

Code review requires technical evaluation, not emotional performance.

**Core principle:** Verify before implementing. Ask before assuming. Technical correctness over social comfort.

## The Process

### Step 1: Read

Read complete feedback without reacting. Do NOT respond yet.

**Forbidden responses (NEVER use):**
- "You're absolutely right!" (explicit CLAUDE.md violation)
- "Great point!" / "Excellent feedback!" (performative)
- "Let me implement that now" (before verification)

### Step 2: Understand

Restate each requirement in your own words.

If ANY item is unclear — **STOP.** Do not implement anything. Ask for clarification on ALL unclear items first.

Items may be related. Partial understanding = wrong implementation.

```
your human partner: "Fix 1-6"
You understand 1,2,3,6. Unclear on 4,5.

❌ WRONG: Implement 1,2,3,6 now, ask about 4,5 later
✅ RIGHT: "I understand items 1,2,3,6. Need clarification on 4 and 5 before proceeding."
```

### Step 3: Verify

Check each suggestion against codebase reality.

**From your human partner:**
- Trusted — implement after understanding
- Still ask if scope unclear
- Skip to action or technical acknowledgment

**From external reviewers — BEFORE implementing:**
1. Technically correct for THIS codebase?
2. Breaks existing functionality?
3. Reason for current implementation?
4. Works on all platforms/versions?
5. Does reviewer understand full context?

If suggestion seems wrong → push back with technical reasoning.
If can't easily verify → say so: "I can't verify this without [X]. Should I [investigate/ask/proceed]?"
If conflicts with your human partner's prior decisions → stop and discuss with your human partner first.

**Your human partner's rule:** "External feedback - be skeptical, but check carefully"

### Step 4: Evaluate

Is each suggestion technically sound for THIS codebase?

**YAGNI check:**
```
IF reviewer suggests "implementing properly":
  grep codebase for actual usage

  IF unused: "This endpoint isn't called. Remove it (YAGNI)?"
  IF used: Then implement properly
```

**Your human partner's rule:** "You and reviewer both report to me. If we don't need this feature, don't add it."

**Push back when:**
- Suggestion breaks existing functionality
- Reviewer lacks full context
- Violates YAGNI (unused feature)
- Technically incorrect for this stack
- Legacy/compatibility reasons exist
- Conflicts with your human partner's architectural decisions

**How to push back:**
- Use technical reasoning, not defensiveness
- Ask specific questions
- Reference working tests/code
- Involve your human partner if architectural

**Signal if uncomfortable pushing back out loud:** "Strange things are afoot at the Circle K"

### Step 5: Respond

Technical acknowledgment or reasoned pushback. Never performative.

**When feedback IS correct:**
```
✅ "Fixed. [Brief description of what changed]"
✅ "Good catch - [specific issue]. Fixed in [location]."
✅ [Just fix it and show in the code]

❌ "You're absolutely right!"
❌ "Great point!"
❌ "Thanks for catching that!"
❌ "Thanks for [anything]"
❌ ANY gratitude expression
```

Actions speak. Just fix it. The code itself shows you heard the feedback.

If you catch yourself about to write "Thanks" — DELETE IT. State the fix instead.

**If you pushed back and were wrong:**
```
✅ "You were right - I checked [X] and it does [Y]. Implementing now."
✅ "Verified this and you're correct. My initial understanding was wrong because [reason]. Fixing."

❌ Long apology
❌ Defending why you pushed back
❌ Over-explaining
```

State the correction factually and move on.

### Step 6: Implement

One item at a time. Test each fix individually.

**Order for multi-item feedback:**
1. Blocking issues (breaks, security)
2. Simple fixes (typos, imports)
3. Complex fixes (refactoring, logic)

Test each fix individually. Verify no regressions after each.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Performative agreement | State requirement or just act |
| Blind implementation | Verify against codebase first |
| Batch without testing | One at a time, test each |
| Assuming reviewer is right | Check if breaks things |
| Avoiding pushback | Technical correctness > comfort |
| Partial implementation | Clarify all items first |
| Can't verify, proceed anyway | State limitation, ask for direction |

## Real Examples

**Performative Agreement (Bad):**
```
Reviewer: "Remove legacy code"
❌ "You're absolutely right! Let me remove that..."
```

**Technical Verification (Good):**
```
Reviewer: "Remove legacy code"
✅ "Checking... build target is 10.15+, this API needs 13+. Need legacy for backward compat. Current impl has wrong bundle ID - fix it or drop pre-13 support?"
```

**YAGNI (Good):**
```
Reviewer: "Implement proper metrics tracking with database, date filters, CSV export"
✅ "Grepped codebase - nothing calls this endpoint. Remove it (YAGNI)? Or is there usage I'm missing?"
```

**Unclear Item (Good):**
```
your human partner: "Fix items 1-6"
You understand 1,2,3,6. Unclear on 4,5.
✅ "Understand 1,2,3,6. Need clarification on 4 and 5 before implementing."
```

## GitHub Thread Replies

When replying to inline review comments on GitHub, reply in the comment thread (`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`), not as a top-level PR comment.
