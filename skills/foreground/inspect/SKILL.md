---
name: inspect
description: Deep inspection mode — expands verification scope beyond the immediate change to side effects, dependencies, and cross-cutting concerns.
user-invocable: true
---

# Inspect — Deep Inspection Mode

User-activated mode that widens the verification lens. Default mode checks if the change works. Inspect mode checks if the change is safe.

Activate: `/inspect`
Deactivate: `/inspect off` or session end.

---

## What changes when inspect is on

### Scope expansion

| Default | Inspect |
|---------|---------|
| Changed files only | Changed files + direct dependents |
| Tests pass? | Tests pass + are tests covering the right cases? |
| Does it work? | Does it work + what could it break? |

### Additional checks (on top of guard)

1. **Dependency trace**: For each modified function/module, list callers and downstream consumers. Flag any that might behave differently.
2. **Side effect scan**: State changes (DB writes, file writes, env mutations, global state) — are they intended? Are they reversible?
3. **Assumption audit**: What does this code assume about its inputs, environment, or execution order? Are those assumptions documented or tested?
4. **Rollback viability**: If this change goes wrong in production, how do you undo it? Is there a migration, a flag, a revert path?

### Reporting

When inspect finds something, report concisely:

```
[inspect] {category}: {what was found}
  Impact: {who/what is affected}
  Suggestion: {what to do about it}
```

When inspect finds nothing noteworthy:

```
[inspect] Clean — no side effects or dependency risks detected.
```

---

## What does NOT change

- System 1/2 automatic switching — still automatic, still silent.
- Core discipline (core.md) — always active regardless of mode.
- Guard skill — always active regardless of mode.
- Speed on simple tasks — inspect adds checks, not slowness. Trivial changes still get trivial treatment.

---

## When to suggest activation

Don't activate automatically. Suggest once per task when trigger conditions are met.

### Trigger conditions (any one is enough)

| Category | Condition |
|----------|-----------|
| **Blast radius** | Change spans 5+ files, or modifies a file imported by 3+ others |
| **Shared code** | Editing shared utilities, base classes, config generators, or sync scripts |
| **Infrastructure** | Touching DB schemas, env vars across services, Milvus/Redis contracts, cron schedules |
| **Auth/Security** | Modifying authentication, API keys, permissions, or credential paths |
| **Data migration** | INSERT/UPDATE/DELETE on production data, schema changes, index rebuilds |
| **Cross-service** | Change requires coordinated deployment to multiple servers/services |
| **User signal** | User says "risky", "careful", "worried", "double-check" |

### Suggestion format

One line, no preamble:

```
[sonmat] {what was detected}. /inspect 켤까요?
```

Examples:
- `[sonmat] 6개 서비스 filter_env 동시 수정. /inspect 켤까요?`
- `[sonmat] prod DB 스키마 변경 감지. /inspect 켤까요?`
- `[sonmat] sync-env.sh + 4개 .env 배포. /inspect 켤까요?`

### Scope management

- User accepts → inspect activates for the current task only
- Task completes or user says `/inspect off` → inspect deactivates
- Don't re-suggest for the same task after user declines

---

## Design rationale

Mode activation is the user's decision. The user chooses when to pay the cost of wider verification. sonmat provides the lens; the user decides when to put it on. Automatic suggestion lowers the chance of missing risky changes; manual activation preserves user agency.
