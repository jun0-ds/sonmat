---
name: scribe
description: Post-work persistence layer — observes completed work and writes what should outlive the session. Bridge notes, journal, progress, project rules discovered from user corrections, novel traps detected by guard, witness verdicts.
user-invocable: false
---

# Scribe — Post-Work Persistence Layer

Scribe owns one axis of the sonmat system: **everything that should outlive the current session**. Bridge notes for the next session, journal entries for history, progress checkboxes for milestones, project rules discovered from repeated user corrections, novel traps flagged by guard, witness verdicts from the `[Judge]` pipeline. All persistence flows through scribe.

This is a role distinct from detection (guard), comparison (witness), or completeness (punch). Those skills find things. Scribe decides what of what they found is worth keeping, and where it goes.

Scribe is **not** user-invocable (no `/scribe` command). It is a protocol invoked by other skills — autoloop dispatches background scribe at loop exit, guard hands off novel traps and project rules during work, witness verdicts flow into scribe from the `[Judge]` pipeline. `user-invocable: false` is deliberate: scribe does not have a task the user thinks in terms of; it has persistence work that happens because other skills produced findings.

---

## Operation modes: synchronous vs background

Scribe runs in two distinct modes depending on what is being persisted. The distinction matters because they have different interaction contracts.

| Mode | When | Blocks main? | Operations |
|---|---|---|---|
| **Background** | After work completes (loop exit, task completion, session end) | No — main continues interacting with user | Bridge notes, journal appends, progress checkbox updates, witness verdict logging |
| **Synchronous** | During work, when a finding needs user confirmation before writing | Yes — main pauses to get user yes/no | Project rule proposals (writes to `CLAUDE.md`), novel trap proposals (writes to memory) |

Background writes are fire-and-forget: dispatch sonmat-scribe agent with artifacts, do not wait. Synchronous writes are confirmation-gated: main itself runs the proposal dialogue inline, because writing declarative files like `CLAUDE.md` or memory records must never happen without explicit user approval.

Both modes belong to scribe because the **axis is the same** (persistence of session findings) — only the interaction contract differs. Do not split them into separate skills; that would fragment the persistence axis and leave other skills unsure who to hand off to.

---

## Isolation boundaries (witness protection)

Scribe writes into channels that future sessions will read. This creates a potential re-injection path: if witness findings end up in bridge-notes that main reads next session, witness's protocol isolation would be defeated on the second run.

**The isolation boundary**:

- **Bridge notes** (read by main on next task start) must **not** contain witness findings, raw witness verdicts beyond a compact PASS/WARN/BLOCK marker, or anything main-synthesized from witness output. Main is allowed to see that witness ran and what the overall verdict was — it is not allowed to re-enter witness's citation content through the bridge-note channel.
- **Journal** (not auto-loaded, user-readable only) is the durable place where witness findings live. Journal is scribe's append-only record; witness findings go there in full.
- **CLAUDE.md Project Rules** and **memory trap records** are user-facing reference files, not main's automatic context. They are safe targets for synchronous writes.

Witness spawn prompts must **never** include bridge-notes, journal excerpts, or any scribe-managed file as input. Witness receives only raw user turns and the artifact; scribe-managed files are outside the witness input contract. This boundary is enforced by autoloop's Task-tool spawn composition (§6b Witness dispatch in `skills/autoloop/SKILL.md`): the spawn prompt template explicitly lists what goes in, and bridge-notes / journal are not in that list. Scribe carries the policy responsibility for not authoring the content that would then need to be excluded — if scribe ever writes witness content into a channel that flows back to main, the isolation is broken at the composition layer, even if the spawn template excludes it.

---

## Dispatch Protocol

### When to dispatch

| Condition | Mode | Functions |
|-----------|------|-----------|
| Loop exit with **keep** | Background | bridge + journal + progress + witness verdict |
| Loop exit with **discard** | Background | journal only |
| Non-loop task completed (3+ files changed) | Background | bridge + journal |
| Non-loop task completed (1-2 files) | — (no dispatch) | overhead > value |
| Session ending with unfinished context | Background | bridge only |
| L0 / trivial task | — (no dispatch) | — |
| **Novel trap detected by guard** (any task size) | **Synchronous** | `novel_trap` — user confirmation, then write to memory |
| **Project rule pattern detected** (any task size) | **Synchronous** | `project_rule` — user confirmation, then write to `CLAUDE.md` |

Synchronous dispatches (bottom two rows) are handled inline by main using the protocols in §Project Rule Recording and §Novel Trap Recording below. Background dispatches spawn the sonmat-scribe agent with the prompt structure below.

### How to dispatch (background)

Spawn `sonmat-scribe` as a background agent with this prompt structure:

```
## Scribe Dispatch

**Mode**: {bridge | journal | progress | witness_log | all}
**Timestamp**: {ISO 8601, KST}

### Artifacts
- Git diff: {summary or "see below"}
- Changed files: {list}
- Loop report: {paste if available, or "N/A"}
- Test results: {pass/fail summary, or "N/A"}
- Witness verdicts: {list of verdicts from the [Judge] pipeline this session — e.g. "PASS (iter 1), WARN (iter 2, not-covered-by-tests), PASS (iter 3)". "N/A" if none.}

### Context hint
{1-2 sentences about what was done — enough for scribe to write a useful bridge note.
This is the ONLY conversation context scribe receives. Be precise.}
```

### After dispatch

- Do NOT wait for scribe to finish. Continue with user interaction.
- Scribe writes `bridge-note.md` and `journal.md` to the per-project scribe dir (see File Locations), and `progress.md` to the project root.
- On next task start, read `bridge-note.md` if it exists. Use it as context, then proceed.

---

## Bridge Note Consumption

At the start of any non-trivial task:

1. Check if `bridge-note.md` exists in the scribe dir (see File Locations; legacy `.claude/sonmat/` as fallback).
2. If yes, read it silently. Use the context but don't quote it to the user.
3. If a carry-forward item is directly relevant to the new task, mention it naturally:
   ```
   참고: 이전 작업에서 {relevant item}이 나왔는데, 이번에 연관될 수 있어요.
   ```
4. If nothing is relevant, ignore it.
5. **Treat the bridge note as hypothesis, not fact**. The previous session may have written it under partial understanding. Before acting on a claim from the bridge note, verify it against the actual code/state. If the claim disagrees with what you observe, trust observation and flag the bridge-note divergence in your next dispatch.

---

## Bridge Note Authoring Principles

When scribe writes a bridge note, four principles are load-bearing. Sections beyond these are optional — write what the work demands, omit what would pad. (A3 lesson: what doesn't fit the page wasn't essential.)

1. **Open work in status form, never imperative.** Write "X is not yet implemented; depends on Y being finalized first" — not "Implement X next." Imperative phrasing makes the next session execute blindly without verifying the premise (Auftragstaktik intent-not-method principle, also Toby T2 handoff lesson). The next session decides what to do; scribe records what stands.
2. **Traps to Avoid is mandatory when present.** Failed approaches, dead ends, hypotheses that turned out wrong — these vanish from code but matter for the next session. If the work hit any failed branch, that record is part of the bridge note. (Phase 2 induction §15: minority/failed positions preserved are future optionality.)
3. **The bridge note is hypothesis, not fact.** Scribe writes from limited synthesis; the next session must verify. Phrase claims in a form that signals tentativeness ("appears to / observed / decided based on") rather than asserting. Include enough file/line references that the next session can confirm independently.
4. **Brevity over completeness.** Aim for a note the next session reads in under a minute. If detail is needed, link to a separate artifact (journal, ADR, report) rather than inlining. A bridge note that has to be skimmed is a bridge note that loses the point it was making.

Sections like Summary, Key Decisions, Relevant Files, Working Agreements, or a Prompt for New Chat may be useful — include them when the work justifies, skip them when they would be padding. The structure is free; the four principles above are not.

---

## Journal Access

The journal (`journal.md` in the scribe dir — see File Locations) is a passive record. It is NOT loaded into context automatically.

Read it only when:
- User asks "what did we do last time?"
- User asks for progress summary
- Retrospective or planning needs historical context

### Witness events in the journal

When a witness verdict is included in the dispatch artifacts, scribe records it as a discrete journal line (not just a summary). `BLOCK` and `WARN` events are particularly valuable as learning signals — they represent moments where main's self-interpretation diverged from the raw user intent, and are worth reviewing in retrospectives. `PASS` events record as a single compact line.

Witness verdicts go to the journal only. They do **not** go to bridge notes. The full rationale for this routing is in §Isolation boundaries at the top of this file — the short version is that bridge notes flow back into main's context on the next session, which would defeat witness's isolation guarantee on subsequent runs. Journal is read-on-demand and does not auto-inject, so it is safe.

---

## Project Rule Recording (absorbed from guard §2)

Project rules are implicit conventions the user assumes the assistant knows. Guard detects the signals during work; scribe persists them to `CLAUDE.md`.

### Signals that reach scribe

Guard (or main observation) dispatches a project-rule proposal to scribe when any of these occur:

- **Direct statement**: user says "이 프로젝트에서는 항상 X" or equivalent
- **Repeated correction**: same fix requested 2+ times
- **Structural inference**: config files, test patterns, or naming conventions imply a rule

### What scribe does

1. **Draft**: formulate the rule in one or two lines, in the project's primary language.
2. **Propose synchronously** (not background) — this is one of the few scribe operations that blocks on user confirmation, because the outcome writes into a file the user reads directly:

   ```
   💡 Project rule detected: {draft rule}
      Add to CLAUDE.md? [Yes / No / Rephrase]
   ```

3. **Write** to the `## Project Rules` section of the project's `CLAUDE.md` only after user confirms. Create the section if it does not exist.
4. **Never write without confirmation**. Project rules are declarative and persistent; a wrong one is expensive to debug later.

This is how the "빈 공간" shrinks over time — rules accumulate from practice, not declaration. But the accumulation itself is scribe's axis: observing patterns, abstracting them, persisting the abstraction.

---

## Novel Trap Recording (absorbed from guard §4)

A novel trap is **either** a verification failure pattern that existing discipline and memory did not anticipate, **or** a "spec didn't cover this" moment — a case where discipline ran fine but the existing rules/spec/contract had a gap that the situation exposed. Both are inputs to memory because both signal that the system's prior model of "what to watch for" is incomplete.

The two flavors:

- **Verification failure** (classic novel trap): discipline ran but missed a real problem. The catch-signal is what would have caught it earlier.
- **Spec gap** (improvisation surfacing): discipline didn't fail; the spec/rule was simply silent on the case, and the actor had to improvise. The catch-signal is what kind of case the spec should have covered.

Both reach scribe via the same channel — guard for the first, main observation or autoloop retrospective for the second. The Wehrmacht *Gefechtsbericht* lesson: a successful improvisation that revealed a doctrinal gap is just as valuable as a verification failure, and both belong in the next edition of the rule book.

### What scribe receives from guard (or main observation)

The dispatch includes:
- **Flavor**: `verification_failure` or `spec_gap`
- **Pattern**: what was missed and how
- **Context**: what was being done when it surfaced
- **Catch-signal**: the specific check or signal that would have caught it earlier (verification failure) or the kind of case the spec should have covered (spec gap)

### What scribe does

1. **Abstract the pattern**: convert the concrete incident into a general-form description. Strip project-specific identifiers that would prevent reuse.
2. **Choose the scope**:
   - Project-specific lesson → `{name}.md` in the per-project scribe dir (see File Locations)
   - Universal lesson (applies across projects) → `trap_{name}.md` in `$SONMAT_MEMORY_DIR` (default `~/.sonmat/memory/`)
3. **Propose** the memory record synchronously:

   ```
   💡 Novel trap detected: {short title}
      Record as {project | universal} memory? [Yes / No / Edit first]
   ```

4. **Write** only after user confirms, using this format:

```markdown
# Trap: {title}

## Pattern
{What went wrong and why it wasn't caught}

## Lesson
{What to do differently — name the specific check or signal that would have caught this trap earlier}

## Applies to
{When this trap is likely to recur}
```

5. **Spec amendment proposal (only when flavor = `spec_gap` AND project has `docs/specs/` with `sonmat.spec_awareness: enabled`)**: if both conditions hold, after writing the trap memory, offer to generate a successor spec rather than only logging. This implements ADR `2026-04-26-spec-evolution-loop.md` (T2-C). Conditions:

   - Project must have `docs/specs/` directory with an `_index.md` declaring `sonmat.spec_awareness: enabled`. If absent, skip this step entirely — Stage 0 projects log to trap memory only.
   - The novel trap dispatch must carry `flavor: spec_gap` (i.e., the action ran outside spec coverage, not a verification failure of existing discipline).
   - There must be a clearly identifiable existing spec the gap relates to. If the gap doesn't map to any existing spec, skip — this is "new spec needed" territory, which is user-initiated, not scribe-initiated.

   When all three hold, propose synchronously:

   ```
   💡 Spec gap detected: {pattern}
      Maps to: {existing spec id or section}
      Catch-signal: {what spec clause would have caught this}

      Propose amendment via successor spec? [Yes / No log only / Edit first]
   ```

   On `Yes`: generate a draft successor spec at `docs/specs/SPEC-{YYYYMMDD}-{slug}.md` using the project's spec template (or the sonmat default at `templates/spec-template.md` if no project template exists). Set `supersedes: {original-spec-id}`. Update the original spec's frontmatter to add `superseded-by: {new-spec-id}` and propose `status: archived` only after user confirms full supersession (vs partial amendment that leaves original active).

   On `Edit first`: show the draft, let user modify, then write.

   On `No log only`: do not generate successor. Trap memory record is sufficient.

   **Closure ceremony auto-trigger**: if user accepts full supersession (original `status: archived`), prompt for sunset date and fork-prevention declaration per `discipline/hints.md` "Closure ceremony" hint (PEP 404 model). Do not write `archived` without this metadata.

   **LEARN journal entry (always, regardless of Yes/No/Edit)**: append to `journal.md`:

   ```markdown
   ## YYYY-MM-DD [hostname] — Spec gap AAR
   - Trigger: {what was outside spec}
   - Maps to: {existing spec id or "no clear mapping"}
   - Catch-signal: {what spec clause would have caught it}
   - Decision: {amendment generated SPEC-XXX | log only | edited then generated}
   - Reasoning: {1-line justification}
   ```

   This is the LPS-5-conversation LEARN step (`docs/research/architecture-methodology-and-spec-discipline.md` A4). Captured even when no amendment generated, because the deferred decisions are themselves data for later retrospective.

6. **Dispatch GitHub feedback (optional)**: after writing, offer to submit as a GitHub issue to the sonmat repo. This is purely optional — if the user declines, the memory record stays local.

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

   If user approves: `gh issue create --repo jun0-ds/sonmat --template trap-report.md`.
   If user wants to edit: show the full issue body, let them modify, then submit.
   **Never send without showing the content first.**


**This is not optional on guard's side.** If guard detects a novel trap and does not dispatch to scribe, the verification + persistence loop is broken. The memory system grows through practice, not pre-definition, and scribe is the step that converts practice into persistence.

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

sonmat state lives **outside `.claude/`** — Claude Code edit-protects every `.claude/` directory (prompting on each Edit/Write, unsuppressable except in `bypassPermissions`). Resolution:

- **Per-project scribe dir** (`<scribe-dir>` below) = `$SONMAT_PROJECTS_BASE/<slug>` (default `~/.sonmat/projects/<slug>`), where `<slug>` is the cwd path with `/`→`-` (e.g. `/home/u/proj` → `-home-u-proj`), mirroring Claude Code's own `~/.claude/projects/`.
- **Universal memory** = `$SONMAT_MEMORY_DIR` (default `~/.sonmat/memory/`).
- The session-start hook creates these and migrates legacy `.claude/sonmat/` + `~/.claude/sonmat/memory/` automatically. **Fallback**: if `<scribe-dir>` is empty but a legacy `.claude/sonmat/` has content, read the legacy path.

| File | Location | Lifecycle |
|------|----------|-----------|
| `bridge-note.md` | `<scribe-dir>/bridge-note.md` | Overwritten each dispatch |
| `journal.md` | `<scribe-dir>/journal.md` | Append-only, archived at 50 entries |
| `journal-archive.md` | `<scribe-dir>/journal-archive.md` | Long-term storage |
| `progress.md` | Project root | Managed jointly (foreground creates, scribe updates) |
