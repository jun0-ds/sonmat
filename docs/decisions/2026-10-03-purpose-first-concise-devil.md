# Purpose first discipline and concise devil

2026-10-03. Applies to the shared sonmat discipline and requested devil reviews in Claude Code
and Codex. The change is packaged as `0.23.0`; the user's global AGENTS.md is unchanged.

## Context

The maintainer reported that devil found logical weaknesses but did not reliably help decide
what to do toward the intended outcome. Adding mandatory Musk or jobs-to-be-done stages would
make the review larger without establishing that it became more useful.

A six-case synthetic comparison found that both the installed skill and a concise draft
preserved purpose, material assumptions and next choices under the manual rubric. The draft's
combined responses were 39.3% shorter. That is evidence for concise delivery on those cases,
not better purpose inference, speed or performance on real plans.

## Decision

The existing Before Acting rules now read the user's intended outcome and constraints before
judging the means. Explicit goals outrank inferred goals; uncertain inferences are labeled,
and clarification is needed only when the uncertainty changes the action. Deletion and reuse
are considered before adding work. Verified essentials, trust boundaries and authorization remain.

Devil retains claim-crux, alternative explanations, causal checks, relevance to stakes and next
actions, and a legitimate decision to keep a sound plan. It puts purpose first and removes the
mandatory balance table, bias naming, ratings and step-by-step output. Musk and jobs-to-be-done
are optional perspectives, not extra processes. The review remains opt-in and one round; it
does not block actions, edit files or infer new authority. Existing invocation metadata remains.

## Consequences

The source files are `discipline/core.md` and `skills/devil/SKILL.md`, shared by both harnesses.
Both plugin manifests and both marketplace version fields use `0.23.0` under
[Versioning](../../VERSIONING.md). There is no Codex-only or Claude-only copy of the new rules.

The initial local trial also applied those two files to the current Codex cache under
`sonmat/0.21.4` on this laptop. That override is not the delivery mechanism for this change:
its directory version does not identify a new release and a plugin update can replace it.
Publication and normal plugin updates must carry the shared package to both harnesses.
Those updates, other devices and fresh-session behavior are not yet verified. No hook, provider,
Paseo service, credential configuration or global AGENTS.md was changed.

Codex support shell tests passed. The generic skill validator rejected the existing
`user-invocable` property, which it does not support; it was not removed to satisfy that checker.
YAML, name, description, preserved invocation metadata and source/install equality were checked
separately. File equality is not proof that a fresh session has loaded or benefits from the change.

No new planner, reviewer or persistent goal state was introduced. Real-plan usefulness and
fresh-session behavior remain evaluation tasks; improvement claims require observed outcomes.
