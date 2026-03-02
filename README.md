# Rezavo Plugins

Plugin marketplace for Rezavo project.

## Plugins

### rr (v2.1.5)

Workflow engine: 20 skilli, 5 agentów, 4 komendy, hooks. Wymusza dyscyplinę procesu (brainstorm → plan → execute → verify → audit → finish).

### rrz (v2.0.0)

Z.AI compatible fork of rr — no `model:` params, works with any backend.

## Instalacja na nowej maszynie

### 1. Zainstaluj marketplace

```bash
claude /plugin     # → Install → Git URL
# URL: https://github.com/<org>/rezavo-plugins.git
# Wybierz: rr
```

### 2. Zainstaluj wymagane pluginy official

```bash
claude /plugin     # → Install → Official → wybierz po kolei:
```

| Plugin | Cel | Wymagany? |
|--------|-----|-----------|
| `rr@rezavo-plugins` | Workflow engine | **TAK** |
| `context7@claude-plugins-official` | Docs bibliotek (MCP) | TAK |
| `playwright@claude-plugins-official` | Browser/E2E (MCP) | TAK |
| `pyright-lsp@claude-plugins-official` | Python type check | TAK |
| `plugin-dev@claude-plugins-official` | Rozwój rr pluginu | Opcjonalny |
| `learning-output-style@claude-plugins-official` | Learning mode | Opcjonalny |
| `claude-md-management@claude-plugins-official` | CLAUDE.md audit | Opcjonalny |

### 3. Konfiguracja pluginów per projekt

Pluginy włączamy w **project scope** (`.claude/settings.local.json`), NIE w user scope (`~/.claude/settings.json`).

```jsonc
// .claude/settings.local.json — sekcja enabledPlugins
{
  "enabledPlugins": {
    "rr@rezavo-plugins": true,
    "context7@claude-plugins-official": true,
    "playwright@claude-plugins-official": true,
    "pyright-lsp@claude-plugins-official": true,
    "plugin-dev@claude-plugins-official": true,
    "learning-output-style@claude-plugins-official": true,
    "claude-md-management@claude-plugins-official": true
  }
}
```

**User scope (`~/.claude/settings.json`) powinien mieć pusty `enabledPlugins: {}`** — zapobiega duplikacji i konfliktom między projektami.

### 4. Weryfikacja

```bash
claude
# W sesji:
/skills          # Powinny być widoczne rr:* skills
/plugin          # Status zainstalowanych pluginów
```

### Pluginy do NIE instalowania

Te pluginy duplikują to co rr robi lepiej:

| Plugin | Dlaczego nie | Odpowiednik w rr |
|--------|-------------|-------------------|
| `superpowers` | rr jest forkiem superpowers | rr = superpowers + custom |
| `code-review` | Generyczny review | rr:Fletcher |
| `pr-review-toolkit` | 6 generycznych agentów | rr:Fletcher + Javert + Paranoik |
| `code-simplifier` | Simplify agent | rr:Fletcher (sekcja Simplicity) |
| `feature-dev` | Generyczny workflow | rr:brainstorming + writing-plans + executing-plans |
| `security-guidance` | PreToolUse hook | rr:Paranoik |

### Różnice między środowiskami

| Środowisko | Hostname | IP | Pluginy | Uwagi |
|------------|----------|----|---------|-------|
| **PROD** (.210) | `pytek` | .210 | Pełny zestaw | **TYLKO ODCZYT** bez zgody usera — rr respektuje CLAUDE.md |
| **STAGING** (.231) | `pytek-dev` | .231 | Pełny zestaw | Testy z userami, sync z PROD |
| **DEV-1** (.232) | `pytek-dev` | .232 | Pełny zestaw | Pełny dostęp (agenci) |
| **DEV-2** (.233) | `pytek-dev` | .233 | Pełny zestaw | Pełny dostęp (agenci) |

Wszystkie środowiska mają Claude Code z identyczną konfiguracją pluginów. Na PROD ograniczenia wynikają z CLAUDE.md (zakaz modyfikacji DB, restartów, zmian konfiguracji bez zgody), nie z pluginów.

`settings.local.json` jest w `.gitignore` — każda maszyna musi być skonfigurowana osobno.

### 5. Posprzątaj stare custom commands

Projekt miał legacy komendy w `.claude/commands/` sprzed rr. Zostały usunięte — rr je zastępuje:

| Usunięta komenda | Odpowiednik w rr |
|------------------|------------------|
| `/fix` | `rr:systematic-debugging` + `rr:test-driven-development` |
| `/security-audit` | `rr:audit` (3 agentów: Fletcher, Javert, Paranoik) |
| `/verify` | `rr:audit` + `rr:pre-merge-review` |

Jedyna pozostała komenda projektowa: `/update-pytek-plugin` (porównanie rr z upstream superpowers).

Jeśli na maszynie nadal są stare komendy:

```bash
# Sprawdź
ls .claude/commands/
# Powinien być TYLKO: update-pytek-plugin.md
# Jeśli są fix.md, security-audit.md, verify.md — usuń:
rm .claude/commands/fix.md .claude/commands/security-audit.md .claude/commands/verify.md
```

## Editing plugins

### Checklist

1. Edit skills/agents/commands in `plugins/rr/`
2. Bump version in `plugins/rr/.claude-plugin/plugin.json`
3. Update version in `.claude-plugin/marketplace.json` (must match)
4. Commit + push
5. User runs `/plugins update` to pull new version

### Version bumping

Three places to keep in sync per plugin:

| File | Field |
|------|-------|
| `plugins/<name>/.claude-plugin/plugin.json` | `"version"` |
| `.claude-plugin/marketplace.json` | `"version"` in plugins array |

Versions must match. Claude Code reads `marketplace.json` to discover available plugins.

### Skills to use when editing

| Task | Skill |
|------|-------|
| Creating/editing skills | `rr:writing-skills` — TDD for docs, pressure testing |
| Validating plugin structure | `plugin-dev:plugin-validator` |
| Reviewing skill quality | `plugin-dev:skill-reviewer` |
| Understanding skill structure | `plugin-dev:skill-development` |

### Structure

```
.claude-plugin/
  marketplace.json          ← plugin registry (Claude Code reads this)
plugins/
  rr/
    .claude-plugin/
      plugin.json           ← plugin metadata + version
    agents/                 ← subagent definitions
    commands/               ← slash commands
    hooks/                  ← event hooks
    skills/                 ← skill definitions (SKILL.md per skill)
  rrz/
    (same structure, Z.AI compatible)
```
