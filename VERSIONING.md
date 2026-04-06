# Versioning

sonmat follows [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`.

## What each number means

| | When to bump | Example |
|---|---|---|
| **MAJOR** | Breaking changes — discipline structure, skill interface, or hook contract changes that require users to update their setup | `1.0.0` → `2.0.0` |
| **MINOR** | New features — new skills, new domain hints, multi-CLI support, new capabilities that don't break existing setups | `0.2.1` → `0.3.0` |
| **PATCH** | Fixes — typos, wording improvements, bug fixes in hooks/scripts | `0.3.0` → `0.3.1` |

## How to release

1. Update version in both files:
   - `.claude-plugin/plugin.json` → `"version": "X.Y.Z"`
   - `.claude-plugin/marketplace.json` → `"version": "X.Y.Z"` (appears twice)

2. Commit:
   ```bash
   git add -A
   git commit -m "release: vX.Y.Z — (one-line summary)"
   ```

3. Tag:
   ```bash
   git tag vX.Y.Z
   git push origin main --tags
   ```

## Version history

| Version | Date | Summary |
|---------|------|---------|
| `0.7.0` | 2026-04-06 | Add Rhythm Rules (Pace/Weight/Learn) to core discipline. Rename `/imp` → `/devil`. Add Reduce hint to Dev domain. |
| `0.6.1` | 2026-04-03 | Fix skill discovery — flatten skills/ directory, rename loop → autoloop (built-in collision) |
| `0.6.0` | 2026-04-02 | Add `/imp` skill — devil's advocate for reasoning. Counter-arguments against interpretations and irreversible decisions |
| `0.4.0` | 2026-04-01 | Prompt-first architecture — hook additionalContext → 0, discipline via CLAUDE.md → core.md reference chain |
| `0.3.2` | 2026-04-01 | Inspect suggestion system — concrete trigger conditions, task-scoped activation, auto-off |
| `0.3.1` | 2026-04-01 | Add `/inspect` skill (deep inspection mode), prompt-first architecture principle |
| `0.3.0` | 2026-04-01 | Multi-CLI support (Codex/Gemini), sonmat as single directory, embed discipline in instruction files |
| `0.2.1` | 2026-03-31 | Restructured discipline (thinking rules + action rules), polyglot hook, nickname system |
| `0.1.0` | 2026-03-29 | Initial release — core discipline, guard/autoloop/plan skills, worker agent |
