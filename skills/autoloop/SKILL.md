---
name: autoloop
description: 범용 자율 루프 — 기획→정의→실행→평가→판단→기록→반복. 에스컬레이션 판단 포함.
user-invocable: true
---

# Autoloop — Autonomous Loop Protocol

## 0. Entry Routing

On receiving a task, judge complexity:

| Signal | L0 (direct) | Full loop |
|--------|-------------|-----------|
| Files to modify | 1 | Multiple |
| Iteration needed | One-shot | Expected |

**L0**: Skip planning questions and definition. Apply core.md + hints.md → execute → verify → done. Escalate to full loop if a trigger fires.

**Full loop**: Proceed to section 1.

**Bridge-note check**: Before starting any task, check if the sonmat bridge note exists (`bridge-note.md` in `$SONMAT_PROJECTS_BASE/<slug>`, default `~/.sonmat/projects/<slug>/` where `<slug>` is the cwd path with `/`→`-`; legacy `.claude/sonmat/` as fallback). If relevant context is found, incorporate it silently. Mention to user only if directly relevant to the new task.


## 1. Planning Questions

When no loop definition exists, build one through conversation. Ask 2-3 at a time, not all at once.

### Required Questions

| # | Question | Collects |
|---|----------|----------|
| 1 | What is the end goal? | `loop.name` + objective |
| 2 | Which files/scope to modify? | `loop.modify` |
| 3 | How to run after modification? | `loop.run` |
| 4 | How to evaluate results? | `loop.evaluate` |
| 5 | Keep/discard/refine criteria? | `loop.judge` |
| 6 | Constraints? (off-limits files, time, preservation zones) | `loop.constraints` |
| 7 | When to stop? | `loop.exit` |

### Skip rules
- Already answered in task description → fill without asking.
- Clearly inferable from context → fill without asking.
- At minimum, secure `modify`, `run`, `evaluate`.

### Confirmation
Show the loop definition YAML and get user approval before starting.
For L0 tasks: one-line summary suffices — "Proceeding like this: [summary]. Object if not."


## 2. Loop Protocol

```
[Plan] → [Define] → [Execute] → [Evaluate] → [Judge] → [Record] → [Repeat/Exit]
```

### [Plan]
- No definition → run section 1 questions.
- Has definition → proceed to [Define].
- Milestone-scale planning → escalate to L3 (see below).

**Brainstorming** (for non-trivial planning):
Don't adopt the first approach that comes to mind. Dispatch a worker (§6a) with a brainstorming prompt: generate N variations on different constraints / priorities / trade-offs, return as a list without committing to any. Main then cross-compares the variations and presents options to the user. This is a `L2` worker spawn at the [Plan] phase, not at [Execute]. The worker's output goes back to main for user presentation, not directly to [Define].

**Milestone planning** (absorbed from plan skill):
When user requests "create roadmap", "restructure milestones", or other structural changes to `progress.md`, escalate to L3. Planning questions:
1. What is the end goal?
2. Any deadlines?
3. How large should milestones be?
4. Anything that needs to start immediately?

Draft `progress.md` from answers, present for user review. Use 3-tier structure: Milestone > Phase > Task with `[x]`/`[ ]` checkboxes. Scribe handles checkbox updates after this point.

### [Define]
- Finalize loop definition YAML for this iteration.
- Decide specifically what to modify this round.
- First iteration: establish baseline (current test results, current metrics).

### [Execute]
- Check git tracking before modifying files.
  - Tracked: restore via `git restore` on discard.
  - Untracked: keep original in memory for discard recovery.
- Modify only within `loop.modify` scope.
- Check `loop.constraints` before modifying.
- Run `loop.run` command. Collect output.

### [Evaluate]
- Measure results against `loop.evaluate` criteria.
- Compare with previous iteration (or baseline if first).
- Present evaluation with numbers and rationale.

### [Judge] — 3-way decision

| Judgment | Condition | Git action |
|----------|-----------|------------|
| **keep** | `loop.judge.keep` met | Self-review → guard (operational) → witness (intent-match) → commit |
| **discard** | `loop.judge.discard` met | `git restore` (revert) |
| **refine** | Partial improvement | Keep good parts, fix bad parts, re-execute |

**keep pipeline** — three gates in order. Each can downgrade the judgment, but they are **not** three equally-strong layers; they are a cheap-first ordering with honest labeling of what each gate actually provides.

1. **Self-review** (main, System 1) — quick re-read of the diff by the same agent that wrote it. This is **not structural isolation** — it is the remnant discipline layer that the sonmat architecture admits cannot be eliminated (cf. `memory/domain/discipline_forced_protocols.md` §Core Tension). Its role is to catch obvious slips cheaply before spending on subagent spawns. Treat it as a noise filter, not as verification. If the loop ever relies on self-review as the *only* gate, the architecture is broken.
2. **Guard** (main, verification checks) — pre-commit test execution, sensitive-file blocking, discipline conformance, novel-trap detection. Runs in-context. Still main-side but oriented around structural rules (file patterns, test results) rather than self-interpretation of intent. See `skills/guard/SKILL.md`.
3. **Witness** (spawned subagent, protocol-isolated) — intent-artifact match. Spawned with user-turn cascade as the only input. Main's chain-of-thought is excluded at the spawn-prompt layer (discipline) and at the execution-context layer (harness-enforced); see `agents/sonmat-witness.md` §Isolation stack for the honest breakdown of what that means on current Claude Code. Whether to spawn witness for a given commit is a structural decision set in `loop.yaml` (`witness.commit: required | optional | skip`) — never a main runtime judgment call. If the loop definition is silent, default to `required`.

Any gate returning a blocking verdict (guard block / witness `BLOCK`) → judgment becomes **refine**, not keep. Non-blocking findings (guard warning / witness `WARN`) → surface to user but proceed if user confirms.

Note on witness verdict reliability: witness's comparator discipline (citing from valid sources only, source-based verdict determination, refusing strength judgment) is **prompt-level**, not runtime-enforced — see `agents/sonmat-witness.md` §Isolation stack for the honest breakdown. Early uses of witness should be sampled by a human reviewer to validate that its verdicts actually follow the specified rules. If drift is observed (e.g., verdicts without citations, strength-based WARN assignments), the agent file needs adjustment — the journal is the right place to log these events (scribe captures witness verdicts for exactly this purpose).

The three-gate order is deliberate: cheap checks first, structurally-isolated check last (because it costs a spawn). Witness is the final gate because its isolation is most valuable on content that a cheaper gate would not have caught anyway. **The three gates are complementary layers of a Swiss cheese model — not redundant, not interchangeable, and definitely not substitutable. Self-review alone is the thinnest possible layer; guard + witness together is the minimum honest stack.**

**Preservation zones** (subjective domains like writing): If refine/discard reveals "the previous version was better" for certain parts, add those to `loop.constraints`. Update zones each iteration with user confirmation.

**Escalation check**: At every judgment, self-check FOR (Feeling of Rightness) against the 4 triggers (section 5). If any trigger fires → escalate.

### [Record]
- keep: commit message includes iteration # and metric change.
- discard: record why (prevent same mistake next iteration).
- refine: record what to keep and what to fix.

### [Repeat/Exit]
- `loop.exit` met → end loop, produce final report.
- Not met → return to [Define].
- On exit: total iterations, metric trajectory, final state.
- **Loop Artifact**: If context should carry to a follow-up loop, record: output paths, key results, constraints for next loop.

**Forest-scale witness check** (on exit, before scribe):

Before dispatching scribe, spawn witness at **session forest scope** if any of these conditions hold:

| Condition | Witness scope |
|---|---|
| Session touched 3+ distinct files | `session-forest` |
| Any user turn in the session contains a scope-broadening phrase ("전체", "모든", "시스템 전반", "일관되게", "across all", etc.) | `principle-coverage` |
| `loop.yaml` declares `witness.forest: required` | As declared |

Forest-scale witness receives (a) the full session's user-turn cascade and (b) the session's accumulated `git diff`. Its findings route as follows:

- `PASS` or `WARN` → continue to scribe dispatch. WARN surfaces to user verbatim; user can override.
- `BLOCK` → do not dispatch scribe yet. Report BLOCK findings to user. Loop exit is paused; user decides to fix (return to [Execute]) or override (proceed with acknowledged mismatch).
- `INSUFFICIENT_GROUND_TRUTH` → report to user, proceed to scribe dispatch.

This is the structural equivalent of the "forest review" that main alone cannot reliably perform at session end — a comparator running with user-turn isolation catches the multi-file partial application / dead-reference class of misses that main's chain-of-thought would rubber-stamp. See `agents/sonmat-witness.md` §Scope scales for the full definition.

**Scribe dispatch** (on exit, after forest witness):
- **keep**: Dispatch scribe with mode `all` (bridge + journal + progress). Include loop report, git diff, and forest-witness verdict as artifacts.
- **discard**: Dispatch scribe with mode `journal` only. Record what was tried and why it failed.
- Scribe runs in background. Do NOT wait for it. Proceed with user interaction immediately.

### Retrospective (after 3+ iterations)
- Was the approach order optimal?
- Where did intent diverge from result?
- What untried approach might have been better?
- Include 1-2 line summary in loop report.

### Memory update (on loop exit)
After retrospective, check: did this loop reveal a lesson not already in sonmat memory?
- If yes → dispatch to scribe as a novel-trap-like payload (pattern, context, catch-signal). Scribe handles the abstraction, user confirmation, and memory write. See `skills/scribe/SKILL.md` §Novel Trap Recording.
- If multiple project lessons have accumulated, check if any should be promoted to universal memory (inductive review) — this is also scribe's dispatch.


## 3. Loop Definition Templates

### Dev loop
```yaml
loop:
  name: "Feature / bug fix"
  modify: "src/ relevant files"
  run: "uv run pytest tests/ -v"
  evaluate:
    metrics: ["test_pass_rate"]
  judge:
    keep: "All tests pass"
    discard: "Existing tests broken"
    refine: "New tests pass, some existing fail"
  witness:
    commit: required    # per-iteration commit gate
    forest: required    # loop-exit forest check
  exit: "All tests pass + self-review done"
```

### Writing loop
```yaml
loop:
  name: "Editing pass"
  modify: "target document"
  run: "One editing pass — show diff"
  evaluate:
    criteria: ["consistency", "flow", "conciseness"]
    require_user_confirmation: true
  judge:
    keep: "Improved over previous"
    discard: "Worse — original was better"
    refine: "Partly improved, partly over-edited"
  witness:
    commit: optional    # subjective domain — witness is advisory
    forest: required    # still worth checking at exit
  exit: "Fewer than 5 changes in a pass"
```

`require_user_confirmation: true` — for domains where automated judgment isn't reliable (writing, design). Must show changes and get approval before keep/discard.

### `witness` field reference

Every loop definition should specify witness scopes. If omitted, `commit: required` and `forest: required` are the defaults.

| Field | Values | Meaning |
|---|---|---|
| `witness.commit` | `required` \| `optional` \| `skip` | Whether the commit-gate witness runs in `[Judge]` keep pipeline. `optional` means witness runs but findings surface as advisory; `skip` disables entirely (use only for subjective domains where intent-match is inherently ambiguous). |
| `witness.forest` | `required` \| `optional` \| `skip` | Whether the session-forest witness runs at loop exit. Defaults to `required` when the session touched 3+ files or the user issued a scope-broadening directive; `skip` is only appropriate for explicitly single-file loops. |

`witness.commit: skip` is the main-runtime bypass that the main agent is not allowed to grant — it must be declared in `loop.yaml` up-front, not decided on the fly. See `agents/sonmat-witness.md` §When witness is invoked for the rationale.


## 4. Discipline Injection

### Injection order
1. Load core.md (always)
2. Load hints.md (always — worker applies what's relevant)
3. Apply project CLAUDE.md overrides (if any `## sonmat` section exists)
4. Inject into System 1 processing or System 2 worker prompt

**Exclusion**: witness is **never** injected with discipline. Witness is a comparator, not a rule-follower; its own operating principles are embedded in the agent definition itself and are distinct from core.md discipline (cf. `agents/sonmat-witness.md` §Operating principles). The only inputs witness receives are raw user turns and the artifact — nothing else.

### Project override format
```markdown
## sonmat
discipline:
  add:
    - "Custom rule for this project"
```

### Worker prompt composition (L2/L3)
```
[1. Role]       — 1 line. Debugger/executor/researcher/reviewer.
[2. Discipline] — core.md + hints.md + project overrides. ~30 lines.
[3. Loop context] — Loop definition YAML + current iteration state.
[4. Task]       — Specific work instructions + reporting format.
```


## 5. Escalation System

Based on dual-process theory. System 1 handles by default; escalate to System 2 when FOR (Feeling of Rightness) drops.

### 4 Triggers

| Trigger | Detection | Example |
|---------|-----------|---------|
| **Surprise** | Expected ≠ actual result | Test expected to pass but failed |
| **Error** | Same failure 2+, fix breaks another | Same test fails twice |
| **Fluency break** | Missing reference, unclear scope | File/path not found |
| **Conflict** | Action vs core.md rules or loop plan clash | Core.md rule violation detected, or action would contradict `loop.constraints` |

### 4 Levels

| Level | Name | Action |
|-------|------|--------|
| **L0** | System 1 | Direct execution, no escalation |
| **L1** | System 1 enhanced | Pause, check impact scope |
| **L2** | System 2 spawn | Spawn 1 sonmat-worker (deep analysis) |
| **L3** | System 2 extended | Spawn multiple workers in parallel |

### Trigger → Level mapping

| Situation | Level |
|-----------|-------|
| First unexpected result | L0 → L1 |
| Same failure 2x | L1 → L2 |
| Fix breaks something else | → L2 |
| Missing file/path | L0 → L1 (search, retry) |
| Dependency missing + unclear scope | → L2 |
| Core.md rule violation | → L1 |
| Scope change vs existing plan | → L2 |
| Milestone-scale planning | → L3 |
| L2 worker can't resolve | → L3 |

### Escalation output
```
⚡ [Trigger] detected
  Cause: [specific cause]
  Action: L[N] → [what will be done]
  💡 Tip: [customization suggestion] (when applicable)
```

### Resolution output
```
✓ [Trigger] resolved → L[N] return ([brief explanation])
```


## 6. Subagent Dispatch & Routing

autoloop spawns two distinct subagent types, with different purposes, inputs, and routing rules. They are documented together here because the spawn-and-route pattern is common, but they are **not** interchangeable.

| Subagent | Purpose | Input | When spawned |
|---|---|---|---|
| **sonmat-worker** | Execute deep analysis or implementation steps that exceed System 1 capacity | discipline-injected prompt + loop context + task instructions | L2/L3 escalation during [Execute], or [Plan] brainstorming |
| **sonmat-witness** | Intent-artifact match verification in isolated context | raw user-turn cascade + artifact (git diff / files) — **no discipline injection, no main CoT** | [Judge] keep pipeline (commit gate) + [Repeat/Exit] (session forest) |

### 6a. Worker dispatch

#### L2: Single worker
Spawn sonmat-worker with the prompt from section 4 (Discipline Injection). Worker receives full discipline.

#### L3: Parallel workers
- Split into independent tasks (no file overlap).
- Same discipline, different task instructions.
- Wait for all → check conflicts → merge or escalate to user.

#### Worker status → loop routing

| Status | Loop action |
|--------|-------------|
| `DONE` | Pass to [Evaluate] |
| `DONE_WITH_CONCERNS` | Pass to [Evaluate] + report concerns to user |
| `NEEDS_CONTEXT` | Provide more context or ask user |
| `BLOCKED` | Escalate to L3 or delegate to user |

If worker needs to modify files outside `loop.modify`, it must report the need — not modify directly. Main session asks user to expand scope.

### 6b. Witness dispatch

Witness is **not** a worker. It does not receive discipline, does not execute tasks, and does not modify state. Its only job is comparator verification in protocol isolation from main's reasoning (`agents/sonmat-witness.md` §Isolation stack).

**How witness is actually spawned**: via the Task tool with `subagent_type: sonmat-witness`, invoked from within autoloop's [Judge] keep pipeline and [Repeat/Exit] forest check. This is a documented, supported path — Task tool subagent delegation is the native Claude Code primitive for spawning isolated subagents. Earlier drafts of this document referred to a "PreToolUse hook → agent hook → deny" pipeline; that path turned out to be undocumented for PreToolUse specifically, and is not the path we use. The enforcement model is autoloop discipline: main must follow the [Judge] pipeline sequence, and the witness Task call is one step in that sequence. This is the same discipline-enforcement model as all other autoloop phases.


Spawn points:
- **[Judge] keep pipeline** — commit-gate scope, per iteration. Gated by `loop.witness.commit`.
- **[Repeat/Exit]** — session-forest scope, at loop exit. Gated by `loop.witness.forest`.

Spawn prompt composition is different from worker's:

```
[1. Scope]    — commit | session-forest | principle-coverage
[2. User turns] — raw, unmodified. Session cascade for forest scope; task cascade for commit.
[3. Artifact]  — git diff + file paths. No summary.
[4. Principle candidate] — (optional, principle-coverage only) literal phrase anchored to user turns
```

**Never include**: discipline/core.md, hints.md, main's chain-of-thought, main's application notes, worker reports, or commit messages as separate inputs. Comments and commit messages embedded in the artifact are visible but citation-invalid (see witness.md §Seen-but-unusable).

#### Witness verdict → loop routing

| Verdict | Loop action |
|---------|-------------|
| `PASS` | Commit / session-exit proceeds. Record verdict in journal (via scribe dispatch). |
| `BLOCK` | Commit-scope: judgment downgraded to **refine**, cited mismatch becomes the next [Execute] target. Forest-scope: session-exit paused, findings reported to user, user decides fix or override. Do not retry witness on the same artifact without a real change in between. |
| `WARN` | Surface to user verbatim (citation included). User confirms → proceed. User rejects → refine. |
| `INSUFFICIENT_GROUND_TRUTH` | Witness could not run its checks. Report to user that the operation is proceeding *without* intent-match verification. Do not silently suppress. |

Witness verdicts are never overridden by main's self-judgment. If main believes witness is wrong, escalate to user — never auto-bypass. This is the structural-isolation principle; bypassing it defeats the mechanism.


## 7. User Growth

Philosophy: "There are no bad users." Transparency in every judgment enables growth.

### 3 Principles
1. **Open customization surface**: Loop definitions, discipline overrides, project rules — always modifiable. Actively show where.
2. **Just-in-time guidance**: On escalation, suggest how to prevent it next time. Never force.
3. **Transparent judgment**: Every keep/discard/refine and escalation includes "why".

### Loop report format
```
📊 Loop Report
  N iterations | keep M | discard K | refine J
  Escalations: [summary or "none"]
  Retrospective: [1-2 lines, if 3+ iterations]
  Result: [final state]
```

Simple loops (1 keep, done): `📊 1 iteration. [result]. No escalation.`
