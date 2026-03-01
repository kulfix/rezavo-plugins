# Rezavo Plugins

Plugin marketplace for Rezavo project.

## Plugins

### rr

Workflow plugin extending superpowers with feature-context, audit gate, and development skills.

### rrz

Z.AI compatible fork of rr — no `model:` params, works with any backend.

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
