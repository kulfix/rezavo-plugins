---
name: rr-aim
description: Codex port of rr command /aim. Use when task matches the original rr command intent.
---

You are in a brainstorming or design review session. The user invoked `/aim` with a target level.

**Read the argument:** `$ARGUMENTS`

The number is the TARGET quality level. Interpret it on a sliding scale:

| Level | Mode | Mindset |
|:-----:|------|---------|
| <=9 | **Pragmatic review** | What's good enough? What can we skip? |
| 10 | **Gap analysis** | What's missing to reach perfection within scope? |
| 11 | **Beyond scope** | What would make this exceptional? |
| 12-15 | **Moonshot** | What if we rebuilt the affected subsystems? |
| 16-20 | **Visionary** | What if we reimagined the entire product around this? |

---

## Level <= 9: Pragmatic Review

The user is saying "I don't need perfection here." Respect that.

Re-examine the design and identify what ACTUALLY matters vs what's nice-to-have:

```
AIM FOR [N]/10 — PRAGMATIC REVIEW
══════════════════════════════════

| # | Element | Current | Verdict |
|---|---------|:-------:|---------|
| 1 | Architecture | 9/10 | ✅ Good enough — ship it |
| 2 | Error handling | 6/10 | ⚠️ Below target — needs [specific fix] |
| 3 | Testing | 5/10 | ❌ Below target — minimum: [what] |
```

Focus: what's the MINIMUM to hit the target? Cut everything else.

---

## Level 10: Gap Analysis

For EVERY element, identify what's missing to reach 10/10.

```
AIM FOR 10/10 — GAP ANALYSIS
═════════════════════════════

| # | Element | Current | Gap | Action to reach 10/10 |
|---|---------|:-------:|-----|----------------------|
| 1 | Architecture | 9/10 | No fallback if driver crashes | Add circuit breaker |
| 2 | Testing | 5/10 | No visual verification | Add Playwright screenshots |
```

- Be BRUTALLY honest — no inflation
- Every element below 10 MUST have concrete gap + action
- Focus on THIS feature scope
- After presenting: "Which gaps do you want to close?"

---

## Level 11: Beyond Scope

Think outside the feature boundary. No self-censorship.

```
AIM FOR 11/10 — BEYOND SCOPE
═════════════════════════════

Current scope delivers: [1-sentence summary]

BEYOND SCOPE:

1. 🚀 [IDEA]
   What: [description]
   Why: [user/business impact]
   Cost: [hours/days/weeks]
   Impact: X/10 | Effort: Y/10

SYSTEMIC IMPROVEMENTS:

2. 🔧 [IMPROVEMENT]
   Benefit here: [how it helps this feature]
   Benefit everywhere: [broader impact]
   Impact: X/10 | Effort: Y/10

FUTURE-PROOFING — decisions cheaper to make NOW:

3. 🔮 [DECISION]
   Why now: [cost now vs later]
```

---

## Level 12-15: Moonshot

Everything from level 11, PLUS:

- What if we **rebuilt the affected subsystems** from scratch around this feature's needs?
- What **architectural patterns** from other industries (fintech, gaming, healthcare) would transform this?
- What would a **10x engineer** do differently with this entire module?

```
AIM FOR [N]/10 — MOONSHOT
═════════════════════════

REBUILD CANDIDATES:
1. 💥 [SUBSYSTEM] — why it's holding us back, what replaces it

CROSS-INDUSTRY PATTERNS:
2. 🌐 [PATTERN from INDUSTRY] — how it applies here

10X MOVES:
3. ⚡ [FUNDAMENTAL CHANGE] — what changes if we do this
```

Include at least one idea that requires significant refactoring. Be specific.

---

## Level 16-20: Visionary

Everything from moonshot, PLUS:

- What if this feature was the **core value proposition** of the entire product?
- What **new business models** does this enable?
- What would this look like in **5 years** if we invested fully?
- What would make competitors **unable to replicate** this?

```
AIM FOR [N]/10 — VISIONARY
═══════════════════════════

IF THIS WAS THE PRODUCT:
1. 🌟 [VISION] — what the product becomes

NEW BUSINESS MODELS:
2. 💰 [MODEL] — revenue/value this unlocks

5-YEAR TRAJECTORY:
3. 🗺️ [ROADMAP] — where this goes

MOAT:
4. 🏰 [COMPETITIVE ADVANTAGE] — why others can't copy
```

---

## After presenting ANY level

- Ask: "What resonates? What should we pull into scope, flag for future, or drop?"
- Ideas user likes at level 11+ → add to feature file as `future:` items or create new feature files with `status: idea`
- User decides what's enough. Their call, not yours.

## If no argument

Say: "Usage: `/aim N` — where N is your target quality level. Examples: `/aim 9` (pragmatic), `/aim 10` (perfection), `/aim 11` (beyond scope), `/aim 15` (moonshot), `/aim 20` (visionary)"
