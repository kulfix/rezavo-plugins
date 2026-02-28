---
name: feature-context
description: >
  Use alongside brainstorming (Step 1), writing-plans (before saving),
  executing-plans (after each task), and finishing-a-development-branch
  (final status update). Reads and updates .ai/features/*.md files.
---

# Feature Context

Zarządzanie plikami feature w `.ai/features/*.md`.

## Format pliku

Każdy feature file ma YAML frontmatter:

```yaml
---
status: done | in_progress | planned | blocked
branch: feature/multi-tenant-foundation
blocked_by: other-feature-name
plans:
  - docs/plans/2026-02-27-design.md
---
```

Sekcje markdown:

```markdown
# Feature Name

## Co zrobione
## TODO
## Known issues
## Założenia / pomysły
```

## Co robić — zależy od momentu workflow

### Brainstorming (po design approval)

1. Przeczytaj relevantne feature files (hook pokazał listę)
2. Utwórz nowy plik `.ai/features/<nazwa>.md` z:
   - `status: planned`
   - `branch:` aktualny branch
   - Sekcja "Założenia / pomysły" z decyzjami z brainstormingu

### Writing-plans (przed zapisaniem planu)

1. Dodaj link do planu w frontmatter `plans:` odpowiedniego feature file

### Executing-plans (po postępie)

1. Zaktualizuj "Co zrobione" — dodaj ukończone komponenty
2. Zaktualizuj "TODO" — usuń ukończone
3. Ustaw `status: in_progress` jeśli był `planned`

### Bug znaleziony

1. Dodaj do "Known issues" z opisem i lokalizacją

### Finishing branch (przed merge/PR)

1. Ustaw `status: done`
2. Zaktualizuj "Co zrobione" — finalna lista
3. Wyczyść "TODO" (powinno być puste)
4. Dodaj "Known issues" jeśli zostały
