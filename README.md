# Rezavo Plugins

Plugin marketplace for Rezavo project.

## Plugins

### rr (v1.11.0)

Workflow engine: 19 skilli, 8 agentów, 4 komendy, hooks. Wymusza dyscyplinę procesu (brainstorm → plan → execute → verify → audit → finish).

### rrz (v1.4.0)

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
| `code-simplifier` | Simplify agent | rr:Diogenes |
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

## Editing plugins

### Checklist

1. Edit skills/agents/commands in `plugins/rr/`
2. Bump version in `plugins/rr/.claude-plugin/plugin.json`
3. Update version in `.claude-plugin/marketplace.json` (must match)
4. If rrz exists — sync changes: copy files, `rr:` → `rrz:`, remove `model:` refs
5. Bump rrz version in both `plugin.json` and `marketplace.json`
6. Commit + push
7. User runs `/plugins update` to pull new version

### Version bumping

Three places to keep in sync per plugin:

| File | Field |
|------|-------|
| `plugins/<name>/.claude-plugin/plugin.json` | `"version"` |
| `.claude-plugin/marketplace.json` | `"version"` in plugins array |

Versions must match. Claude Code reads `marketplace.json` to discover available plugins.

### rrz sync

rrz is a fork of rr for Z.AI backend. After editing rr:

```bash
# Copy changed files
cp plugins/rr/skills/<skill>/SKILL.md plugins/rrz/skills/<skill>/SKILL.md

# Apply transforms
sed -i 's/\brr:/rrz:/g' plugins/rrz/skills/<skill>/SKILL.md

# Remove model references (rrz only)
# - Delete `model: sonnet/opus/haiku` from agent frontmatter
# - Replace "Sonnet subagent" → "subagent" in skill content
# - Delete `model: "sonnet"` lines from code blocks
```

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
