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
- Isolate in a worktree when it pays off: parallel features, long-running refactors, or reversible-risk experiments — dispatch via `Agent({isolation: "worktree"})`. Skip for L0 single-file edits, read-only exploration, or when already inside a worktree.

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

## Korean ↔ English mixed prompts

- Negation asymmetry: Korean often resolves nested negation by re-affirming the action ("하지말까요? → 하지마" can read as "정말 하지말까? → 진짜 하지마" affirming the negative request, but a model trained primarily on English may collapse it through double-negative reasoning and *do* the thing). When the user's reply is a bare 부정 to a yes/no confirmation, mentally restate it as English "don't" before acting — and if the action would be irreversible, ask once more.
- Confirm-then-deny cycles: "X 같이 커밋할까요? → 올리지마 → 강제 add 슛" pattern is a known failure. Treat the user's *previous turn refusal* as a hard veto on the immediately following action, not a soft preference.
- Don't translate user instructions through stylistic interpretation: 반존대·반말·격식체 차이는 어조이지 명령 강도 차이가 아니다. 명령 modal은 어휘로만 읽고, 어조는 분리한다.
