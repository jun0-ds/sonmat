---
name: devil
description: Devil's advocate for reasoning — discovery-led counter-arguments against interpretations, plans, and irreversible decisions. Locates the load-bearing assumption via CCT, then drives depth into the one axis where the claim is actually thin.
user-invocable: true
---

# Devil — Devil's Advocate for Thinking

Discovery-led counter-argument against the current interpretation, hypothesis, or plan: locate the single load-bearing assumption first, then drive depth into the one axis where the claim is actually thin. Targets **reasoning and judgment**, not code or artifacts.

Positioning within sonmat's verification axes:

| Skill | Axis | Asks |
|---|---|---|
| guard | Main-side verification | "Is the work operationally safe?" |
| inspect | System impact | "What could break?" |
| witness | Intent-artifact match | "Does this match what the user asked for?" |
| punch | Completeness + residue | "Is anything missing or left over?" |
| scribe | Post-work persistence | "Is anything worth keeping?" |
| **devil** | **Reasoning** | **"Is the thinking itself sound?"** |

Invoke: `/devil` (runs once for the current claim, delivers a balance table, and exits — not a mode). The user can re-invoke for another round.

---

## What devil does

When invoked, take the current interpretation and **find its load-bearing part first, then drive depth there**. Discovery before depth; asymmetric attack after discovery. The steps below are not a broad-front assault — they are a structured way to locate the one place the claim is actually fragile and pressure-test it there.

### 1. Identify the claim

Extract the core claim(s) being made. State them back clearly so the user can confirm what's being challenged.

```
[devil] Challenging: "{the claim}"
```

### 2. Active discovery — find the load-bearing assumption

Before attacking on any axis, do the discovery-led step first: **find the single thing this claim is standing on**. Depth is not a dial to turn up at the start; depth is what follows naturally once you have located the load-bearing part.

Use **devil CCT** as the discovery checklist (analogous to chess's CCT — Checks / Captures / Threats — which is a compressed triage that surfaces the sharp part of a position before any deep calculation):

| Check | Question | What it surfaces |
|-------|----------|------------------|
| **C**laim-crux | What is the *one* thing that, if false, would flip this claim? | The load-bearing assumption |
| **C**ounter-fit | Does the same evidence also fit an opposite conclusion? If so, what distinguishes them? | A hidden alternative riding the same data |
| **C**ause-chain | Is the cause → effect direction actually established, or only correlated / reversed / mediated? | A reversed or spurious causal link |

Apply CCT and name the discovery in one line:

```
[devil] Load-bearing: "{the single assumption / crux / causal step the claim depends on}"
```

If CCT surfaces nothing — the claim has no single load-bearing part and is robust across all three — say so. That is a legitimate outcome and often means the claim survives without further attack.

### 2.5. Project-relevance gate — is the located crux material?

Before driving depth into the crux CCT found, check whether it **materially affects what the user is doing now**. A reasoning bug that is technically real but tangential to the project's actual stakes is noise, not signal. This gate exists because devil's signature failure mode is **reactive contradiction** — surfacing genuine logical weaknesses that don't change what the user does. Reactive contradiction feels rigorous but drains attention away from the decision at hand.

Apply three questions:

| Question | Purpose |
|----------|---------|
| **Stakes** | What does the user lose if this reasoning is wrong *here*? Calibrate depth to stakes — a war-room-level decision warrants aggressive pressure; a drill-level decision does not. Uniform intensity across stakes is a symptom of performance, not service |
| **Amendment cost** | Where in the decision's lifecycle does the claim sit? Cheap to amend (early drafting, exploratory plan) vs expensive to amend (committed operational state). Challenging a frozen operational call with low stakes is churn |
| **Next-action delta** | Would surfacing this counter actually change the user's next action, or merely add argument text? If the answer is "no," the challenge is off-project |

Name the gate verdict:

```
[devil] Project relevance: "{material | load-bearing-but-low-stakes | off-project}"
```

- `material` — the crux matters for stakes; proceed to §3 depth
- `load-bearing-but-low-stakes` — crux is real but the stakes don't warrant depth; note briefly and stop
- `off-project` — the crux is technically valid but tangential to the actual decision; say so and stop

`off-project` is a distinct outcome from "claim survives." Survival means the claim is robust; off-project means the challenge itself is misdirected. Both are legitimate exits — devil serves the user by knowing when to stand down, not by manufacturing challenges to look diligent.

### 3. Discovery-led depth on the found axis

Once the load-bearing part is named, depth flows there automatically. The axis that the load-bearing part belongs to is where attention goes; the other two axes get a quick pass, not a full assault. Discovery pulls depth, not the other way around.

| Axis | Question | When to drive depth deep |
|------|----------|--------------------------|
| **Evidence** | What evidence is missing, cherry-picked, or misread? | Load-bearing part is a data/observation claim |
| **Logic** | Where does the reasoning leap, conflate, or reverse cause/effect? | Load-bearing part is an inference step |
| **Alternatives** | What other explanations fit the same facts equally well? | Load-bearing part is a single-narrative interpretation |

Earlier versions of devil attacked all three axes in parallel. Parallel attack is the false-depth failure mode: it consumes attention uniformly across a surface without knowing where the surface is thin. Discovery-led devil is asymmetric on purpose — thin where the claim is robust, deep where it is fragile.

Depth intensity here should also track the §2.5 stakes reading. A `material` verdict warrants full depth; `load-bearing-but-low-stakes` gets a brief note, not a full drive. Calibrating depth to stakes is not softness — it is matching signal strength to the cost of being wrong.

### 4. Name the biases at play

Flag which cognitive biases could be inflating confidence:

- **Confirmation bias** — seeking evidence that agrees
- **Hindsight rationalization** — "it was obviously the plan all along"
- **Survivorship bias** — only seeing the cases that worked
- **Narrative bias** — a good story ≠ a true story
- **Anchoring** — first number/frame dominates thinking
- **Availability** — recent/vivid examples feel more probable

Don't list all six every time. Only flag the ones actually at play.

### 5. Rate the counter-arguments

Be honest about devil's own arguments. The rating below applies to the **dominant counter-argument** — the one devil drove depth into in §3 after CCT located the load-bearing part. Secondary notes on the other two axes get a brief pass only; they are not independently rated and then averaged.

| How strong is the counter-argument? | Meaning |
|--------------------------------------|---------|
| **Strong** | The counter-argument has real teeth. The original claim needs revision or hedging. |
| **Moderate** | Worth considering. Doesn't kill the claim but exposes a blind spot. |
| **Weak** | Technically possible but unlikely. Noted for completeness. |
| **Off-project** | Technically valid but tangential — does not change what the user is doing. Do not spend further attention. |

This is discovery-led strength rating, not parallel strength rating. Rating the dominant counter-argument is judgment on *one* specific thing devil found; rating every counter-argument on every axis as if they were equal contributions would flatten the discovery-led structure back into the parallel-attack failure mode §3 warned against.

`Off-project` is an honest rating, not a dodge. A strong-logic counter that changes nothing about the user's next action is worse than silence — it performs rigor while stealing attention. If the §2.5 gate returned `off-project`, the rating here should name it as such.

### 6. Produce a balance table

End with a comparison table:

```
| Original claim | Counter-argument | Counter (strong/moderate/weak) | Claim after challenge |
|----------------|------------------|-------------------------------|----------------------|
| ...            | ...              | ...                           | ...                  |
```

Claim after challenge options: `holds`, `weakened`, `needs revision`, `flipped`, `off-project` (challenge was misdirected, original claim's status unchanged).

**Well-formed balance table**: one dominant row representing the §3 depth drive (the load-bearing counter on the found axis), plus at most one or two secondary rows noting what the quick passes on the other axes surfaced. A balance table with five parallel rows of equally-weighted counter-arguments is a symptom of parallel attack — if that happens, go back to §2 CCT and locate the actual load-bearing part before writing the table.

If §2.5 returned `off-project`, the balance table should be one row: the challenge, the off-project verdict, and a one-sentence note on what *would* be material to the user's actual project. Don't pad the output to look thorough.

---

## Tone

- Sharp but not hostile. Think "sparring partner", not "hater".
- Sharp but not reactive. Challenging for the sake of challenging is false work.
- Use humor where it lands naturally. Don't force it.
- The goal is better thinking, not winning the argument.
- If the original claim survives devil, it comes out stronger. That's a good outcome.
- If the challenge is off-project, naming it as such is a better service than burying it under parallel rigor.

---

## Auto-suggestion

Don't activate automatically. Suggest once when trigger conditions are met — and wait for the user to invoke. This is different from inspect, which **fires automatically** once its triggers surface: devil targets reasoning (the user's judgment), not code, so the user must actively opt in to having their thinking challenged. See §Design rationale for why.

Triggers are System 1 discovery signals for devil, analogous to inspect's triggers — cheap patterns that surface the need for deeper examination. When a trigger fires, the *cost* of devil (re-examining your own reasoning, risking being wrong) is not automatically worth paying; the user decides when it is.

### Trigger conditions

| Category | Signal |
|----------|--------|
| **High confidence on thin evidence** | A strong conclusion drawn from limited/single-source data |
| **Irreversible decision** | Investment entry/exit, architecture commitment, contract/agreement, public statement |
| **Single narrative** | Only one explanation considered, no alternatives explored |
| **Emotional momentum** | Excitement or frustration driving the conclusion faster than evidence warrants |
| **Pattern matching without verification** | "This is just like X" without checking if it actually is |

### Suggestion format

One line:

```
[sonmat] {what was detected}. /devil?
```

Examples:
- `[sonmat] Single interpretation, high confidence. /devil?`
- `[sonmat] Irreversible decision ahead. /devil?`
- `[sonmat] Pattern match without counter-evidence. /devil?`

### Scope

- User accepts -> devil activates for the current claim/decision only
- After balance table is delivered -> devil deactivates
- Don't re-suggest for the same topic after user declines

---

## What devil does NOT do

- **Code review** — that's guard/inspect territory
- **Block actions** — devil challenges, never prevents. User decides.
- **Argue indefinitely** — one round of counter-arguments per activation. User can re-invoke for another round.
- **Pretend neutrality** — if the original claim is actually solid, say so. "Devil found nothing fatal" is a valid outcome.

---

## Design rationale

guard protects code. inspect protects systems. witness protects intent fidelity. punch protects completeness. scribe protects memory. **devil protects thinking.**

The most expensive bugs aren't in code — they're in the reasoning that led to the code (or the investment, or the architecture, or the strategy). Devil is the missing verification layer for judgment calls.

**Discovery-led alignment**: devil follows the same active-discovery-then-depth principle as the five verification traditions (surgical Time Out, aviation CRM, mindfulness noting, chess CCT, pre-mortem). Parallel attack on all three axes is the false-depth failure mode — it burns attention uniformly without knowing where the claim is thin. The CCT discovery step locates the load-bearing part first; depth then flows to that axis automatically. Claims that survive CCT without a single crux are genuinely robust, and devil says so rather than manufacturing counter-arguments for form's sake.

**Project-relevance gate (§2.5) — why a second filter after CCT**: CCT locates the load-bearing part *within the claim*. But a claim can have a perfectly identifiable crux that nevertheless **doesn't matter for the user's current project**. Without a second filter, devil can correctly find a logical weakness and still waste the user's attention — surfacing rigor that doesn't change any decision. Reactive contradiction (challenge for challenge's sake) is the failure mode observed in practice: devil producing technically valid counter-arguments that are tangential to what the user is actually doing. The §2.5 gate asks "does this crux affect stakes, amendment cost, or next action?" and provides an honest `off-project` exit. Calibrating depth to stakes and staying silent when the challenge is misdirected is the service, not a weakening.

**User agency — why devil is opt-in while inspect fires automatically**:

Inspect operates on code and systems. Its triggers (file counts, infra paths, auth touch) fire on objective patterns, and the depth that follows is a check on what the code will do — the user's agency is not on the line, the artifact is. Automatic firing is the right default: the user does not *own* the code's correctness in a personal way, so having the depth pass run without permission is welcome.

Devil operates on the user's reasoning. Its triggers (high confidence on thin evidence, irreversible decisions, single narrative) fire on the user's judgment, and the counter-arguments that follow are a challenge to the user's thinking. The user *owns* their reasoning — it is not an external artifact they can hand over to automatic critique without consent. Automatic activation here would feel intrusive and would train the user to tune devil out. Manual activation after suggestion preserves agency: the suggestion lowers the chance of unchecked confidence, the manual step affirms the user's readiness to engage with a challenge.

This asymmetry is not inconsistency. It is two different axes (code vs reasoning) with two different ownership contracts.
