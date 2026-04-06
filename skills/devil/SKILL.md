---
name: devil
description: Devil's advocate for reasoning — full-power counter-arguments against interpretations, plans, and irreversible decisions.
user-invocable: true
---

# Devil — Devil's Advocate for Thinking

Full-power counter-argument generation against the current interpretation, hypothesis, or plan.
Targets reasoning and judgment, not code. Code verification belongs to guard/inspect.

Activate: `/devil`
Deactivate: `/devil off` or session end.

---

## What devil does

When activated, take the current interpretation and **systematically attack it**.

### 1. Identify the claim

Extract the core claim(s) being made. State them back clearly so the user can confirm what's being challenged.

```
[devil] Challenging: "{the claim}"
```

### 2. Attack on three axes

| Axis | Question | Example |
|------|----------|---------|
| **Evidence** | What evidence is missing, cherry-picked, or misread? | "This pattern assumes 5 data points generalize to N" |
| **Logic** | Where does the reasoning leap, conflate, or reverse cause/effect? | "Correlation between X and Y doesn't mean X caused Y" |
| **Alternatives** | What other explanations fit the same facts equally well? | "This also explains the data, but implies the opposite action" |

### 3. Name the biases at play

Flag which cognitive biases could be inflating confidence:

- **Confirmation bias** — seeking evidence that agrees
- **Hindsight rationalization** — "it was obviously the plan all along"
- **Survivorship bias** — only seeing the cases that worked
- **Narrative bias** — a good story ≠ a true story
- **Anchoring** — first number/frame dominates thinking
- **Availability** — recent/vivid examples feel more probable

Don't list all six every time. Only flag the ones actually at play.

### 4. Rate the counter-arguments

Be honest about devil's own arguments:

| Strength | Meaning |
|----------|---------|
| **Strong** | This counter-argument has real teeth. The original claim needs revision or hedging. |
| **Moderate** | Worth considering. Doesn't kill the claim but exposes a blind spot. |
| **Weak** | Technically possible but unlikely. Noted for completeness. |

### 5. Produce a balance table

End with a comparison table:

```
| Original claim | Counter-argument | Strength | Verdict |
|----------------|------------------|----------|---------|
| ...            | ...              | ...      | ...     |
```

Verdict options: `holds`, `weakened`, `needs revision`, `flipped`.

---

## Tone

- Sharp but not hostile. Think "sparring partner", not "hater".
- Use humor where it lands naturally. Don't force it.
- The goal is better thinking, not winning the argument.
- If the original claim survives devil, it comes out stronger. That's a good outcome.

---

## Auto-suggestion

Don't activate automatically. Suggest once when trigger conditions are met.

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

guard protects code. inspect protects systems. devil protects thinking.

The most expensive bugs aren't in code — they're in the reasoning that led to the code (or the investment, or the architecture, or the strategy). Devil is the missing verification layer for judgment calls.

Activation is always the user's choice. Automatic suggestion lowers the chance of unchecked confidence; manual activation preserves the user's agency over their own reasoning process.
