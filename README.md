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

### Other AI CLIs

sonmat is built for Claude Code, but the discipline and skills are plain markdown — they work with any AI CLI.

Each CLI has its own equivalent of `CLAUDE.md`:

| CLI | Global instruction file | Where to put sonmat files |
|-----|------------------------|--------------------------|
| Claude Code | `CLAUDE.md` | Plugin install (see above) |
| Codex | `AGENTS.md` | `~/.codex/` |
| Gemini CLI | `GEMINI.md` | `~/.gemini/` |
| Other | Whatever file your CLI reads as its main guide | Copy there |

**Setup (non-Claude CLIs):**

1. Copy `discipline/` and `skills/` into your CLI's config directory:
   ```bash
   git clone https://github.com/jun0-ds/sonmat.git /tmp/sonmat
   cp -r /tmp/sonmat/discipline /tmp/sonmat/skills /tmp/sonmat/agents ~/.codex/  # or ~/.gemini/
   rm -rf /tmp/sonmat
   ```

2. **Embed the core discipline directly** into your CLI's instruction file (`AGENTS.md`, `GEMINI.md`, etc.). File references like "see discipline/core.md" are weak — the model may or may not read them. Paste the content into the instruction file so the model can't skip it:

   ```markdown
   ## Core Discipline (sonmat)

   ### Verification

   **Attitude: Confidence is the signal to begin, not to stop.**
   When you feel certain about a result, that certainty is information about your
   psychology, not about reality.

   **Directions:**
   1. **Break it**: Construct the conditions under which your conclusion fails.
   2. **Cross it**: Reach the same conclusion through an independent path.
   3. **Ground it**: Go to the source. Run the code, read the data, observe the system.

   ### Transparency
   - State the trigger on escalation: why did you switch to System 2?
   - State the rationale on judgment: why keep/discard/refine?

   ### Domain Hints
   (paste from discipline/hints.md — include what's relevant to your work)

   ### Skills
   - `skills/guard/` — pre-commit verification
   - `skills/loop/` — autonomous loop with escalation
   - `skills/plan/` — milestone/phase management
   ```

   Claude Code handles this automatically via its plugin system. For other CLIs, you are the plugin.

3. Adapt hooks to your CLI's format if needed.

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