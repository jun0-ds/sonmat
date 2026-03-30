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

### Platform notes

sonmat works on both Windows and Linux/macOS. The hook layer (`run-hook.cmd`) is a polyglot script — cmd.exe runs the batch portion, Unix shells run the bash portion.

**Windows (native)**
- Claude Code calls `run-hook.cmd` via cmd.exe
- The script finds Git for Windows bash (`C:\Program Files\Git\bin\bash.exe`) or any bash on PATH
- No extra setup needed if Git for Windows is installed

**Windows (WSL2) — recommended**
- Claude Code runs inside WSL2, so hooks execute as plain bash
- Paths stay Linux-native (`~/.claude/...`) — no cross-filesystem issues
- `settings.json` hooks should point to the bash script directly:
  ```json
  {
    "type": "command",
    "command": "bash ~/.claude/plugins/marketplaces/sonmat/hooks/session-start"
  }
  ```

**Linux / macOS**
- Works out of the box. No special config.

**Codex CLI?**
See [sonmat-codex](https://github.com/jun0-ds/sonmat-codex) — a dedicated port with domain auto-detection and benchmark skill.

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

### Loop & escalation

`Plan → Execute → Evaluate → Judge → Repeat/Exit` — with automatic escalation when things go wrong (L0 skill → L1 pause → L2 worker spawn → L3 parallel workers).

### Structure

```
sonmat/
├── skills/          # loop, guard, plan
├── discipline/      # core.md (verification) + hints.md (domain traps)
├── agents/          # sonmat-worker (System 2, discipline-injected)
└── hooks/           # session start
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

| Before | After (sonmat) |
|--------|---------------|
| superpowers TDD/debug/review | `discipline/core.md` + `hints.md` |
| superpowers brainstorming | `skills/loop/` planning questions |
| GSD spec → plan → execute | `skills/plan/` + `skills/loop/` |
| karpathy-skills principles | `discipline/core.md` |

## License

MIT — see `LICENSE`.