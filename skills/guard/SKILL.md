---
name: guard
description: Main-side verification checks — pre-commit test / sensitive-file blocking, discipline conformance, novel-trap detection. Pure verify-and-flag; persistence of findings is scribe's job, intent-artifact match is witness's.
user-invocable: false
---

# Guard — Main-Side Verification Checks

Automatic verification layer running in the main session (System 1). No agent spawn.

Guard covers **verification** checks that main can reliably do on itself: sensitive files, test execution, discipline conformance, and detection of novel traps during work. Guard is pure verify-and-flag — it detects, it warns, it blocks. It does **not** record, accumulate, or persist findings; those belong to scribe (post-work persistence). It also does **not** verify whether the artifact matches the user's intent; that check is structurally unreliable when done inside the agent that produced the artifact, and is delegated to [witness](../../agents/sonmat-witness.md).

**Scope boundaries**:

| Check kind | Owner | Why |
|---|---|---|
| Test execution, sensitive file blocking, discipline conformance, novel-trap detection | **guard** | Real-time verification during work; synchronous check-and-block at decision points |
| Scope match (is this within what was asked?), content match (does it do what was asked?), framing-derived scope | **witness** | Intent-artifact comparison — requires protocol isolation from main's reasoning (see witness.md §Isolation stack for what "isolation" means on current Claude Code) |
| Recording novel traps, writing project rules to CLAUDE.md, journaling verdicts, bridge notes, progress tracking | **scribe** | Post-work persistence — what the session learned that should outlive it |

Guard detects and flags. Scribe persists what was flagged. Witness checks intent-artifact match in isolation. Three different axes on the same work.

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

## 2. Discipline Violation

### Check against core.md + hints.md
- Compare current actions against the active discipline (core verification principles + domain hints).
- On violation: stop, warn, suggest the correct action.
- User can explicitly override.

**Note**: Discipline conformance is a main-side check because discipline is a shared rule set, not a user-specific intent. Witness is deliberately excluded from discipline injection (see witness.md §Operating principles) — it is a comparator, not a rule-follower.

---

## 3. Novel Trap Detection

When a verification failure is discovered that is NOT covered by existing hints or memory, guard flags it as a **novel trap** — a class of failure that existing discipline and memory did not anticipate. Guard's job stops at detection and flagging; recording, abstracting, and persisting the trap belong to scribe.

### What guard does

1. **Detect**: a verification failure occurs, and the failure pattern does not match any existing hint or memory entry.
2. **Flag** it in the output as `Novel trap` with a 1-2 line description: what happened, why existing discipline didn't catch it.
3. **Dispatch to scribe** at the end of the current task with the trap payload (pattern, context, what-would-have-caught-it). See `skills/scribe/SKILL.md` §Novel Trap Recording.
4. **Not optional**: guard must dispatch. If a novel trap is detected and not dispatched, the verification layer is not complete.

Guard does **not** write memory files itself, does not propose formats to the user, and does not manage the sonmat memory directory. All of that is scribe's territory — guard's role is to notice that something new happened and hand the raw signal off.

---

## 4. Severity

| Severity | Symbol | Target | Action |
|----------|--------|--------|--------|
| **Warning** | ⚠️ | Discipline violation, novel trap detected | Warn + dispatch to scribe for persistence (traps). Proceed if user allows. |
| **Block** | 🚨 | Sensitive files, security risk, failing tests | Immediate stop. Re-confirm even after user allows. |

Same-category warnings repeated 3+ times in a session → collapse to one-line summary.

Scope creep is *not* listed here — that category moved to witness's intent-scope mismatch check. Guard does not judge scope against user intent; witness does, with protocol isolation.

Project rule discovery is *not* listed here — that category moved to scribe. Guard detects and verifies; observing the user's patterns to propose project rules is accumulation work, and accumulation is scribe's axis.

---

## 5. Operation Mode

This guardrail operates at **System 1 level**:
- No agent spawn.
- Runs in main session, immediately.
- Always on unless user explicitly disables.
- When triggered, state what was detected concisely.

For the **protocol-isolated** verification layer (intent-artifact match, commit-gate BLOCK), see [witness](../../agents/sonmat-witness.md). Guard and witness are complementary Swiss-cheese layers, not substitutes — guard catches operational slips, witness catches intent drift that main's self-check structurally cannot.
