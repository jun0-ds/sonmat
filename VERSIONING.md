# Versioning

sonmat follows [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`.

## What each number means

| | When to bump | Example |
|---|---|---|
| **MAJOR** | Breaking changes — discipline structure, skill interface, or hook contract changes that require users to update their setup | `1.0.0` → `2.0.0` |
| **MINOR** | New features — new skills, new domain hints, multi-CLI support, new capabilities that don't break existing setups | `0.2.1` → `0.3.0` |
| **PATCH** | Fixes — typos, wording improvements, bug fixes in hooks/scripts | `0.3.0` → `0.3.1` |

## How to release

1. Update version in both files:
   - `.claude-plugin/plugin.json` → `"version": "X.Y.Z"`
   - `.claude-plugin/marketplace.json` → `"version": "X.Y.Z"` (appears twice)

2. Commit:
   ```bash
   git add -A
   git commit -m "release: vX.Y.Z — (one-line summary)"
   ```

3. Tag:
   ```bash
   git tag vX.Y.Z
   git push origin main --tags
   ```

## Version history

| Version | Date | Summary |
|---------|------|---------|
| `0.13.0` | 2026-04-26 | Tier 2 implementation entry — three ADRs (T2-A project-spec-structure / T2-B spec-auto-reference / T2-C spec-evolution-loop) move from documentation to working artifacts. New `templates/spec-template.md` and `templates/spec-index-template.md` give projects copy-and-fill scaffolds for `docs/specs/` per CSI Three-Part Format + ISO 19650 lifecycle metadata. scribe SKILL.md extended with spec amendment ritual: when novel-trap dispatch carries `flavor: spec_gap` AND project has `docs/specs/_index.md` declaring `sonmat.spec_awareness: enabled`, scribe proposes successor-spec generation (Yes / No log only / Edit first), with closure-ceremony auto-trigger and LEARN journal entry per LPS 5-conversation model. hints.md Spec consumption sub-section adds Stage 1 awareness behaviors: auto-read `_index.md` at task start, inline-reference relevant specs, alerts-only no blocking, draft-status treated as non-binding, verify against spec body not just index. All Stage 1 behaviors gated on opt-in flag; default (Stage 0) keeps v0.12.0 behavior unchanged. |
| `0.12.0` | 2026-04-26 | Spec authoring discipline added to hints.md Dev domain — feeding from Phase 3 architecture-methodology research wave (5 cases: Ancient/Medieval, Renaissance/Modernism, BIM+CSI, Lean+IPD, Practitioner gap rituals). Six new spec-authoring hints: modal calibration (RFC 2119 self-limiting), intent vs mechanism (Auftragstaktik Was/Warum not Wie), record rejected alternatives (Brooks ledger of refusal / Talmud minority opinion), closure ceremony on retirement (PEP 404), amend via successor not in-place edit (RFC Updates/Obsoletes), spec ambiguity → numbered question with fishing-RFI self-check (AIA G716 model). Refined via devil project-relevance gate — Tier 1 only; Tier 2 (auto-reference / spec evolution loop) deferred to ADRs after substrate baseline measurement. |
| `0.11.0` | 2026-04-26 | Discipline + skill behavioral changes feeding from spec-induction Phase 1+2 research wave. core.md: Conceptzia audit (Before #4), spec-gap AAR (After #4), self-critique of antibodies (Learn). hints.md: Korean ↔ English negation asymmetry domain section. devil: §2.5 project-relevance gate (Stakes / Amendment cost / Next-action delta) with off-project honest exit, eliminates reactive-contradiction failure mode. scribe: bridge-note authoring principles (status-form / Traps mandatory / hypothesis / brevity), Novel Trap dual flavor (verification_failure + spec_gap). |
| `0.10.1` | 2026-04-21 | Add hint for `Agent({isolation: "worktree"})` usage — parallel features, long-running refactors, and reversible-risk experiments should dispatch into worktree isolation. No new skill; leans on Claude Code's built-in `isolation` parameter rather than duplicating the functionality inside sonmat. |
| `0.10.0` | 2026-04-16 | Add grounding-during-exploration rules to core discipline (`While Exploring` — name hypotheses, mark position). Clarify devil balance-table wording. |
| `0.9.1` | 2026-04-15 | Honest framing pass on witness isolation stack. Separate layer 1 (platform-enforced execution isolation) from layers 2-3 (aspirational prompt-level contracts). Add honest caveats to witness.md §Role and §Isolation stack clarifying that the agent file is a prompt, not a compiled program, and that comparator discipline needs human-sampled validation in early use. Autoloop adds a reliability note to the [Judge] pipeline pointing at scribe's witness event log as the drift-detection channel. |
| `0.9.0` | 2026-04-15 | Add `sonmat-witness` agent — protocol-isolated intent-artifact comparator with three scope scales (commit / session forest / principle coverage). Split guard/scribe — scribe becomes post-work persistence layer, absorbs project rule discovery and novel trap recording. Reframe inspect and devil around discovery-led depth (cascade principle retracted as ambiguous). Add refactor-residue check to punch. Retract "3-layer architecture" aspiration as unsupported by current Claude Code platform; document honest 2-layer witness-pair architecture with isolation stack. Replace PreToolUse hook integration path with Task-tool spawn from autoloop [Judge] phase. |
| `0.8.0` | 2026-04-11 | Add `/punch` skill (completeness check), context doubt principle in core discipline |
| `0.7.1` | 2026-04-10 | Fix devil balance table column labels — Strength→Counter strength, Verdict→Claim verdict |
| `0.7.0` | 2026-04-06 | Add Rhythm Rules (Pace/Weight/Learn) to core discipline. Rename `/imp` → `/devil`. Add Reduce hint to Dev domain. |
| `0.6.1` | 2026-04-03 | Fix skill discovery — flatten skills/ directory, rename loop → autoloop (built-in collision) |
| `0.6.0` | 2026-04-02 | Add `/imp` skill — devil's advocate for reasoning. Counter-arguments against interpretations and irreversible decisions |
| `0.4.0` | 2026-04-01 | Prompt-first architecture — hook additionalContext → 0, discipline via CLAUDE.md → core.md reference chain |
| `0.3.2` | 2026-04-01 | Inspect suggestion system — concrete trigger conditions, task-scoped activation, auto-off |
| `0.3.1` | 2026-04-01 | Add `/inspect` skill (deep inspection mode), prompt-first architecture principle |
| `0.3.0` | 2026-04-01 | Multi-CLI support (Codex/Gemini), sonmat as single directory, embed discipline in instruction files |
| `0.2.1` | 2026-03-31 | Restructured discipline (thinking rules + action rules), polyglot hook, nickname system |
| `0.1.0` | 2026-03-29 | Initial release — core discipline, guard/autoloop/plan skills, worker agent |
