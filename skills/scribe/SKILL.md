---
name: scribe
description: Background meta channel — dispatches sonmat-scribe agent for bridge notes, journaling, and progress tracking after foreground work completes.
---

# Scribe — Background Meta Channel

Scribe is not a foreground skill. It is the protocol for dispatching the sonmat-scribe agent in the background after work completes.

---

## Dispatch Protocol

### When to dispatch

| Condition | Dispatch? | Functions |
|-----------|-----------|-----------|
| Loop exit with **keep** | Yes | bridge + journal + progress |
| Loop exit with **discard** | Yes | journal only |
| Non-loop task completed (3+ files changed) | Yes | bridge + journal |
| Non-loop task completed (1-2 files) | No | overhead > value |
| Session ending with unfinished context | Yes | bridge only |
| L0 / trivial task | No | — |

### How to dispatch

Spawn `sonmat-scribe` as a background agent with this prompt structure:

```
## Scribe Dispatch

**Mode**: {bridge | journal | progress | all}
**Timestamp**: {ISO 8601, KST}

### Artifacts
- Git diff: {summary or "see below"}
- Changed files: {list}
- Loop report: {paste if available, or "N/A"}
- Test results: {pass/fail summary, or "N/A"}

### Context hint
{1-2 sentences about what was done — enough for scribe to write a useful bridge note.
This is the ONLY conversation context scribe receives. Be precise.}
```

### After dispatch

- Do NOT wait for scribe to finish. Continue with user interaction.
- Scribe writes to `.claude/sonmat/bridge-note.md`, `.claude/sonmat/journal.md`, and `progress.md`.
- On next task start, read `bridge-note.md` if it exists. Use it as context, then proceed.

---

## Bridge Note Consumption

At the start of any non-trivial task:

1. Check if `.claude/sonmat/bridge-note.md` exists in the project.
2. If yes, read it silently. Use the context but don't quote it to the user.
3. If a carry-forward item is directly relevant to the new task, mention it naturally:
   ```
   참고: 이전 작업에서 {relevant item}이 나왔는데, 이번에 연관될 수 있어요.
   ```
4. If nothing is relevant, ignore it.

---

## Journal Access

The journal at `.claude/sonmat/journal.md` is a passive record. It is NOT loaded into context automatically.

Read it only when:
- User asks "what did we do last time?"
- User asks for progress summary
- Retrospective or planning needs historical context

---

## Progress Management (absorbed from plan skill)

### What scribe handles (background)
- Checking off completed tasks/phases in `progress.md`
- Adding completion timestamps
- Committing with `progress: {item} done`

### What stays in foreground
- Creating `progress.md` (user decision)
- Adding new milestones/phases (structural change = loop L3)
- Reordering or reprioritizing (user decision)

### Milestone planning (formerly plan skill)
Milestone-level planning ("create roadmap", "restructure milestones") is now handled by loop's L3 escalation. The planning questions from the old plan skill are absorbed into loop's [Plan] phase when escalated to L3.

---

## File Locations

| File | Location | Lifecycle |
|------|----------|-----------|
| `bridge-note.md` | `.claude/sonmat/bridge-note.md` (project) | Overwritten each dispatch |
| `journal.md` | `.claude/sonmat/journal.md` (project) | Append-only, archived at 50 entries |
| `journal-archive.md` | `.claude/sonmat/journal-archive.md` (project) | Long-term storage |
| `progress.md` | Project root | Managed jointly (foreground creates, scribe updates) |
