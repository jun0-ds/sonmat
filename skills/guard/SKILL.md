---
name: guard
description: Guardrails — pre-commit verification, scope checks, discipline violation detection, novel trap flagging.
---

# Guard — Guardrail Skill

Automatic verification layer running in the main session (System 1). No agent spawn.

---

## 1. Pre-Commit Verification

Before any commit, check in order:

### Test pass confirmation
- If tests exist, run them before commit. Fail → block commit.
- "No tests, so just commit" is not allowed.

### Claims backed by execution
- "It works" must be backed by actual output (logs, test results). Not by speculation.

### Sensitive file blocking
- `.env`, `credentials.*`, `secrets.*`, `*.pem`, `*.key` in staging → immediate block.
- Also check `.gitignore` coverage.

---

## 2. Scope Check

### Scope creep detection
- Flag file changes beyond the requested scope.
- "This button color change" → refactoring the component tree = scope creep.

### Impulse suppression
- Unrelated improvements noticed during work → note them, don't include in current commit.

### Scope expansion requires confirmation
- If broader changes are needed, ask the user first. Never expand silently.

---

## 3. Project Rule Discovery

During work, watch for implicit rules the user assumes you know:

- **Direct statement**: "이 프로젝트에서는 항상 X" → propose immediately.
- **Repeated correction**: Same fix requested 2+ times → MUST propose as rule.
- **Structural inference**: Config files, test patterns, naming conventions that imply rules.

When spotted:
```
💡 Project rule detected: {draft rule}
   Add to CLAUDE.md? [Yes / No / Rephrase]
```

Write to `## Project Rules` section in CLAUDE.md only after user confirms.
This is how the "빈 공간" shrinks over time — rules accumulate from practice, not declaration.

---

## 4. Discipline Violation

### Check against core.md + hints.md
- Compare current actions against the active discipline (core verification principles + domain hints).
- On violation: stop, warn, suggest the correct action.
- User can explicitly override.

---

## 4. Completion Review (Verification Discipline Applied)

Before declaring "done", apply the verification discipline:

### Break it
- Re-read the full diff as if trying to find what's wrong.
- What input would make this code fail? What edge case was missed?

### Cross it
- Check downstream: files that depend on what changed. References, config, paths still valid?
- Does the change work from a different entry point?

### Ground it
- Was the fix verified by actual execution, or just by reading the code?
- If only read → run it.

---

## 5. Novel Trap Flagging + Memory Write

When a verification failure is discovered that is NOT covered by existing hints or memory:

1. **Flag** it as `Novel trap` in the output.
2. **Describe**: what happened, why existing discipline didn't catch it, what would have caught it.
3. **Propose** a memory record to the user:
   - Project-specific lesson → `{project}/.claude/sonmat/{name}.md`
   - Universal lesson → `~/.claude/sonmat/memory/trap_{name}.md`
4. **Write** only after user confirms. Use this format:

```markdown
# Trap: {title}

## Pattern
{What went wrong and why it wasn't caught}

## Lesson
{What to do differently — tied to Break/Cross/Ground}

## Applies to
{When this trap is likely to recur}
```

**This is not optional.** If guard detects a novel trap and does NOT propose a memory record, the verification discipline was not fully applied. The memory system grows through practice, not pre-definition.

### GitHub feedback (optional)

After writing a memory record, offer to submit it as a GitHub issue to the sonmat repo:

```
💬 This trap could help other sonmat users. Submit to GitHub?
   Your privacy is respected — only the abstracted pattern is sent,
   no conversation content or personal data.

   Below is EXACTLY what will be sent:

   Title: Trap: {title}
   Pattern: {abstracted pattern}
   Discovered via: {method}

   [Yes / No / Edit first]
```

If user approves: `gh issue create --repo jun0-ds/sonmat --template trap-report.md`
If user wants to edit: show the full issue body, let them modify, then submit.
**Never send without showing the content first.**

---

## 6. Severity

| Severity | Symbol | Target | Action |
|----------|--------|--------|--------|
| **Warning** | ⚠️ | Scope creep, discipline violation | Warn + suggest alternative. Proceed if user allows. |
| **Block** | 🚨 | Sensitive files, security risk | Immediate stop. Re-confirm even after user allows. |

Same-category warnings repeated 3+ times in a session → collapse to one-line summary.

---

## 7. Operation Mode

This guardrail operates at **System 1 level**:
- No agent spawn.
- Runs in main session, immediately.
- Always on unless user explicitly disables.
- When triggered, state what was detected concisely.
