---
name: punch
description: Punch list — completeness check before delivery. Reconstructs intent, overlays domain checklist, finds what's missing.
user-invocable: true
---

# Punch — Punch List Before Delivery

Like a construction punch list: walk the finished building and note everything that's missing or incomplete before handoff.

Not "does this work?" (that's guard/inspect) but **"what was supposed to exist that doesn't?"**

Activate: `/punch`
Deactivate: `/punch off` or session end.

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

---

## Depth levels

| Depth | Scope | When to use |
|-------|-------|-------------|
| `/punch quick` | User stories only — "can the user do X?" | Mid-development check |
| `/punch` (default) | User stories + contracts + domain checklist | Feature completion |
| `/punch deep` | Full reconstruction + all checklists + edge cases, concurrency, failure modes | Pre-release, critical changes |

---

## When to suggest activation

Don't activate automatically. Suggest once when trigger conditions are met.

### Trigger conditions

| Category | Signal |
|----------|--------|
| **Feature declared done** | User says "done", "finished", "ship it", "that should be it" |
| **Structural change** | Architecture, data model, or flow significantly changed |
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

### Scope

- User accepts -> punch runs for the current feature/change
- After report is delivered -> punch deactivates
- Don't re-suggest for the same scope after user declines

---

## What punch does NOT do

- **Fix bugs** — punch finds gaps, doesn't fix them. User decides priority.
- **Write tests** — punch identifies what to test, not how. Test writing is a separate step.
- **Replace guard/inspect** — guard checks discipline, inspect checks side effects, punch checks completeness. They're complementary.
- **Require a spec upfront** — the whole point is reconstructing intent from what exists, not demanding documentation.

---

## Design rationale

guard asks "is this safe?" inspect asks "what could break?" devil asks "is this reasoning sound?" **punch asks "is anything missing?"**

Like a construction punch list — you walk the finished building with the contractor and note every outlet that's missing, every door that doesn't close, every fixture that was in the plan but not in the building. The building works, but it's not complete.

The reconstruct + checklist method works because: (1) reconstruction surfaces project-specific assumptions through dialogue; (2) domain checklists catch universal must-haves that nobody thought to mention; (3) presenting the reconstruction to the user creates a brief-back checkpoint — the cheapest error-catching mechanism known across aviation, surgery, and military operations.
