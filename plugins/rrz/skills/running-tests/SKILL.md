---
name: running-tests
description: Use when about to run pytest, ./cli.py test, ./cli.py e2e, or any test command. Also use when deciding which tests to run, which group to pick, or whether to run full suite vs targeted tests.
---

# Running Tests

**NIGDY `pytest` lokalnie. Zawsze Docker przez `./cli.py`.**

## Backend (pytest)

```bash
./cli.py test up              # Start (raz na sesje)
./cli.py test run -g fast     # Grupa
./cli.py test run -f tests/api/ # Sciezka
./cli.py test run -k "test_m1"  # Keyword
./cli.py test down            # Stop (na koniec)
```

Grupy: `fast`, `services`, `api`, `models`, `jobs`, `matching`, `integration`, `security`, `all`.
Sprawdz: `./cli.py test groups`

## E2E (Playwright)

**Osobne srodowisko Docker** — nie mieszaj z backend:

```bash
./cli.py e2e up               # Build & start
./cli.py e2e up --no-build    # Start bez rebuild (szybciej)
./cli.py e2e test smoke       # Konkretna grupa
./cli.py e2e test all         # Wszystkie grupy
./cli.py e2e test smoke --debug # Z inspektorem
./cli.py e2e down             # Stop
```

Grupy E2E: `smoke`, `booking`, `dashboard`, `templates`, `visual`, `edge`, `all`.

CI: `gh workflow run e2e-modular.yml -f groups=booking -f test_file=path/to/test.spec.ts`

## Kiedy co odpalac?

| Sytuacja | Komenda |
|----------|---------|
| Podczas pracy nad taskiem | `-f tests/api/` lub `-k "test_name"` — TYLKO dotyczace zmian |
| Przed PR (backend) | `-g all` (>10 min) |
| Przed PR (E2E) | `./cli.py e2e test all` |
| Baseline na poczatku workflow | `-g all` + `e2e test all` (zapisz logi) |
| Debug 1 testu CI | `test_file=` w GH Actions, NIE caly workflow |

<HARD-RULE>
NIE odpalaj `-g all` ani `e2e test all` po kazdym tasku. Punktowo = szybko. Full = przed PR.
</HARD-RULE>

## Diagnostyka bledow

Jesli testy failuja:
1. Przeczytaj output — nie zgaduj
2. Sprawdz czy Docker dziala: `./cli.py test up`
3. Sprawdz czy migracje sa aktualne w Docker
4. NIE twierdz "pre-existing" bez baseline evidence

<HARD-RULE>
Przy debugowaniu ZAWSZE strzelaj w konkretne testy (`-k "test_name"` lub `-f tests/path/`).
Full suite to ~3000 testow i >10 minut. Nie odpalaj go zeby sprawdzic 1 fix.
</HARD-RULE>
