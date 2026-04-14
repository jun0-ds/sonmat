---
name: punch
description: Punch list — completeness and residue check before delivery. Finds what's missing that should exist (omission) and what's left behind that shouldn't (refactor residue). Reconstructs intent, overlays domain checklist, scans for stale references.
user-invocable: true
---

# Punch — Punch List Before Delivery

Like a construction punch list: walk the finished building and note everything that's missing or incomplete before handoff.

Not "does this work?" (that's guard/inspect) but **"what was supposed to exist that doesn't?"**

Invoke: `/punch` (runs once for the current scope, reports, and exits — not a mode). Manual-only; punch does not auto-activate.

---

## Why this exists

Vibe coding skips the spec. That's a feature, not a bug — but it removes the safety net that specs provided: a shared checklist of "everything that should exist."

Traditional collaboration solves this with requirements docs, design reviews, and QA teams — multiple humans independently checking completeness. In AI-human collaboration, there's no second human. This skill fills that gap.

Research basis: 40-55% of all implementation errors are **omissions** — things that should exist but don't. Another 20-25% are **ambiguity** — things that exist but in the wrong form. Only 10-15% are outright wrong. **The biggest ROI is finding what's missing, not what's broken.**

---

## Method: Reconstruct + Checklist, then Diff

Two complementary lenses:
- **Reconstruct**: derive what should exist from intent and implementation (catches project-specific gaps)
- **Domain checklist**: apply known must-haves for this type of work (catches gaps the user also forgot)

Neither alone is sufficient. Reconstruction misses what nobody thought of. Checklists miss what's unique to this project. Together they cover both.

### Phase short-circuit — residue-only fast path

If punch was invoked as `/punch residue`, or if the trigger was `Structural removal` or `Rename` and the user has not requested reconstruction, **skip Phase 1 and Phase 2 entirely and jump to Phase 3's Residue-free check**. Residue detection is mechanical grep — it does not need intent reconstruction or domain checklists. Running Phase 1 dialogue for pure residue cleanup is overhead that undermines the point of having a fast path for structural changes.

If punch was invoked without a mode and the only session activity was structural removals/renames, suggest the fast path and let the user accept or decline:

```
[punch] Session activity: structural removals only (no new features).
Run residue-only fast path? [Yes / No — I want full reconstruction]
```

### Phase 1 — Reconstruct intent (conversational)

Build a shared understanding of what should exist. Implementation alone can't reveal intent that was never expressed — so this phase is a **dialogue**, not a one-shot analysis.

1. **Read the implementation**: code, config, UI, data flow — form an initial picture.
2. **Draft and present**: Lay out what you understood as a starting point, explicitly marking gaps and uncertainties.

```
[punch] Draft intent — based on implementation:
  User stories: [list]
  Contracts: [list]
  Constraints: [list]
  Uncertain: [things I couldn't infer — need your input]
  What's missing, wrong, or different from what you had in mind?
```

3. **Dialogue**: User corrects, adds, clarifies. This is where the real value is — surfacing what was in the user's head but never made it to code. Each round narrows the gap.
4. **Lock**: When the user confirms, this becomes the reference for Phase 2. Not a formal spec — a shared, good-enough checklist.

**Optional cross-check**: if the feature is high-stakes and there is reason to suspect main may have mis-synthesized the reconstruction (e.g., long conversation, conflicting user turns, user asked "does this match what I said?"), spawn [witness](../../agents/sonmat-witness.md) on the locked reconstruction at **commit-gate scope** (see witness.md §Scope scales). Witness reads raw user turns against the reconstruction and flags any intent that main-synthesized Phase 1 may have quietly dropped. Punch's axis is completeness-by-checklist; witness's axis is fidelity-to-raw-intent — they are orthogonal and can both be wrong in different ways.

### Phase 2 — Domain checklist overlay

After intent is locked, overlay the relevant domain checklist. This catches **what the user also didn't think of** — the "화장실을 까먹은" case.

#### Built-in checklists

| Domain | Key items |
|--------|-----------|
| **Web app** | Auth/session, input validation, error pages, loading states, responsive, accessibility, CORS, rate limiting |
| **API** | Versioning, error format, auth, pagination, timeout, idempotency, documentation |
| **Data pipeline** | Schema validation, null/empty handling, dedup, retry/backoff, monitoring, backfill path |
| **CLI tool** | Help text, exit codes, stdin/stdout, error messages, config file, --dry-run |
| **ML/AI** | Baseline comparison, eval metrics, data leakage, inference latency, fallback on failure |
| **Skill / documentation** | Cross-reference currency (do links still point at existing targets?), terminology consistency (has renamed terminology updated everywhere?), section-to-section alignment (do sibling sections agree on shared definitions?), invocation/example currency (do examples still reflect the current API or flow?), residue from prior edits (see Residue-free check in Phase 3) |

These are starting points. Only apply items relevant to the current project — don't force-fit.

#### Accumulated checklists

Domain checklists grow over time. When punch finds a gap that wasn't on any checklist, propose adding it:

```
[punch] Novel gap found: {description}
  Add to {domain} checklist? [Yes / No]
```

Stored in: `~/.claude/sonmat/memory/punch_{domain}.md`

### Phase 3 — Systematic gap search

For each item in the reconstructed intent + domain checklist, check:

| Check | Question | Error type |
|-------|----------|------------|
| **Exists?** | Is this capability actually implemented? | Omission |
| **Complete?** | Does it handle the full path — happy, sad, edge? | Partial omission |
| **Consistent?** | Does it behave the same across entry points? | Ambiguity |
| **Bounded?** | Are failure modes handled? What happens at limits? | Missing constraint |
| **Connected?** | Do components agree on their shared contracts? | Interface gap |
| **Observable?** | Can the user tell if it worked or failed? | Feedback gap |
| **Residue-free?** | After this session's removals, renames, or restructures, are all references, cross-links, terminology, examples, and dependent documents updated? | Refactor residue |

#### Residue check — what it looks for

Structural changes leave debris. When a section is deleted, a function renamed, a concept retired, the removal itself is usually complete — but **references elsewhere** often survive. These stale references are not "missing features" in the traditional sense; they are **the opposite**: ghosts of removed features still cited in places that weren't updated alongside the removal.

Concrete patterns to scan for during residue check:

1. **Removed section / renamed section**: grep for the old section title, heading anchor, or internal link target across the whole project. Any match outside the removal point is residue.
2. **Removed function / method / class**: grep for the old name. Any caller, import, or docstring reference is residue.
3. **Removed file**: grep for the old path. Any cross-reference, include, or doc link is residue.
4. **Retired terminology**: when a term is deprecated (e.g., "mode" → "reaction", "2-layer" → "witness-pair"), grep for the old term. Any surviving use is residue, *unless* it appears in historical / changelog / archival context that is supposed to preserve the old term.
5. **Orphaned examples**: examples that reference the removed/renamed item. Update or remove.
6. **Severity / category / type tables**: enum-like lists that mentioned the removed item as a valid value. Remove the entry.
7. **Template strings**: report templates, commit message formats, or prompt fragments that embed the old name. Update.

This check is mechanical — it is not reasoning, it is grep. The cost is low and the catch rate on structural changes is high, because human attention after a removal typically stays on the removal point and misses the web of downstream references.

**When to run residue check**: after any session that included a removal, rename, or restructure. See Trigger conditions below.

### Phase 4 — Report

```
[punch] Punch list:

  Clear (N items):
  - [item]: verified by [evidence]

  Gaps (N items):
  - [GAP-1] {category}: {description}
    Expected: {what should exist}
    Actual: {what exists or doesn't}
    Severity: {critical / moderate / minor}
    Source: {reconstruction / domain checklist}
    Suggestion: {what to do}

  Needs input (N items):
  - [item]: {why it's unclear}
```

---

## Gap categories

| Category | Description |
|----------|-------------|
| **Omission** | Feature/path that should exist but doesn't |
| **Partial** | Implemented but incomplete (missing edge cases, error handling) |
| **Ambiguity** | Behavior differs from reasonable user expectation |
| **Interface** | Components disagree on contract (types, formats, assumptions) |
| **Feedback** | User can't tell if action succeeded/failed |
| **Refactor residue** | A removal or rename left behind references to the old state that were not updated. Dead internal links, orphaned examples, stale enum entries, retired terminology that still appears outside archival context |

---

## Invocation modes

Punch is user-invocable and supports several scope aliases. Unlike inspect (which is trigger-reactive and rejects depth dials as anti-discovery-led), punch's modes are **user scope selections**, not depth dials — the user explicitly chooses how much of the punch method to run, based on what kind of check is needed right now. The user knowing they want "just residue" or "just user stories" is the active discovery; the mode just names that discovery.

| Mode | Phases run | Typical use |
|---|---|---|
| `/punch residue` | Phase 3 `Residue-free?` only. Skips Phase 1, Phase 2, and other Phase 3 checks. | After a session of structural removals or renames — the fast path |
| `/punch quick` | Phase 1 (skipped if user declines dialogue) + Phase 3 `Exists?` check on user stories only | Mid-development smoke check — "did I at least wire up the happy path?" |
| `/punch` (default) | Full Phase 1 + Phase 2 + Phase 3 including Residue-free | Feature completion — standard punch list |
| `/punch deep` | Default + edge cases, concurrency, failure modes, all domain checklists regardless of apparent relevance | Pre-release, critical changes, high-stakes |

Residue-free runs in every mode **except** `/punch quick`, because quick's whole point is minimum overhead and residue is only relevant after structural changes (which quick is not the right tool for). When invoked as `/punch residue`, only the Residue-free check runs.

### Why punch has modes when inspect does not

This is worth flagging because the two skills appear to violate each other's principles. Inspect was reframed to forbid "depth dials" because auto-triggered depth passes must be driven by discovery, not by pre-selected depth. Punch keeps modes because:

- Punch is **user-invocable**, not auto-triggered. The user's decision to invoke `/punch quick` *is* a discovery signal ("I know I want a cheap smoke check right now").
- Inspect's triggers (file counts, path patterns) are discovery signals that *precede* the user's awareness; the depth follows the signal. Inspect cannot ask the user "how deep?" because the signal itself is what determines depth.
- Punch's invocation is the signal. The user chose to invoke at a specific mode — that choice is the active discovery, the mode is its name.

The two positions are consistent: depth follows discovery. For inspect, the discovery is a pattern match. For punch, the discovery is the user's intent in typing the command.

---

## When to suggest activation

Don't activate automatically. Suggest once when trigger conditions are met.

### Trigger conditions

| Category | Signal |
|----------|--------|
| **Feature declared done** | User says "done", "finished", "ship it", "that should be it" |
| **Structural change** | Architecture, data model, or flow significantly changed |
| **Structural removal** | Section deleted, function removed, file unlinked, concept retired — residue check strongly recommended |
| **Rename** | Symbol, file, section, or term renamed — residue check strongly recommended |
| **Integration point** | Multiple components wired together for the first time |
| **User uncertainty** | "Am I missing anything?", "What else?", "Is this complete?" |
| **No spec existed** | Feature was built conversationally without prior requirements |

### Suggestion format

```
[sonmat] {what was detected}. /punch?
```

Examples:
- `[sonmat] Feature built without spec, declared done. /punch?`
- `[sonmat] 3 components integrated for the first time. /punch?`
- `[sonmat] Structural change across 5 files. /punch?`
- `[sonmat] Guard §2 / §4 migrated to scribe — residue check recommended. /punch?`
- `[sonmat] Term retired (mode → reaction) — residue check recommended. /punch?`

### Scope

- User accepts -> punch runs for the current feature/change
- After report is delivered -> punch deactivates
- Don't re-suggest for the same scope after user declines

---

## What punch does NOT do

- **Fix bugs** — punch finds gaps, doesn't fix them. User decides priority.
- **Write tests** — punch identifies what to test, not how. Test writing is a separate step.
- **Replace guard/inspect/witness** — guard is main-side verification, inspect is discovery-led depth, witness is intent-artifact match in isolation, punch is completeness against a reconstructed spec. Four different axes; they're complementary.
- **Check user-intent fidelity** — punch's reconstruction is main-synthesized, so it inherits main's interpretation of user intent. When that fidelity itself is in doubt, use witness (which reads raw user turns without main's interpretation layer).
- **Require a spec upfront** — the whole point is reconstructing intent from what exists, not demanding documentation.

---

## Design rationale

guard asks "is this safe?" inspect asks "what could break?" devil asks "is this reasoning sound?" witness asks "does this match what the user asked for?" **punch asks "is anything missing?"**

Like a construction punch list — you walk the finished building with the contractor and note every outlet that's missing, every door that doesn't close, every fixture that was in the plan but not in the building. The building works, but it's not complete.

The reconstruct + checklist method works because: (1) reconstruction surfaces project-specific assumptions through dialogue; (2) domain checklists catch universal must-haves that nobody thought to mention; (3) presenting the reconstruction to the user creates a brief-back checkpoint — the cheapest error-catching mechanism known across aviation, surgery, and military operations.
