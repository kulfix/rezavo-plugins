---
name: testing-guidelines
description: Use when writing tests, reviewing tests, running tests, setting up test data, or asking "how to test". Covers Docker workflow, factories, fixtures, markers, RBAC setup, and test groups.
---

# Testing Guidelines

Testy w PyTek — Docker only, factory-boy, realna logika.

## Unit/API/Integration (pytest)

**NIGDY `pytest` lokalnie.** Zawsze Docker:

```bash
./cli.py test up                # Start (raz na sesje)
./cli.py test run -g fast       # Grupa
./cli.py test run -f tests/api/ # Sciezka
./cli.py test run -k "test_m1"  # Keyword
./cli.py test down              # Stop
```

Grupy: `fast`, `services`, `api`, `models`, `matching`, `integration`, `security`, `all` (>10 min).

**Punktowo podczas pracy, full (`-g all`) TYLKO przed PR.**

## E2E (Playwright)

```bash
./cli.py e2e up                 # Start (raz)
./cli.py e2e test smoke         # Grupa: smoke/booking/dashboard/all
./cli.py e2e test smoke --debug # Z inspektorem
./cli.py e2e down               # Stop
```

CI: `gh workflow run e2e-modular.yml -f groups=booking -f test_file=path/to/test.spec.ts`

**Ta sama zasada: punktowo podczas debug, full przed PR. NIE odpalaj calego workflow na 1 test.**

## Factory-boy (WYMAGANE)

```python
from tests.factories import (
    TenantFactory, UserFactory, UserTenantFactory, CallFactory,
    GuestFactory, OfferFactory, KWHotelReservationFactory,
    VisitorSessionFactory, TemplateFactory,
    InternalNumberFactory, UserInternalNumberFactory,
    RoomTypeFactory, OfferEventFactory,
    ImportedFileFactory, SettingFactory, DiscountCodeFactory,
    RatePlanFactory, AuditLogFactory, RoleFactory, PermissionFactory,
    GuestMergeLogFactory, MergeBlocklistFactory,
)

# BAD: Model(...) + db.session.add/commit
# GOOD: CallFactory(call_id="123", clid="+48123")  — auto-commit, sensowne defaults
```

## Fixture, markery, RBAC

- Fixture: **`db`** (nie `db_session`, nie `test_db`)
- Markery: `pytestmark = pytest.mark.unit/api/integration/security` — WYMAGANE w kazdym pliku
- RBAC: `UserTenantFactory(user=user, tenant_id=1, role_id=3)` + `make_jwt(user_id=1, tenant_id=1, role='admin', permissions=['*'])`

## Mockowanie

| Mockuj | NIE mockuj |
|--------|-----------|
| Zewnetrzne API (Zadarma, Gemini, OpenAI) | Wlasne serwisy |
| Filesystem, network, czas, losowosc | SQLAlchemy/DB, logike biznesowa |
| Celery tasks (`.delay()`, `.apply_async()`) | Model queries |

TestProviders: sprawdz `tests/helpers` (`TestZadarmaClient`, `TestTranscriptionProvider`, etc.)

## Konwencja

```python
def test_<co>_should_<wynik>_when_<warunek>(self, db):
    """
    Given: [stan]  When: [akcja]  Then: [wynik]
    """
    # Arrange / # Act / # Assert
```

## Anti-Patterns

| DON'T | DO |
|-------|-----|
| `pytest` lokalnie | `./cli.py test run` |
| `npx playwright` bezposrednio | `./cli.py e2e test` |
| `Model(...)` + `db.session.add()` | `ModelFactory(...)` |
| `db_session` / `test_db` | `db` |
| Mock everything | Mock only external |
| `-g all` / full E2E po kazdym tasku | Punktowo, full przed PR |
| `User.role` (legacy) | `UserTenantFactory` (RBAC) |
