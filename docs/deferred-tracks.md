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
