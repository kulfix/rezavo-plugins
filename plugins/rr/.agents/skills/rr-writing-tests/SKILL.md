---
name: rr-writing-tests
description: Codex port of rr:writing-tests workflow. Use when task matches the original rr skill intent.
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

## E2E Tests (Playwright)

E2E weryfikuja Acceptance Scenarios z design doc. Pisz PO implementacji.

- **Lokalizacja:** `tests/e2e/features/` (feature), `tests/e2e/multi-tenant/` (isolation)
- **Login:** `loginViaAPI(page)` z `fixtures/config.ts` — NIGDY przez UI
- **Nazwy:** `SC-XX:` prefix (atomic), `JOURNEY:` prefix (chain ≥3 atomic)
- **Helpers MT:** `loginAs()`, `switchTenantAPI()`, `getAuthMe()` z `multi-tenant/helpers.ts`
- **Run:** `./cli.py e2e test features` (local), `gh workflow run e2e-modular.yml` (CI)

| DON'T | DO |
|-------|-----|
| `networkidle` | Explicit selectors (`waitFor`, `toBeVisible`) |
| `waitForTimeout()` | `waitForResponse()` lub `locator.waitFor()` |
| Soft assertions (`if (exists) { ok } else { log }`) | Hard assertions (`expect(...).toBeVisible()`) |
| UI login | `loginViaAPI(page)` |
| Hardcoded URLs | `BASE_URL` from config |
| Duplicate login in helpers | Shared `getApiToken(request)` helper |
