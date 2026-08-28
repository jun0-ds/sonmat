# Codex native adapter

- Status: accepted
- Date: 2026-08-29
- Release: v0.17.0

## Context

Codex could already discover sonmat's skills and SessionStart definition through its compatibility loader. That did not make the plugin semantically safe. The hook assumed every host was Claude Code: it could create a project `CLAUDE.md`, append to the global Claude instructions, migrate Claude-owned state, and emit Claude update commands.

The same gap appeared in the agent layer. Codex custom agents are standalone TOML files under `~/.codex/agents/` or `.codex/agents/`; Claude Code's `agents/*.md` files are not native Codex agent definitions. A plugin that appears installed can therefore expose all skills while leaving witness, scribe, and worker unavailable.

## Decision

Sonmat keeps one plugin repository with separate harness adapters.

The SessionStart hook identifies Codex through `PLUGIN_DATA`, a Codex plugin-hook variable. Codex receives a small instruction to read and apply `discipline/core.md` and `discipline/hints.md`. It does not create or edit either harness's durable instruction files. Claude Code keeps its existing one-time `CLAUDE.md` bootstrap and zero-context steady state.

Codex-native agent definitions ship in `codex/agents/`. They are not copied during SessionStart. The user runs `scripts/install-codex-agents.sh` explicitly after reviewing it. The installer checks every destination before writing, remains idempotent when files match, and refuses to overwrite a changed agent unless the user passes `--force`.

The public plugin keeps state paths portable. Integrators redirect `SONMAT_MEMORY_DIR` and `SONMAT_PROJECTS_BASE` in their service or harness layer; sonmat does not embed an integrating framework's home path.

## Rejected alternatives

### Trust the compatibility loader

Loader acceptance proves only that Codex can parse and launch the hook. It says nothing about which harness-owned files the script mutates. Keeping the old hook active would turn successful discovery into the failure mode.

### Edit `AGENTS.md` automatically

An install hook cannot distinguish a user's global instruction policy from a disposable default. Automatic edits would create the same cross-harness mutation problem under a new filename. Session context is reversible and leaves durable policy with the user.

### Install agents from SessionStart

Custom-agent TOMLs are executable policy: they can change instructions, model settings, sandbox settings, and tool connections. Copying them from an untrusted hook before review would hide a meaningful configuration change inside session startup. An explicit installer preserves a review boundary and can refuse local divergence.

## Consequences

Codex users must trust the hook and run one explicit agent-install command. A new thread is required after either step. The extra ceremony is visible, but the plugin no longer equates successful loading with semantic compatibility.

Claude Code behavior stays backward compatible. Changes to the shared hook need tests for both branches because a fix for one harness can still alter the other branch.
