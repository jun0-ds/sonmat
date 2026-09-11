# 2026-09-11 — Approved execution baseline as a separate witness input

## Context

A recurring agentic-coding failure appears after a user approves a plan. During implementation the
agent discovers an older document, test, or behavior that disagrees with the plan, silently rewrites
the plan to match it, and restores behavior the user intended to remove. The discovery may be valid;
the unauthorized resolution is the failure.

The opposite fix is also unsafe. Treating every approved plan as the highest contract would let an
assistant-authored misunderstanding, followed by a brief "go ahead", silently retire standing safety
or product contracts. Approval grants execution authority over the displayed plan. It does not make
the assistant the author of user intent, and it does not amend contracts the plan did not name.

Current witness deliberately accepts raw user turns as intent evidence and rejects a main-authored
plan as user-authored even when the user briefly approves it. That protection prevents intent
laundering and stays in force. It leaves witness unable to detect a different failure: an artifact
that drifts away from the exact plan the user authorized.

## Decision

### 1. Approval creates a limited execution baseline

The exact plan or loop definition shown immediately before an explicit user approval becomes the
execution baseline for that task. Its contract-bearing fields are:

- objective
- modification scope
- constraints
- judgment criteria
- behavior the plan explicitly removes or preserves

Implementation details may change within those boundaries. Changing a contract-bearing field is a
new plan revision and requires the user to see the current baseline, the proposed revision, and the
reason before approving it.

The baseline is not a blanket amendment. A standing contract omitted from the plan remains standing.
When new evidence makes the baseline and a standing contract incompatible, the agent pauses and asks
the user which decision updates or retires the other. A safety or privacy concern pauses execution;
it does not authorize the agent to choose a fallback.

### 2. Witness receives two authority channels, not one merged summary

When an approved baseline exists, witness dispatch adds an optional baseline envelope:

```text
[Approved baseline]
- exact displayed plan or loop definition, unmodified
- raw user turn that explicitly approved that display
```

Witness still receives raw user turns separately. The baseline envelope is limited execution
authority, not user-authored intent. Arbitrary assistant plans, summaries, reasoning, and later
rewrites remain invalid inputs. If either the exact snapshot or its approval turn is missing, witness
does not treat the material as an approved baseline.

This separation preserves two comparisons:

1. raw user intent ↔ artifact
2. approved execution baseline ↔ artifact

It also exposes a third condition rather than hiding it: raw intent and the approved baseline may
themselves be incompatible.

### 3. Add `AUTHORITY_CONFLICT`

Witness returns `AUTHORITY_CONFLICT` when the raw user turns and approved baseline require
incompatible outcomes and no later raw user turn explicitly resolves the difference. When Stage 2
spec verification supplies a published contract, an unresolved baseline ↔ published-contract
conflict uses the same verdict.

`AUTHORITY_CONFLICT` is not PASS, WARN, or BLOCK:

- witness does not decide which authority wins
- main does not refine toward either side
- commit or loop exit pauses
- the user chooses whether to keep the baseline, revise it, or amend the standing contract

If the authorities do not conflict but the artifact departs from the approved baseline, the existing
BLOCK path applies.

### 4. Preserve the honest isolation boundary

The baseline envelope is composed by main today because the harness does not expose an independent
approval-capture channel. Therefore its exactness is a prompt-level contract, not a platform-enforced
guarantee. The spawn prompt must pass the displayed snapshot and approval turn verbatim; it must not
reconstruct either from memory.

Execution-level context separation remains the only structural isolation layer. The new channel does
not strengthen that guarantee and must not be described as doing so. A future harness-level approval
snapshot would remove main from this composition step.

### 5. Scope relative to spec verification

This decision does not enable automatic spec discovery and does not change the Stage 0/1/2 gates in
`2026-04-26-spec-auto-reference.md`. It updates the witness input model defined by
`2026-04-26-witness-spec-extension.md`: an approved baseline may be supplied at any stage because it
comes from the current user interaction, while published specs remain Stage 2-only inputs.

## Consequences

### Positive

- Silent replanning and restoration can be detected even when the user's approval was brief.
- Approval no longer has to be misclassified as authorship to carry execution authority.
- Safety conflicts stop work without granting the agent authority to choose a different product
  decision.
- `AUTHORITY_CONFLICT` keeps disagreement visible instead of rewarding whichever source the model
  happened to read last.

### Negative and limits

- Main still composes the baseline envelope, so plan laundering is reduced by protocol rather than
  eliminated structurally.
- The extra comparison adds prompt length and another verdict path.
- Vague approvals or plans without explicit contract-bearing fields provide only a weak baseline.
- More pauses are possible if plans routinely omit standing contracts they knowingly affect; the
  remedy is to name those amendments in the plan, not to weaken the conflict signal.

## Related

- `2026-04-26-witness-spec-extension.md`
- `2026-04-26-spec-auto-reference.md`
- `2026-04-26-hunsugun-witness-seam.md`
- `2026-08-29-codex-native-adapter.md`
