---
name: inspect
description: Trigger-reactive discovery-led depth — when a System 1 signal surfaces (blast radius, shared code, infra, auth, migration), pull depth into side-effect, dependency, assumption, and rollback checks. Not a mode; a reaction.
user-invocable: true
---

# Inspect — Discovery-Led Depth

Inspect is **not a mode**. It is a set of checks that fire in response to a specific discovery. The **discovery-led principle**: active discovery pulls depth in, not the other way around — depth is not a dial you turn up before knowing what you are looking at.

When a System 1 signal (see Triggers below) surfaces, inspect pulls System 2 checks scoped to **that specific signal**. One discovery → depth on that discovery → checks resolve → back to default operation. No "inspect on / inspect off" state.

Manual invocation (`/inspect`) is still available when the user wants to force a depth pass without waiting for an auto-detected trigger — but even then, it runs once for the current change and exits.

---

## What inspect does when triggered

### Scope of a single depth pass

| Default operation | Depth pass fires |
|---------|---------|
| Changed files only | Changed files + direct dependents |
| Tests pass? | Tests pass + are tests covering the right cases? |
| Does it work? | Does it work + what could it break? |

The depth scope is bounded by the trigger. A "shared utility edit" trigger pulls depth into its dependents; it does not turn on "inspect mode" for the rest of the session.

### Additional checks (on top of guard)

Four check types. A depth pass does **not** run all four by default — which check fires is determined by the trigger. Running all four regardless of trigger would violate the discovery-led principle (depth chosen without a specific discovery).

1. **Dependency trace**: For each modified function/module, list callers and downstream consumers. Flag any that might behave differently.
2. **Side effect scan**: State changes (DB writes, file writes, env mutations, global state) — are they intended? Are they reversible?
3. **Assumption audit**: What does this code assume about its inputs, environment, or execution order? Are those assumptions documented or tested?
4. **Rollback viability**: If this change goes wrong in production, how do you undo it? Is there a migration, a flag, a revert path?

The trigger → check mapping is in §Triggers below (after trigger conditions are defined). Read the triggers first, then the mapping — the mapping refers to triggers by name.

### Output format

The report makes the discovery → depth chain visible. The trigger is stated at the top (so the reader can see *why* depth was paid), the checks that ran are named, and each finding cites a concrete location.

```
[inspect] {TRIGGER} → checks fired: {list}

Scope:
{1-2 lines on what the depth pass looked at — files, functions, state mutations, etc.}

Findings:
- [{check: dependency trace | side effect | assumption | rollback}] {description}
  Location: {file:line, or command output, or state identifier}
  Impact: {who or what is affected — callers, downstream services, data, etc.}
  Severity: {critical | moderate | informational}
  Suggestion: {what to consider — fix, verify, document, or accept}

Summary: {1 line — "N findings, M critical" or equivalent}
```

When a depth pass finds nothing noteworthy:

```
[inspect] {TRIGGER} → checks fired: {list}

Scope:
{1-2 lines on what was inspected}

Summary: Clean — no side effects, dependency risks, or assumption violations detected.
```

#### Severity definitions

Inspect severities describe *how much attention the finding deserves*, not whether to block. Inspect never blocks commits — blocking is guard's (operational) and witness's (intent) role. Inspect informs the decision to proceed; main / user decides.

| Severity | Meaning | Example |
|---|---|---|
| **critical** | Finding represents a likely failure or data loss if the change ships as-is. | Migration with no rollback path; dependency that will break at runtime. |
| **moderate** | Finding represents an assumption or side effect that is not obviously wrong but is worth verifying before shipping. | Assumption about input format that isn't documented; state mutation that could surprise a caller. |
| **informational** | Finding is a fact worth noting but does not imply a fix. | "This function is now called by 14 other modules — worth knowing for future refactors." |

Citations are mandatory for every finding: `file:line`, a command output line, or a named state identifier. A finding without a concrete location is speculation; discard it or downgrade to an informational note with no citation claim.

---

## What inspect is not

- **Not a persistent mode**. No on/off state. Each depth pass is bounded to a single triggering discovery.
- **Not a depth dial**. "Go deep" is never a standalone decision — it is always the consequence of a specific discovery. If no discovery, no depth pass.
- **Not a slowdown on trivial work**. A one-line fix with no triggering signal runs at default speed. Triggers gate the cost.

### Boundary with other sonmat skills

Inspect shares the verification layer with guard, witness, and punch — each on a different axis. Clean boundaries matter because depth passes that drift across axes dilute the focus that makes discovery-led depth useful in the first place.

| Skill | Axis | Question | Inspect overlap |
|---|---|---|---|
| **guard** | Main-side verification | "Are tests passing? Sensitive files safe? Discipline followed?" | guard always runs; inspect adds depth when a signal warrants wider reach. guard is *always-on verification*, inspect is *triggered depth*. |
| **witness** | Intent-artifact match | "Does the artifact match what the user asked for?" | None — witness asks whether user intent was fulfilled, inspect asks what the change might break. Same diff, different axes. |
| **punch** | Completeness | "Is anything *missing* that should exist?" | None — inspect finds what *could break*, punch finds what *was never built*. Opposite directions. |
| **scribe** | Post-work persistence | "Is anything worth keeping from what we found?" | Inspect reports findings to main; if a finding turns out to be novel (not covered by existing hints), main dispatches to scribe (via guard's novel-trap path). Inspect does not dispatch to scribe directly — novel judgment belongs to guard's hint-comparison step, not to inspect. |

Inspect is **not a replacement for guard, witness, or punch**. A depth pass on the wrong axis catches the wrong class of problem.

---

## Triggers — the discovery signals

Inspect fires when a trigger is detected. Triggers are System 1 pattern signals, cheap to evaluate. When one fires, suggest the depth pass once per discovery; if the user accepts (or if the trigger is auto-fire class), the depth pass runs once and exits.

| Category | Condition |
|----------|-----------|
| **Blast radius** | Change spans 5+ files, or modifies a file imported by 3+ others |
| **Shared code** | Editing shared utilities, base classes, config generators, or sync scripts |
| **Infrastructure** | Touching DB schemas, env vars across services, Milvus/Redis contracts, cron schedules |
| **Auth/Security** | Modifying authentication, API keys, permissions, or credential paths |
| **Data migration** | INSERT/UPDATE/DELETE on production data, schema changes, index rebuilds |
| **Cross-service** | Change requires coordinated deployment to multiple servers/services |
| **User signal** | User says "risky", "careful", "worried", "double-check" |

### Trigger → Check mapping

Each trigger pulls specific checks. This mapping is the discovery-led principle made concrete — the discovery (trigger) determines the depth (which checks fire).

| Trigger | Primary check | Secondary check | Why this mapping |
|---|---|---|---|
| **Blast radius** | Dependency trace | Assumption audit | The risk is downstream behavior divergence; depth goes to callers and the assumptions they relied on. |
| **Shared code** | Dependency trace | Assumption audit | Same pattern as blast radius, but scoped to the shared component's consumers. |
| **Infrastructure** | Side effect scan | Rollback viability | Infra changes are state mutations with hard-to-reverse failure modes; depth goes to what changes in state and how to undo it. |
| **Auth / Security** | Assumption audit | Side effect scan | Security bugs live in unstated assumptions (who can call this, what's trusted); depth goes to the assumption layer first. |
| **Data migration** | Rollback viability | Side effect scan | Data loss is irreversible; rollback viability is the first question. |
| **Cross-service** | Dependency trace | Rollback viability | Multi-service failures propagate; depth goes to where a partial deploy lands. |
| **User signal** | All four | — | The user has flagged a general concern without pattern, so all four checks fire. This is the manual override. |

If a trigger fires that is not in this table (a new one added later), default to "all four" for safety until a specific mapping is established.

### Suggestion format

One line, no preamble:

```
[sonmat] {what was detected}. /inspect 할까요?
```

Examples:
- `[sonmat] 6개 서비스 filter_env 동시 수정. /inspect 할까요?`
- `[sonmat] prod DB 스키마 변경 감지. /inspect 할까요?`
- `[sonmat] sync-env.sh + 4개 .env 배포. /inspect 할까요?`

The wording avoids "켤까요" (turn on) because inspect is not a switch. Each suggestion is a depth-pass offer, not a mode toggle.

### Depth pass scope

- Trigger fires + user accepts → depth pass runs once for the current change
- Depth pass completes → inspect is done. No "on" state to turn off.
- Don't re-suggest for the same change after user declines. A *new* discovery with a *new* trigger is a new depth pass.

---

## Design rationale

**Discovery-led principle**: active discovery pulls depth in. The five verification traditions (surgery checklists, aviation CRM, mindfulness noting, chess blunder checks, pre-mortem) all agree — depth follows a discovery mechanism, it does not precede one. Depth chosen before discovery is false confidence dressed up as thoroughness; it consumes attention without improving outcomes.

Earlier versions of inspect treated depth as a user-flipped dial ("turn on inspect mode"). That framing reversed the order: the user decided to go deep *before* any signal had surfaced, and then the deep checks ran on a target that might or might not have deserved them. The current framing keeps the same check set but ties activation to specific triggering signals — the cost of depth is only paid when a discovery justifies it.

Triggers are intentionally System 1 patterns (file counts, path matches, keyword signals). They are not themselves deep reasoning — they are cheap pattern-match hooks that let deeper reasoning fire *where it matters*. Automatic suggestion lowers the chance of missing risky changes; user acceptance preserves agency over when to pay the cost.

Manual `/inspect` invocation remains available as an override for cases where the user has noticed a signal the automatic triggers did not — but it still runs as a bounded depth pass, not a mode.
