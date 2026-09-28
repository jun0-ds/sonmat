# 2026-09-28 — Project instruction entrypoint

- Status: accepted
- Updates: `2026-08-29-codex-native-adapter.md`, `2026-04-26-hunsugun-project-rule-seam.md`
- Release: v0.18.2

## Context

Scribe's project-rule protocol named `CLAUDE.md` as its only target. That worked only where Claude Code loaded the file. In a Codex session, `AGENTS.md` is the native project instruction file, so a confirmed rule could land in a file Codex did not load. The Claude-oriented bootstrap made the same asymmetry visible on fresh projects.

## Decision

`AGENTS.md` is the canonical per-project instruction file. Scribe writes `## Project Rules` there and no `CODEX.md` is introduced.

`CLAUDE.md` is a Claude Code adapter. For a fresh Claude Code project, SessionStart creates a minimal `AGENTS.md` and a `CLAUDE.md` containing `@AGENTS.md`. Claude-specific instructions may live after that import.

The Codex SessionStart hook still does not create or edit either durable instruction file. A user-confirmed scribe proposal may create `AGENTS.md`; a Claude adapter change remains separately reviewable.

## Existing projects

An existing `CLAUDE.md` can carry useful project-specific instructions, so it is not safe to replace it with an import automatically. When no `AGENTS.md` exists, the hook reports the migration condition and leaves both content and ownership untouched. Migration is a project-scoped, user-approved diff: move common rules to `AGENTS.md`, replace duplication with `@AGENTS.md`, and retain only Claude-specific additions in `CLAUDE.md`.

## Consequences

New project rules are visible to Codex directly and to Claude Code through one import. Older Claude-only projects remain compatible but are not canonical until deliberately migrated. This changes the Claude bootstrap template and scribe wording, so both harness branches need regression coverage.
