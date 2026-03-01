---
name: feature-context
description: >
  Use when starting brainstorming, writing plans, executing plan tasks, finishing branches,
  or any workflow step that needs current feature state and file scope
---

# Feature Context

Track feature status, plans, and changed files in `.ai/features/*.md`.

## Overview

Living document per feature. Other skills read it to understand scope — especially **rr:audit** which uses `files:` to know what to review.

## Feature File Format

```yaml
---
status: planned | in_progress | done | blocked
branch: feature/my-feature
base_branch: main  # branch this feature was created from (for PR targeting)
blocked_by: other-feature  # optional
plans:
  - docs/plans/2026-02-28-design.md
files:
  - app/models/foo.py
  - app/api/foo/routes.py
  - tests/api/test_foo.py
---
```

**Branch chaining:** Features can branch from other features, not just `main`.
Example: `main → feature/A → feature/B`. Feature B's `base_branch: feature/A`.
`finishing-a-development-branch` reads `base_branch` to target PRs correctly.

Sections (during development):

```markdown
# Feature Name
## Co zrobione
## TODO
## Known issues
## Założenia / pomysły
```

Sections (after finishing — business documentation):

```markdown
# Feature Name

## Co to jest
1-2 zdania: co robi ten feature z perspektywy użytkownika/biznesu.

## Po co to
Jaki problem biznesowy rozwiązuje. Co było wcześniej i dlaczego nie wystarczało.

## Co można zrobić
Lista możliwości z perspektywy użytkownika (admina, developera etc.).
NIE opisuj implementacji — opisz CO użytkownik może zrobić i JAK.
Każda możliwość = krótki opis + przykład użycia.

## Jak używać
Krok po kroku dla każdej grupy użytkowników:
- Dla użytkownika końcowego: co kliknąć, co wpisać
- Dla developera: jak rozszerzyć, jakie API wywołać (endpoint + payload)

## Decyzje
Tabela kluczowych decyzji:
| Decyzja | Dlaczego |
|---------|----------|
| X zamiast Y | Uzasadnienie biznesowe/techniczne |

## Nie w scope
Co świadomie pominięto i dlaczego.
```

**WAŻNE:** Dokumentacja powinna opisywać feature z perspektywy BIZNESOWEJ i UŻYTKOWEJ.
NIE dokumentuj kodu (architektura, diagramy klas, ścieżki plików).
Dokumentuj CO można zrobić, JAK tego używać, DLACZEGO takie decyzje.

## When to Update

| Workflow step | Action |
|---------------|--------|
| **Brainstorming** | Create branch, create file with `status: planned`, `branch:`, `base_branch:`, fill "Założenia" |
| **Writing plans** | Add plan path to `plans:` |
| **Executing plans** (after each task) | Update `files:`, "Co zrobione", "TODO", set `status: in_progress` |
| **Bug found** | Add to "Known issues" |
| **Finishing branch** | See HARD-RULE below |

<HARD-RULE>
**Finishing branch — business documentation is MANDATORY:**

1. Set `status: done`
2. DELETE dev sections: Co zrobione, TODO, Known issues, Założenia
3. WRITE business sections — ALL of them:
   - **Co to jest** — 1-2 zdania, perspektywa użytkownika
   - **Po co to** — problem biznesowy, dlaczego teraz
   - **Co można zrobić** — lista możliwości z perspektywy usera, NIE kod
   - **Jak używać** — krok po kroku per grupa użytkowników
   - **Decyzje** — tabela kluczowych wyborów
   - **Nie w scope** — co pominięto i dlaczego

PR body is generated FROM these sections. Without them → PR will be technical garbage.
This step must happen BEFORE /pre-merge-review and BEFORE PR creation.
</HARD-RULE>

## Updating `files:`

After each completed task, add files your feature created or significantly modified:

```bash
git diff HEAD~1 --name-only
```

- Only files central to the feature (not incidental reformats)
- Keep sorted alphabetically
- Remove deleted files from list

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Not updating `files:` after tasks | rr:audit falls back to full branch diff — noisy |
| Adding every touched file | Only files central to feature |
| No feature file before executing plans | Create during brainstorming or manually |
| Missing `plans:` link | rr:audit (Javert) can't verify completeness |
| Setting status: done without business docs | MUST write Co to jest/Po co to/Co można zrobić before PR |
| Writing technical descriptions | Feature file = business perspective, NOT code architecture |

**REQUIRED BY:** rr:audit, rr:brainstorming, rr:writing-plans, rr:executing-plans, rr:finishing-a-development-branch
