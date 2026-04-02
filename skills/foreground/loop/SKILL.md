---
name: loop
description: 범용 자율 루프 — 기획→정의→실행→평가→판단→기록→반복. 에스컬레이션 판단 포함.
user-invocable: true
---

# Loop — Autonomous Loop Protocol

## 0. Entry Routing

On receiving a task, judge complexity:

| Signal | L0 (direct) | Full loop |
|--------|-------------|-----------|
| Files to modify | 1 | Multiple |
| Iteration needed | One-shot | Expected |

**L0**: Skip planning questions and definition. Apply core.md + hints.md → execute → verify → done. Escalate to full loop if a trigger fires.

**Full loop**: Proceed to section 1.

**Bridge-note check**: Before starting any task, check if `.claude/sonmat/bridge-note.md` exists. If relevant context is found, incorporate it silently. Mention to user only if directly relevant to the new task.


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
Don't adopt the first approach that comes to mind. Have the worker generate variations (different constraints, different priorities), then cross-compare and present options to user.

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
| **keep** | `loop.judge.keep` met | Self-review → guard review → commit |
| **discard** | `loop.judge.discard` met | `git restore` (revert) |
| **refine** | Partial improvement | Keep good parts, fix bad parts, re-execute |

On keep: loop self-review → guard completion review → commit. If review finds issues → switch to refine.

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

**Scribe dispatch** (on exit):
- **keep**: Dispatch scribe with mode `all` (bridge + journal + progress). Include loop report and git diff as artifacts.
- **discard**: Dispatch scribe with mode `journal` only. Record what was tried and why it failed.
- Scribe runs in background. Do NOT wait for it. Proceed with user interaction immediately.

### Retrospective (after 3+ iterations)
- Was the approach order optimal?
- Where did intent diverge from result?
- What untried approach might have been better?
- Include 1-2 line summary in loop report.

### Memory update (on loop exit)
After retrospective, check: did this loop reveal a lesson not already in sonmat memory?
- If yes → propose a memory record to the user (same format as guard's novel trap).
- Project-specific → `{project}/.claude/sonmat/`
- Universal → `~/.claude/sonmat/memory/`
- If multiple project lessons have accumulated, check if any should be promoted to universal memory (inductive review).


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
  exit: "Fewer than 5 changes in a pass"
```

`require_user_confirmation: true` — for domains where automated judgment isn't reliable (writing, design). Must show changes and get approval before keep/discard.


## 4. Discipline Injection

### Injection order
1. Load core.md (always)
2. Load hints.md (always — worker applies what's relevant)
3. Apply project CLAUDE.md overrides (if any `## sonmat` section exists)
4. Inject into System 1 processing or System 2 worker prompt

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
| **Conflict** | Action vs discipline/plan clash | Discipline violation detected |

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
| Discipline violation | → L1 |
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


## 6. Worker Dispatch (L2/L3)

### L2: Single worker
Spawn sonmat-worker with the prompt from section 4.

### Worker status → loop routing

| Status | Loop action |
|--------|-------------|
| `DONE` | Pass to [Evaluate] |
| `DONE_WITH_CONCERNS` | Pass to [Evaluate] + report concerns to user |
| `NEEDS_CONTEXT` | Provide more context or ask user |
| `BLOCKED` | Escalate to L3 or delegate to user |

If worker needs to modify files outside `loop.modify`, it must report the need — not modify directly. Main session asks user to expand scope.

### L3: Parallel workers
- Split into independent tasks (no file overlap).
- Same discipline, different task instructions.
- Wait for all → check conflicts → merge or escalate to user.


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
