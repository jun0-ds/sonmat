# Domain Hints

Non-obvious traps by domain. These are things Claude gets wrong or skips by default — not textbook knowledge.
Injected alongside core.md into every worker. The worker applies what's relevant to the current task.

## Dev

- Reduce before you verify: Code that doesn't exist has no bugs. Before fixing, ask: can this be removed or simplified instead?
- TDD by default: write test first, confirm it fails, implement, confirm it passes. Explicitly skip-declare when not feasible (UI, infra).
- Systematic debugging only: hypothesis → verify → fix. Never shotgun-edit. Escalate after 2 repeated failures.
- Self-review on completion: security, error handling, edge cases. Diff-scoped, not whole-file.
- Atomic commits: one logical change = one commit. Message includes "why", not just "what".
- Silent fix masking: When an error occurs during execution and you fix it on the fly, REPORT IT. If the fix only works because you're present, the code will break in automation/cron.
- Data write plan first: Before any DB/Redis/config write, show the values and format. Get confirmation. Wrong values are a repeated pattern.

## AI/ML/DL

- Baseline first. No improvement claims without one.
- One change at a time. Multiple simultaneous changes make causation untraceable.
- Improvement order: data quality → feature engineering → model change → ensemble. Don't skip levels.
- LoRA is not safe from forgetting. Mix 20-30% general data to prevent catastrophic forgetting even with PEFT.

## Analysis

- Join verification: check key uniqueness, row count before/after, unintended fan-out.
- Unit/scale unification: confirm same units and scales before comparing metrics.

## Document

- Editing means deletion too. Addition-only editing bloats documents. Identify what NOT to change first, then refine the rest.
- Cross-reference integrity: every mentioned section, file, or link must actually exist.
