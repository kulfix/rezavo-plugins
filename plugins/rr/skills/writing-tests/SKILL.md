---
name: writing-tests
description: Use when creating test files, writing test functions, modifying existing tests, adding test coverage, or asking "how to test X". Also use when reviewing tests or setting up test data with factories.
---

# Writing Tests

Testy w Rezavo — factory-boy, realna logika, Docker only.

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
# GOOD: CallFactory(call_id="123", clid="+48123")
```

Defaults — podawaj tylko co sie rozni: [docs/claude/testing-guidelines.md](docs/claude/testing-guidelines.md)

## Fixture, markery, RBAC

- Fixture: **`db`** (nie `db_session`, nie `test_db`)
- Markery WYMAGANE w kazdym pliku:
  ```python
  pytestmark = pytest.mark.unit  # unit/api/integration/security
  ```
- RBAC:
  ```python
  user = UserFactory(username='operator')
  UserTenantFactory(user=user, tenant_id=1, role_id=3)
  token = make_jwt(user_id=user.id, tenant_id=1, role='admin', permissions=['*'])
  ```

## Konwencja nazw

```python
def test_<co>_should_<wynik>_when_<warunek>(self, db):
    # Arrange / Act / Assert
```

## Mockowanie

| Mockuj | NIE mockuj |
|--------|-----------|
| Zewnetrzne API (Zadarma, Gemini, OpenAI) | Wlasne serwisy |
| Filesystem, network, czas | SQLAlchemy/DB, logike biznesowa |
| Celery tasks (`.delay()`) | Model queries |

TestProviders: `tests/helpers` (`TestZadarmaClient`, `TestTranscriptionProvider`, etc.)

## Edge Cases — WYMAGANE

Kazdy test musi pokryc: null, empty, duplikaty, format miedzynarodowy, granice.

## Anti-Patterns

| DON'T | DO |
|-------|-----|
| `Model(...)` + `db.session.add()` | `ModelFactory(...)` |
| `test_db` / `db_session` | `db` |
| Mock everything | Mock only external |
| `User.role` (legacy) | `UserTenantFactory` (RBAC) |
| Skip edge cases | Cover null, empty, max |
| Jeden wielki test | Wiele malych testow |
