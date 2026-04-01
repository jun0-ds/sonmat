---
name: inspect
description: Deep inspection mode — expands verification scope beyond the immediate change to side effects, dependencies, and cross-cutting concerns.
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

Don't activate automatically. But suggest `/inspect` when:

- Modifying shared utilities, base classes, or core infrastructure
- Touching auth, payments, or data migration
- Refactoring that spans 5+ files
- User says "this is risky" or "be careful"

Suggestion format: `This touches [X]. Consider /inspect for wider verification.`

---

## Design rationale

Mode activation is the user's decision. The user chooses when to pay the cost of wider verification. sonmat provides the lens; the user decides when to put it on.
