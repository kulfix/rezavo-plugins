---
name: audit
description: >
  Uruchom po zakończeniu implementacji feature'a (koniec subagent-driven/executing-plans).
  Odpala 5 audytorów równolegle i zbiera wyniki.
---

# Audit Gate

Uruchom 5 audytorów RÓWNOLEGLE (5 Agent tool calls w jednym message).

## Agenci

| # | Agent | subagent_type | Co robi |
|---|-------|---------------|---------|
| 1 | Fletcher | Fletcher - code reviewer | Code review na git diff vs main |
| 2 | Javert | Javert - completeness auditor | Spec z feature file vs kod |
| 3 | Paranoik | Paranoik - tenant debugger | Tenant isolation audit |
| 4 | Dr. House | Dr. House - test auditor | Jakość nowych/zmienionych testów |
| 5 | DBA | DBA - migration reviewer | Review nowych migracji |

## Jak uruchomić

1. Ustal scope: `git diff main...HEAD --name-only`
2. Znajdź aktualny feature file z `.ai/features/` (hook pokazał listę)
3. Znajdź plan z frontmatter `plans:` feature file
4. Uruchom 5 agentów RÓWNOLEGLE — jeden message, 5 Agent tool calls
5. Każdy agent dostaje prompt z scope i kontekstem (patrz niżej)
6. Poczekaj na wyniki wszystkich 5
7. Pokaż podsumowanie (patrz niżej)
8. Critical/Important = MUST FIX przed kontynuacją
9. Suggestion = zgłoś userowi, opcjonalne

## Prompt per agent

Każdy agent dostaje:

```
Zbadaj zmiany na branchu relative to main.
Pliki zmienione: [git diff main...HEAD --name-only]
Feature: [nazwa z feature file]
Spec/design: [plans: z frontmatter feature file]
Skup się na NOWYCH zmianach, nie na legacy code.
```

## Podsumowanie wyników

Po zebraniu wyników od wszystkich 5 agentów, pokaż:

```
AUDIT RESULTS:
- Fletcher: [TEMPO/DRAGGING/RUSHING] — X issues (Y Critical)
- Javert: [DELIVERED/INCOMPLETE] — X/Y requirements
- Paranoik: [ISOLATED/SUSPICIOUS/COMPROMISED] — X findings
- Dr. House: [HEALTHY/SYMPTOMATIC/TERMINAL] — X findings
- DBA: [SAFE/RISKY/DANGEROUS] — X findings
```
