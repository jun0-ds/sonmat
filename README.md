# sonmat (손맛)

> 엄마 손맛은 맛있는데 왜 내가 하면..?

> Your AI is confident. Your AI is wrong. And neither of you noticed.

손맛은 AI와 사용자 양쪽에 **의심하고 검증하는 습관**을 심는 Claude Code·Codex 플러그인입니다.

## What this is

A Claude Code and Codex plugin that builds the habit of **doubting and correcting** on both sides.

Your AI delivers answers with confidence but no verification. You accept them because they sound right. Nobody checks. Errors compound silently.

sonmat breaks this cycle:

- **For the AI** — injects a verification discipline into every agent, including subagents. Break it (find where it fails), Cross it (verify independently), Ground it (execute, don't assume).
- **For you** — surfaces the AI's reasoning transparently so you can actually judge instead of just trusting.

That's it. Everything else is implementation.

## Install

### Claude Code

```bash
/plugin marketplace add jun0-ds/sonmat
/plugin install sonmat@sonmat
```

On first session, sonmat plants a reference block in your `~/.claude/CLAUDE.md` automatically. Start talking.

### Codex

```bash
codex plugin marketplace add jun0-ds/sonmat
codex plugin add sonmat@sonmat
```

Start a new thread and open `/hooks`. Review the SessionStart hook before trusting it. Codex binds trust to the hook hash, so a changed hook waits for review instead of running silently.

The hook engages the discipline through session context without editing `AGENTS.md`. It also reports the exact path of the optional native-agent installer. Review that script, then run the command it prints to install `sonmat_worker`, `sonmat_witness`, and `sonmat_scribe` under `~/.codex/agents/`. The installer is idempotent and refuses to overwrite a locally modified agent unless you pass `--force`.

### Reinstall

스킬이 보이지 않을 때 (터미널에서 직접 실행):

```bash
# 재설치
claude plugin marketplace add jun0-ds/sonmat
claude plugin install sonmat@sonmat
```

위 방법이 안 되면 수동 클론 후 등록:

```bash
rm -rf ~/.claude/plugins/marketplaces/sonmat
git clone https://github.com/jun0-ds/sonmat.git ~/.claude/plugins/marketplaces/sonmat
claude plugin install sonmat@sonmat
```

자세한 진단 방법은 [Troubleshooting](docs/troubleshooting.md) 참고.

### Platform notes

sonmat works on both Windows and Linux/macOS. The hook layer (`run-hook.cmd`) is a polyglot script — cmd.exe runs the batch portion, Unix shells run the bash portion.

**Windows (native)**
- Claude Code calls `run-hook.cmd` via cmd.exe
- The script finds Git for Windows bash (`C:\Program Files\Git\bin\bash.exe`) or any bash on PATH
- No extra setup needed if Git for Windows is installed

> **Git Bash (MSYS2) 주의**: Git Bash에서 `/plugin install` 등 슬래시 명령 실행 시 MSYS2가 경로를 자동 변환하여 `C:/Program Files/Git/plugin`처럼 깨질 수 있다. `MSYS_NO_PATHCONV=1` 환경변수를 설정하거나, WSL2 사용을 권장한다.
>
> ```bash
> # Git Bash에서 경로 변환 비활성화
> export MSYS_NO_PATHCONV=1
> ```

**Windows (WSL2) — recommended**
- Claude Code runs inside WSL2, so hooks execute as plain bash
- Paths stay Linux-native (`~/.claude/...`) — no cross-filesystem issues
- Git Bash의 MSYS2 경로 변환 문제가 없음
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

Claude Code and Codex have native plugin adapters. The discipline and skills remain plain markdown, so other AI CLIs can use them with a manual setup.

Each CLI has its own equivalent of `CLAUDE.md`:

| CLI | Global instruction file | Where to put sonmat files |
|-----|------------------------|--------------------------|
| Claude Code | `CLAUDE.md` | Plugin install (see above) |
| Codex | `AGENTS.md` | Native plugin install above |
| Gemini CLI | `GEMINI.md` | `~/.gemini/sonmat/` |
| Other | Whatever file your CLI reads as its main guide | Copy there |

**Setup (CLIs without a native adapter):**

Paste the following into your first conversation with the AI. It will set up sonmat in its own environment:

```
Install sonmat into your environment.

1. Clone https://github.com/jun0-ds/sonmat into your config directory
   as a single directory (Gemini: ~/.gemini/sonmat/).
   Keep it as one unit — sonmat is a unified verification system,
   not a collection of separate files.

2. Read sonmat/discipline/core.md and sonmat/discipline/hints.md,
   then embed their contents directly into your main instruction file
   (Gemini: GEMINI.md).
   Do NOT use file references like "see core.md" — paste the actual content,
   because references may be ignored.

3. List the sonmat/skills/ paths in your instruction file
   so you can use them when needed.
```

Claude Code and Codex handle discipline loading through their plugin adapters. For other CLIs, the AI sets itself up from the instruction above.

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
  └─ Thinking Discipline block — standing instruction: read core.md & apply every session
  └─ sonmat section (paths to discipline files)
       └─ core.md — verification rules (Break / Cross / Ground)
       └─ hints.md — domain-specific traps
```

On first session the hook plants two things into `~/.claude/CLAUDE.md`: a **reference block** (paths to the discipline files) and a **Thinking Discipline block** — the standing instruction that actually engages the discipline (read `core.md` + `hints.md` and apply them as the premise of every response). Without it a fresh user gets only the file locations, so the discipline engages weakly. The working-command block is skipped when the user already keeps their own discipline section, so it never duplicates a hand-written one. After that the hook outputs nothing — Claude reads the discipline through the normal CLAUDE.md loading path. Zero additionalContext overhead.

Codex uses the same SessionStart hook but follows a different branch. It never creates or edits `CLAUDE.md` or `AGENTS.md`; instead it supplies a small read-and-apply command as session context. Native subagent definitions live under `codex/agents/` and are copied into `~/.codex/agents/` only after the user runs the explicit installer.

### Loop & escalation

`Plan → Execute → Evaluate → Judge → Repeat/Exit` — with automatic escalation when things go wrong (L0 skill → L1 pause → L2 worker spawn → L3 parallel workers).

### Structure

```
sonmat/
├── skills/          # autoloop, guard, plan, inspect
├── discipline/      # core.md (verification) + hints.md (domain traps)
├── agents/          # Claude Code worker, witness, and scribe definitions
├── codex/agents/    # Codex-native custom-agent definitions
├── scripts/         # explicit Codex agent installer
└── hooks/           # harness-aware session start adapter
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
| superpowers brainstorming | `skills/autoloop/` planning questions |
| GSD spec → plan → execute | `skills/plan/` + `skills/autoloop/` |
| karpathy-skills principles | `discipline/core.md` |

## FAQ

**Q: What is sonmat?**
A: sonmat is a Claude Code and Codex plugin that builds verification habits into AI-human collaboration. It provides six reactive checking axes — guard, inspect, witness, punch, devil's advocate, and scribe — so that errors in AI outputs get caught before they compound. The name (손맛, "hand taste") refers to the unique quality a skilled cook brings — the gap between generic output and verified, grounded work.

**Q: How is sonmat different from other Claude Code plugins like superpowers or ultrathink?**
A: The key difference is discipline propagation. Every popular plugin keeps its rules in the main session only — subagents and workers start blank, with no verification rules. sonmat injects discipline into every agent at dispatch time, so verification works at every level, not just the top.

**Q: Does sonmat work with Codex CLI or Gemini CLI?**
A: Yes. Codex has a native plugin manifest, a harness-aware SessionStart branch, and optional native custom agents. Gemini CLI still uses the one-time manual setup because sonmat does not ship a Gemini-specific adapter.

**Q: Does sonmat slow down my workflow?**
A: Claude Code uses a prompt-first architecture: after the one-time `CLAUDE.md` bootstrap, the hook has no discipline-context overhead. Codex adds one small SessionStart instruction that tells the agent to read and apply the discipline files. The verification skills and agents run only when their workflow calls for them.

**Q: What are the six verification axes?**
A: **Guard** blocks bad commits (sensitive files, broken tests). **Inspect** checks blast radius on shared code, auth, or infra changes. **Witness** independently compares what was built against what was requested. **Punch** audits completeness — finds omissions and leftover artifacts. **Devil** surfaces counter-arguments before irreversible decisions. **Scribe** persists findings after work completes.

**Q: Can I use only some of the skills?**
A: Yes. Each skill is independent — use `/guard` before commits, `/punch` before delivery, or `/devil` before big decisions. You don't have to use all six at once.

## Troubleshooting

설치 문제, Windows 경로 변환, 스킬 미표시 등 → [docs/troubleshooting.md](docs/troubleshooting.md)

## Attribution

If you use or reference sonmat in your project, a mention is appreciated:

> Built with [sonmat](https://github.com/jun0-ds/sonmat) by jun0-ds

## License

BSD 3-Clause — see `LICENSE`.
