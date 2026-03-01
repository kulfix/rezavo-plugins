---
name: testing-guidelines
description: Use when writing tests, reviewing tests, running tests, setting up test data, or asking "how to test". Covers Docker workflow, factories, fixtures, markers, RBAC setup, and test groups.
---

# Testing Guidelines

Testy w PyTek — Docker only, factory-boy, realna logika.

## Uruchamianie testow (DOCKER ONLY)

**NIGDY nie odpalaj `pytest` lokalnie.** Zawsze przez CLI w Docker:

```bash
./cli.py test up                # Start kontenerow (raz na sesje)
./cli.py test run -g fast       # Uruchom grupe
./cli.py test run -f tests/api/ # Uruchom sciezke
./cli.py test run -k "test_m1"  # Uruchom po keyword
./cli.py test down              # Stop kontenery
```

### Grupy testow

| Grupa | Opis | Czas |
|-------|------|------|
| `fast` | Unit testy (bez DB-heavy) | Szybki |
| `services` | Service layer | Sredni |
| `api` | API endpoints | Sredni |
| `models` | Modele | Sredni |
| `matching` | GST matching M1-M10 | Sredni |
| `integration` | Integration tests | Wolny |
| `security` | Security + quality gate | Wolny |
| `all` | Full suite | **>10 min** |

**Kiedy ktora grupa:**
- Po tasku: TYLKO testy dotyczace zmian (`-f`, `-k`, lub pasujaca grupa)
- Full suite (`-g all`): TYLKO na koniec feature/workflow, przed PR

### Opcje

```bash
./cli.py test run -g services -j 4   # Parallel (pytest-xdist)
./cli.py test run -m security        # Po markerze
./cli.py test groups                 # Pokaz wszystkie grupy
```

## Factory-boy (WYMAGANE)

**Zawsze uzywaj factories**, nie reczne `Model(...)`:

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

# BAD
call = Call(call_id="123", tenant_id=1, clid="+48123", sip="101")
db.session.add(call)
db.session.commit()

# GOOD — factory auto-commits, sensowne defaults
call = CallFactory(call_id="123", clid="+48123")
```

### Key defaults (podawaj tylko to co zmienione)

| Factory | Defaults |
|---------|----------|
| `CallFactory` | `tenant_id=1, clid="+48123456789", sip="105", seconds=300, disposition="answered"` |
| `UserFactory` | `password="Password123!", is_active=True` |
| `GuestFactory` | `tenant_id=1, customer_phone=Sequence, customer_name=Faker` |
| `OfferFactory` | `tenant_id=1, status="draft", language="pl"` |
| `KWHotelReservationFactory` | `tenant_id=1, status=4, matched=False` |
| `VisitorSessionFactory` | `tenant_id=1, url="https://example.com/page"` |

## Fixture `db`

Uzywaj `db` — NIE `db_session`, NIE `test_db`:

```python
def test_example(self, db):
    call = CallFactory()
    db.session.refresh(call)
    assert call.id is not None
```

## Markery (WYMAGANE)

Kazdy plik testowy **musi** miec `pytestmark`:

```python
import pytest
pytestmark = pytest.mark.unit         # tests/services/, tests/models/
pytestmark = pytest.mark.api          # tests/api/
pytestmark = pytest.mark.integration  # tests/integration/
pytestmark = pytest.mark.security     # tests/security/
```

## RBAC — testy z rolami

```python
# User z rola i tenant
user = UserFactory(username='operator')
UserTenantFactory(user=user, tenant_id=1, role_id=3)  # 3 = operator

# JWT token z permissions
def test_example(self, make_jwt, client):
    token = make_jwt(user_id=1, tenant_id=1, role='admin', permissions=['*'])
    headers = {'Authorization': f'Bearer {token}'}
    resp = client.get('/api/calls', headers=headers)
```

## Testuj REALNA logike

```python
# BAD — mock zwraca mock
@patch('app.services.guest.GuestRepository')
def test_link(self, mock_repo):
    mock_repo.find.return_value = MagicMock(id=1)
    assert result.id == 1  # Testuje MOCK, nie logike!

# GOOD — realna logika z DB + factory
@pytest.mark.integration
def test_should_link_guest_when_phone_matches(self, db):
    guest = GuestFactory(customer_phone="+48123456789")
    result = GuestMatchingService(db.session).link(session)
    assert result.guest_id == guest.id
```

### Kiedy mockowac?

| Mockuj | NIE mockuj |
|--------|-----------|
| Zewnetrzne API (Zadarma, Gemini, OpenAI) | Wlasne serwisy |
| Filesystem, network | SQLAlchemy/DB |
| Czas, losowosc | Logike biznesowa |
| Celery tasks (`.delay()`, `.apply_async()`) | Model queries |

### TestProviders (external API)

| Provider | Zastepuje |
|----------|-----------|
| `TestTranscriptionProvider` | WhisperX, Voxtral |
| `TestAnalysisProvider` | Ollama, Gemini |
| `TestZadarmaClient` | Zadarma API |
| `TestQdrantClient` | Qdrant |

## Konwencja nazewnictwa

```python
def test_<co>_should_<wynik>_when_<warunek>(self, db):
    """
    Given: [stan poczatkowy]
    When: [akcja]
    Then: [oczekiwany wynik]
    """
    # Arrange
    guest = GuestFactory(customer_phone="+48123456789")
    # Act
    result = service.match("+48123456789")
    # Assert
    assert result.guest_id == guest.id
```

## Edge Cases — WYMAGANE

```python
def test_should_match_when_exact_phone(self, db): ...
def test_should_return_none_when_no_phone(self, db): ...
def test_should_return_none_when_phone_empty(self, db): ...
def test_should_handle_international_format(self, db): ...
def test_should_handle_duplicate_phones(self, db): ...
```

## Checklist

- [ ] `pytestmark` w pliku
- [ ] Factories (nie reczne `Model(...)`)
- [ ] Fixture `db` (nie `db_session`/`test_db`)
- [ ] Nazwa: `test_<co>_should_<wynik>_when_<warunek>`
- [ ] Docstring Given/When/Then
- [ ] Komentarze `# Arrange / # Act / # Assert`
- [ ] Mockuje TYLKO external API
- [ ] Edge cases pokryte
- [ ] Uruchamiam przez `./cli.py test run` (nie `pytest`)

## Anti-Patterns

| DON'T | DO |
|-------|-----|
| `pytest` lokalnie | `./cli.py test run` w Docker |
| `Model(...)` + `db.session.add()` | `ModelFactory(...)` |
| `db_session` / `test_db` | `db` |
| Mock everything | Mock only external |
| `-g all` po kazdym tasku | `-g all` tylko przed PR |
| Skip edge cases | Cover null, empty, max |
| One giant test | Many small focused tests |
| `User.role` (legacy) | `UserTenantFactory` (RBAC) |
