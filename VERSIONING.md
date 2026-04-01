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
| `0.3.1` | 2026-04-01 | Add `/inspect` skill (deep inspection mode), prompt-first architecture principle |
| `0.3.0` | 2026-04-01 | Multi-CLI support (Codex/Gemini), sonmat as single directory, embed discipline in instruction files |
| `0.2.1` | 2026-03-31 | Restructured discipline (thinking rules + action rules), polyglot hook, nickname system |
| `0.1.0` | 2026-03-29 | Initial release — core discipline, guard/loop/plan skills, worker agent |
