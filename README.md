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

On first session, sonmat plants a reference block in your `~/.claude/CLAUDE.md` automatically. Start talking.

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

### Other AI CLIs

sonmat is built for Claude Code, but the discipline and skills are plain markdown — they work with any AI CLI.

Each CLI has its own equivalent of `CLAUDE.md`:

| CLI | Global instruction file | Where to put sonmat files |
|-----|------------------------|--------------------------|
| Claude Code | `CLAUDE.md` | Plugin install (see above) |
| Codex | `AGENTS.md` | `~/.codex/sonmat/` |
| Gemini CLI | `GEMINI.md` | `~/.gemini/sonmat/` |
| Other | Whatever file your CLI reads as its main guide | Copy there |

**Setup (non-Claude CLIs):**

Paste the following into your first conversation with the AI. It will set up sonmat in its own environment:

```
Install sonmat into your environment.

1. Clone https://github.com/jun0-ds/sonmat into your config directory
   as a single directory (Codex: ~/.codex/sonmat/, Gemini: ~/.gemini/sonmat/).
   Keep it as one unit — sonmat is a unified verification system,
   not a collection of separate files.

2. Read sonmat/discipline/core.md and sonmat/discipline/hints.md,
   then embed their contents directly into your main instruction file
   (Codex: AGENTS.md, Gemini: GEMINI.md).
   Do NOT use file references like "see core.md" — paste the actual content,
   because references may be ignored.

3. List the sonmat/skills/ paths in your instruction file
   so you can use them when needed.
```

Claude Code handles this automatically via its plugin system. For other CLIs, the AI sets itself up — you just give it the instruction.

## Design philosophy

1. **Confidence is when you should doubt** — When the model feels sure, that's exactly when it should look for counterexamples. Confidence without verification is just hallucination with good posture.

2. **Rules that don't propagate don't exist** — Discipline only in the main session is decoration. sonmat injects it into every worker at dispatch time.

3. **Autonomy ≠ abandonment** — Autonomous loops need guardrails. Escalation kicks in at the right moment — not too early, not too late.

4. **Every domain has its own traps** — "Write tests first" is vital for dev, meaningless for data analysis. "One change at a time" is essential for ML, overkill for docs.

## How it works

### Discipline loading

sonmat uses a **prompt-first** architecture — no runtime hook injection.

```
CLAUDE.md (always loaded)
  └─ sonmat section (paths to discipline files)
       └─ core.md — verification rules (Break / Cross / Ground)
       └─ hints.md — domain-specific traps
```

On first session, the hook plants a sonmat reference block in `~/.claude/CLAUDE.md`. After that, the hook outputs nothing — Claude reads the discipline through the normal CLAUDE.md loading path. Zero additionalContext overhead.

### Loop & escalation

`Plan → Execute → Evaluate → Judge → Repeat/Exit` — with automatic escalation when things go wrong (L0 skill → L1 pause → L2 worker spawn → L3 parallel workers).

### Structure

```
sonmat/
├── skills/          # loop, guard, plan, inspect
├── discipline/      # core.md (verification) + hints.md (domain traps)
├── agents/          # sonmat-worker (System 2, discipline-injected)
└── hooks/           # session start (side effects only, zero prompt injection)
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