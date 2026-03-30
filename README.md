# sonmat (손맛)

> 엄마 손맛은 맛있는데 왜 내가 하면..?

> Your AI is confident. Your AI is wrong. And neither of you noticed.

sonmat teaches both of you to doubt and fix.

## What this is

A Claude Code plugin that builds the habit of **doubting and correcting** — on both sides.

Your AI delivers answers with confidence but no verification. You accept them because they sound right. Nobody checks. Errors compound silently.

sonmat breaks this cycle:

- **For the AI** — injects a verification discipline into every agent, including subagents. Break it (find where it fails), Cross it (verify independently), Ground it (execute, don't assume).
- **For you** — surfaces the AI's reasoning transparently so you can actually judge instead of just trusting.

That's it. Everything else is implementation.

## Install

```bash
/plugin marketplace add jun0-ds/sonmat
/plugin install sonmat@sonmat
```

No config. Start talking.

## Design philosophy

1. **Confidence is when you should doubt** — When the model feels sure, that's exactly when it should look for counterexamples. Confidence without verification is just hallucination with good posture.

2. **Rules that don't propagate don't exist** — Discipline only in the main session is decoration. sonmat injects it into every worker at dispatch time.

3. **Autonomy ≠ abandonment** — Autonomous loops need guardrails. Escalation kicks in at the right moment — not too early, not too late.

4. **Every domain has its own traps** — "Write tests first" is vital for dev, meaningless for data analysis. "One change at a time" is essential for ML, overkill for docs.

## How it works

### Discipline injection

When Claude spawns a subagent, sonmat attaches the discipline directly to the worker's prompt:

```
You (main session)
  → spawns sonmat-worker
      ↳ task description
      ↳ core discipline (verification attitude)
      ↳ domain-specific traps (dev / ML / analysis / doc)
      ↳ must report: surprises, errors, conflicts
```

Not a file reference. Not a hook that might fire. Actual rules in the actual prompt. The worker can't skip what's in its own prompt.

### Autonomous loop

```
Plan → Define → Execute → Evaluate → Judge → Record → Repeat/Exit
```

Judgment: keep / discard / refine. Not blind repetition.

### Escalation

| Level | Action |
|-------|--------|
| L0 | Skill handles it directly |
| L1 | Pause, double-check |
| L2 | Spawn worker with discipline |
| L3 | Spawn parallel workers |

Triggers: surprise results, repeated failures, missing references, rule conflicts. Automatic — you don't decide when to escalate.

### Structure

```
sonmat/
├── skills/
│   ├── loop/        # autonomous loop engine
│   ├── guard/       # pre-commit checks, scope control
│   └── plan/        # milestone/phase tracking (progress.md)
├── discipline/
│   ├── core.md      # always-on verification rules
│   └── hints.md     # domain-specific trap hints
├── agents/
│   └── sonmat-worker.md  # System 2 worker with discipline
└── hooks/                # session start (auto-update, naming, memory)
```

### Naming (optional)

On first session, sonmat suggests a mutual nickname between you and Claude. A small thing that changes how collaboration feels.

| Style | Example |
|-------|---------|
| Equal | friend / friend |
| You > Claude | senior / junior |
| Claude > You | coach / player |

### Override

Add to your project's CLAUDE.md:

```markdown
## sonmat
discipline:
  disable:
    - "hints.md > TDD"
  add:
    - "run ruff format before commit"
```

## Coming from other plugins?

Every popular Claude Code plugin shares the same gap: rules stay in the main session. Subagents start blank.

| Plugin | Main session rules | Rules reach workers? |
|--------|-------------------|---------------------|
| [superpowers](https://github.com/obra/superpowers) | ✓ | ✗ ([#237](https://github.com/obra/superpowers/issues/237)) |
| [GSD](https://github.com/gsd-build/gsd-2) | ✓ | unclear |
| [karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) | ✓ | ✗ |
| ultrathink | ✓ | ✗ ([#25591](https://github.com/anthropics/claude-code/issues/25591)) |

Documented: [claude-code#8395](https://github.com/anthropics/claude-code/issues/8395), [claude-code#22022](https://github.com/anthropics/claude-code/issues/22022)

```bash
# uninstall
claude plugins uninstall superpowers@superpowers-marketplace
claude plugins uninstall andrej-karpathy-skills@karpathy-skills
# For GSD, remove related hooks from settings.json
```

| Before | After (sonmat) |
|--------|---------------|
| superpowers TDD/debug/review | `discipline/core.md` + `hints.md` |
| superpowers brainstorming | `skills/loop/` planning questions |
| GSD spec → plan → execute | `skills/plan/` + `skills/loop/` |
| karpathy-skills principles | `discipline/core.md` |

## License

MIT — see `LICENSE`.