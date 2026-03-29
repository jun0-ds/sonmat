---
name: plan
description: Milestone/phase management — progress.md based project progress tracking.
---

# Plan Skill

## Overview

Manage projects in a 3-tier structure:

- **Milestone**: Major goal unit (e.g., "MVP launch", "v2.0 complete")
- **Phase**: Steps within a milestone (e.g., "Design done", "Core features implemented")
- **Task**: Execution units within a phase (e.g., "Write DB schema", "Implement API endpoints")

Track state via markdown checkboxes in `progress.md`. Track history via git commits.
No separate state files, dedicated agents, or CLI commands.

---

## progress.md Operations

### Location
Project root. Create or update as needed. If missing, build through planning questions.

### Format

```markdown
# Project Progress

## Milestone 1: [goal]
- [x] Phase 1: [description]
- [ ] Phase 2: [description]
  - [x] Task 1
  - [ ] Task 2

## Milestone 2: [goal]
- [ ] Phase 3: [description]
  - [ ] Task 3
  - [ ] Task 4
```

### Rules
- `[x]` = complete, `[ ]` = incomplete.
- Indent: milestone > phase > task.
- On state change: update `progress.md` and git commit.
- Commit format: `plan: [phase/task name] done` or `plan: [phase name] started`

---

## Natural Language Commands

### "Start next phase"
1. Read `progress.md` to find current position.
2. Find first incomplete (`[ ]`) phase.
3. Confirm task list with user.
4. Commit: `plan: [phase name] started`

### "Show progress"
1. Read `progress.md` — tally complete/incomplete items.
2. `git log --oneline -20` for recent history.
3. Summarize: progress per milestone, current phase, next action.

### "Create roadmap"
Large scope — escalate to System 2.

Planning questions:
- What is the end goal?
- Any deadlines?
- How large should milestones be?
- Anything that needs to start immediately?

Draft `progress.md` from answers, present for user review.

### "Mark this phase done"
1. Change `[ ]` to `[x]` for the phase in `progress.md`.
2. If incomplete tasks remain under it, confirm with user.
3. Commit: `plan: [phase name] done`

---

## Milestone-Level Planning

Large-scope work (new milestones, roadmap restructuring, priority changes) → escalate to System 2 and run planning questions.

**Escalation criteria:**
- Adding or significantly changing milestones
- Structural changes spanning multiple phases
- Requests like "redo the roadmap", "change strategy"

On escalation: provide current `progress.md` as context, run planning questions, write updated `progress.md` from consensus.
