# Deferred tracks

Work left over from the 2026-04-15 witness session. Pick up later when relevant.

---

## Track 3 remaining — additional assumption audits

Session did three rounds of devil CCT and flipped three assumptions (see `docs/posts/2026-04-15-witness-v0.9.md`). Two more candidates identified but not yet audited:

### #3 — "punch residue check is mechanical grep, not reasoning"

Claim in `skills/punch/SKILL.md` §Phase 3 Residue-free check:

> "This check is mechanical — it is not reasoning, it is grep."

Suspect: detecting "retired terminology" or "orphaned examples" still requires knowing *which* terminology was retired and *what counts as archival context*. That knowledge is session-state interpretation, not pure grep. The claim may be overstated.

Audit approach when picked up: apply devil CCT to this specific claim. Load-bearing question is probably whether the "knowing what was retired" step is itself mechanical (e.g., derivable from git diff of the same session) or requires reasoning.

### #4 — "discovery-led principle actually converges with the five verification traditions"

Claim in `memory/domain/discipline_forced_protocols.md` §Cascade 해석 (165-182):

> "The five verification traditions (chess CCT, surgical Time Out, aviation CRM, mindfulness noting, pre-mortem) all map to active discovery → depth cascade."

Suspect: this may be an analogy error. The five traditions are human-organizational checklist protocols; LLM reasoning passes are a different domain. The structural isomorphism may be something we projected onto the evidence rather than something the evidence supports.

Audit approach when picked up: for each of the five traditions, check whether the original literature describes it with a "discovery → depth" structure, or whether that framing is our retrospective imposition. This is a literature audit, not a devil round.

---

## Runtime monitoring (continuous)

### Witness behavior validation

Witness's comparator discipline is prompt-level, not runtime-enforced (see `agents/sonmat-witness.md` §Isolation stack, layers 2-3 are aspirational). Early uses need human sampling to validate:

- Does witness actually produce citations from valid sources only?
- Does it follow source-based verdict rules (§1/§2/§4 → BLOCK, §3 → WARN)?
- Does it drift into strength judgment, producing WARN because something "feels" weak?
- Does it respect the "suspect first" default posture?

Data source: `journal.md` witness event log. Scribe captures witness verdicts exactly for this purpose.

Feedback loop: if drift is observed, the fix lives in `agents/sonmat-witness.md` agent file. Adjust the prompt, not the code around it.

### Autoloop [Judge] pipeline observance

Main's adherence to the three-gate keep pipeline (self-review → guard → witness → commit) is discipline-enforced, not hook-enforced. Watch for:

- Does main actually spawn witness at [Judge] keep pipeline, or does it skip when pressed for time?
- Does main override witness BLOCK verdicts "because it seemed wrong"?
- Does `loop.yaml` `witness.commit: skip` get used only for its intended use cases (subjective domains), or does it creep into use as a default bypass?

Feedback loop: autoloop memory / retrospective should surface patterns. If bypass becomes common, the problem is either (a) witness is producing false positives that justify bypass, or (b) discipline enforcement is too weak and the design needs a structural backup.

---

## Feature request track

`docs/feature-requests/claude-code-isolation.md` lists four Claude Code platform capabilities that would strengthen sonmat-witness. None are blockers; all are improvements. When/if Anthropic expresses interest in platform feedback on isolation primitives, this is the document to submit.

Summary of the four:

1. **Harness-enforced input channel restriction** for subagents (declare allowed/forbidden input channels, platform rejects prompts that include forbidden channels)
2. **Nested subagent delegation** (one additional level — orchestrator → workers, session layer → orchestrator)
3. **Session-level intent extraction layer** (UserPromptSubmit-hook-style primitive that can fork user turns into multiple downstream channels, one being a long-lived subagent)
4. ~~PreToolUse → agent hook → synchronous deny documentation~~ (retracted 2026-04-15, not actually needed — Task tool path works for autoloop integration)

---

## Hook integration — actually unused

`hooks/hooks.json` currently only has a SessionStart command hook. Witness integration is entirely at the autoloop skill layer (Task tool spawn from [Judge]). No PreToolUse hook configuration exists.

If a future use case requires ad-hoc tool-call gating outside autoloop (e.g., a user running tools manually and wanting witness on risky commits), the cleanest path is a dedicated skill wrapper like `/commit-verified` that spawns witness before the risky operation. Do not try to force this into PreToolUse hooks — that path is undocumented and fragile (see v0.9.0 release notes).

---

## Other outstanding items

- `loop.yaml` template files: currently only exist as documentation examples inside `skills/autoloop/SKILL.md` §3. No standalone template files in `templates/` or similar. Users copying the examples from docs is the current workflow.
- dev.to + velog posts: `docs/posts/2026-04-15-witness-v0.9.md` exists in Korean. English version for dev.to and final velog adaptation are deferred to the branding track (see `~/.claude/memory/domain/branding_plan.md`).
- `.claude-plugin/marketplace.json`: currently points at `./` as source. If the marketplace structure changes in the future (e.g., separate sonmat from other plugins), revisit this field.

---

## Reward-loop framing — self-referential verification ceiling (2026-05-22)

From a control-tower reasoning session. Background + full argument: `~/.claude/memory/domain/reward_loop_external_oracle.md` (global memory). This track is a *frame* that several existing items above turn out to be instances of, plus concrete edit candidates. Handed off here for a future sonmat work session.

### Core claim

> The currency of reward is the *derivative* of prediction improvement, and for an LLM that loop never closes at inference time — so self-referential scaffolds (devil / punch / witness) hit a ceiling and only become reliable when an **external oracle** is present. Code work has a built-in oracle (compiler / tests / types); planning/spec work does not, and needs a human or a *separate* model as oracle.

Same conclusion as `discipline_forced_protocols.md` ("the second locus must be isolated from the first's rationalization") and Huang et al. 2023 ("LLMs Cannot Self-Correct Reasoning Yet"), pushed one layer down: *why* (no closed reward loop) and *how far* (only with an objective oracle).

### Existing items this reframes

- **#3 (punch = mechanical grep?)**: punch's "did I miss anything?" is self-referential — a blind spot is by definition invisible to self-check. The grep claim being overstated is a *symptom* of this ceiling, not a separate bug.
- **#4 (discovery ↔ 5 traditions)**: the five traditions all externalize the locus; that is their load-bearing common feature, which this frame names directly.
- **Witness validation ("feels weak" drift; journal as data)**: using `journal.md` (self-report) to validate witness is itself a self-report-as-ground trap. Witness validation needs an external ground, not journal alone.
- **Autoloop [Judge] (main overrides BLOCK "because it seemed wrong")**: override-by-feeling is the self-reference ceiling acting at the orchestration layer.

### Edit candidates (the actual work, when picked up)

- `discipline/core.md` "Cross it" / "Ground it": state explicitly that a self-pass (devil) is *not* an oracle; route through a model-external oracle (tests / another model / human) when one exists.
- `discipline/hints.md`: add a hint keyed on task type — code has a built-in oracle, planning/spec does not.
- `skills/punch`, `agents/sonmat-witness.md`: completeness and intent-artifact judgments must not be grounded in self-report (journal); require external ground where available.
- `skills/scribe`: when journal records "verified", force naming *what* served as oracle (test / human / other model / none) — prevents the self-report-as-quality trap.
- Worker dispatch / orchestration: window curation (load-bearing info at front/end, not the middle — "lost in the middle"), adaptive per-task reasoning length, and a "scaffold-execution-record ≠ quality-evidence" reminder.

### Relation to existing spec/verification machinery (raised 2026-05-22)

Is "oracle" a new component, or does it merge with what already exists? Working hypothesis: **oracle is not a new component — it is an axis cutting across the existing verification machinery.**

- **spec** (`docs/specs/`, RFC 2119): provides the *criterion half* of an oracle (intent externalized to a doc). A criterion alone is not an oracle — if the model judges its own spec-conformance, that is still self-check (the ceiling). spec becomes an oracle only when conformance is *judged externally*. Degree of merge ∝ spec's checkability: a machine-checkable spec (types, contracts, test cases) *is* an oracle; a natural-language spec ("good UX", a SHOULD a human must read) gives only the criterion and leaves judgment outside. To promote spec → oracle, wire each MUST to *how* it gets judged (test / human / other model).
- **guard**: already partly an oracle (runs tests = external verdict).
- **witness**: an oracle only if grounded in external state, not in journal (self-report). Cf. #Witness validation above.
- **punch**: no oracle (self-referential completeness check).

So: do NOT add a standalone "oracle" component (duplication). Instead re-map existing components along an "oracle present? built-in / external / none" axis.

Broader structural review: check whether munteok's components are well-factored — not "must be independent", but look for (a) duplication across things split apart, (b) over-coupling within one thing. Right granularity is found by working, not decided up front. Cf. `deep_module_design.md` (Ousterhout). Same "right-size" question as window/CoT length, applied to module boundaries.

**Category note** — core / spec / witness / oracle are not parallel layers; they are different *categories*:

- **Component** (entity): core, witness, guard — actual code/prompt. Within components there *is* a vertical layer: core (orchestration / meta-gate) sits above witness·guard·punch (specific verification tasks).
- **Artifact** (input): spec — a document carrying the criterion.
- **Role / empty slot**: oracle — the judging function itself, *filled by* a component (witness with external ground, guard running tests), an artifact (machine-checkable spec), or an external party (human).

So oracle is not a peer of the others — it is the slot they fill; comparing them side by side is a category mix. And the judgment splits two layers: core does the **meta-judgment** ("did it pass an oracle?") and must *not* be the oracle itself (same-model self-judgment = the ceiling); the **first-order judgment** ("does the artifact meet the spec?") is domain-specific (tests for code, a human for planning). Why spec ≠ enough: a clear spec still needs an external judge, because the failure isn't distrust of the spec (A) but distrust of the model's self-conformance-judgment (B) — a blind spot survives self-check. Merge degree ∝ spec checkability (machine-checkable spec collapses criterion+judge into one).

### Decided vs open

- **Decided**: do *not* inject "encouragement" (lowers verification, feeds sycophancy). "Progress sense" → implement as explicit state tracking, not as an emotion. Do *not* add a standalone oracle component — oracle is an axis, not a box.
- **Open**: (a) how to *enforce* external-oracle routing in prompt/code; (b) how spec-conformance judgment gets wired to an actual judge; (c) the component re-mapping along the oracle axis — these are the design questions for the work session.

### Evidence note

Diagnosed by contrasting a planning-heavy track (no built-in oracle, more human-QA defects) with an implementation track (built-in oracle: tests/types). Caveat: confounded — the planning track was an immature new effort, so defect count alone is not proof; the structural argument stands on its own. A self-report trap actually occurred during this very diagnosis (treating a journal's "devil 2 rounds / browser-verified" record as quality evidence), which is itself a data point for the claim.
