# Feature Request — Claude Code isolation primitives for verifier subagents

**Date**: 2026-04-15
**Context**: Designing sonmat-witness, a structurally isolated intent-artifact comparator that verifies commits against raw user turns without being contaminated by the executing agent's reasoning.

## The gap

Building a verification architecture where a second agent checks the first agent's work against the user's original intent requires three capabilities. Current Claude Code / Claude Agent SDK supports part of one.

| Capability | Current status | Sonmat-witness need |
|---|---|---|
| **Execution-level context isolation** between subagent and parent | ✅ Supported | Used |
| **Reasoning-level context isolation** — preventing the subagent from seeing parent's system prompt, prior tool outputs, or in-flight chain-of-thought | ❌ No documented mechanism | Required for structural isolation |
| **Nested subagent delegation** — a subagent spawning its own sub-subagents | ❌ Explicitly forbidden ([multi-agent docs](https://platform.claude.com/docs/en/managed-agents/multi-agent.md)) | Needed for orchestrator-worker layering above verifier |
| **Session-level intent extraction layer** — a component that reads user turns before main processes them and can route them to isolated verifiers | ❌ No such concept in docs | Needed to remove main's role in preparing witness's input |
| **PreToolUse hook → synchronous subagent verdict → deny** pipeline | ❓ Inferable from `"type": "agent"` hooks + `permissionDecision: "deny"`, but not documented | Needed for commit-gate blocking |

## Why reasoning-level isolation matters

The core failure mode that verifier subagents exist to prevent is the same one documented in Huang et al. 2023 ("LLMs Cannot Self-Correct Reasoning Yet"): when a verifier shares context with the executor, it inherits the executor's rationalizations and becomes a confirmation rubber-stamp instead of an independent check.

Execution-level isolation (separate context window, separate tool permissions) prevents the executor from *driving* the verifier, but it does not prevent the *spawn prompt* from laundering the executor's reasoning into the verifier's input. Today, the sonmat-witness design enforces this by protocol: the spawn prompt must contain only raw user turns and the artifact. This is discipline-enforced at the orchestration layer, not harness-enforced.

A harness-level option to declare "this subagent must receive input from channel X only, and other channels are platform-rejected" would move this from discipline to structure. Example shape:

```yaml
subagent:
  name: witness
  input_channels: [raw_user_turns, artifact_files]
  forbidden_channels: [parent_system_prompt, parent_tool_outputs, parent_messages]
```

Forbidden channels would be enforced at spawn time; attempting to include them would return a platform error rather than silently passing them through.

## Why nested delegation matters

The sonmat architecture wants a three-role structure:

- **Session layer**: extracts user turns at the boundary of the conversation, routes them to verifiers
- **Orchestrator**: drives execution, makes decisions about what to modify
- **Worker**: carries out individual tool calls

If nested delegation were supported, the verifier (witness) could live above the orchestrator and intercept every decision point without the orchestrator having any opportunity to colour its input. Today this is impossible because:

1. Main (conversation + orchestration combined) is the only agent that can spawn subagents
2. Subagents cannot spawn further subagents

Consequence: witness's input pipeline runs *through* main, which is exactly the executor whose reasoning witness is supposed to be isolated from. The isolation is partial by construction.

Lifting the nesting restriction to allow **one additional level** of delegation (so orchestrator can spawn workers, and a session layer above orchestrator can spawn the verifier) would close this gap. Unbounded nesting is not needed; two levels of delegation would cover this use case and most similar verifier-based architectures.

## Why session-level intent extraction matters

Currently, the boundary between "what the user said" and "what main decided the user meant" lives inside main. A verifier that reads main's interpretation of user intent inherits main's interpretation bias. A session layer that extracts the raw user-turn stream before main sees it, and passes it to both main and the verifier independently, would make intent the shared source of truth rather than a main-mediated artifact.

This could be built on top of `UserPromptSubmit` hooks if hooks were allowed to fork the user turn into multiple downstream channels, one of which is a subagent with its own long-lived context.

## Why PreToolUse hook → subagent verdict → block documentation matters

The hook types `"command"`, `"http"`, `"prompt"`, and `"agent"` are documented. The `permissionDecision: "deny"` field is documented. What is not documented is whether:

1. An `agent`-type PreToolUse hook can synchronously wait for the subagent to complete before the tool call proceeds
2. The subagent's verdict can be used to populate `permissionDecision`
3. This pattern scales (i.e., doesn't add unbounded latency to every gated tool call)

Even a short documentation page saying "yes, this works, here's a minimal example, here are the latency expectations" would let us rely on this pattern instead of inferring it from part counts.

## Non-goals

- Unbounded subagent nesting. Two levels of delegation are sufficient for verifier architectures and most orchestration patterns.
- Removing main's ability to compose prompts for its own subagents. This feature request is about *additional* channel controls, not about taking away existing flexibility.
- Replacing agent-decides model with harness-decides. We understand Anthropic's architectural choice here and are not asking for it to be reversed. We are asking for one additional structural primitive (channel-level input restriction) that lets verifier architectures live comfortably inside the agent-decides model.

## What sonmat is doing in the meantime

- Building witness as a 2-layer (witness-pair) architecture on the primitives available today
- Documenting the isolation stack honestly: execution-level (harness-enforced) + spawn-prompt discipline (design-enforced) + citation rule (behavioral)
- Treating the above as "protocol isolation" rather than "structural isolation" in the documentation
- Runtime-verifying the PreToolUse → agent hook → deny pattern before relying on it in production autoloop integrations

We can ship a functional witness-pair architecture without these features. The features would let us ship a stronger one.
