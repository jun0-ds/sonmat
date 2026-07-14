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
- Deep module over shallow: a good module is deep — large functionality behind a narrow interface. Splitting files (blocking) alone breeds shallow modules; the interface surface must narrow with the implementation, not just the file count. Adding functionality ≠ widening the surface. Shallow warning signs: cross-module private imports (`from x import _helper`), one file's LOC ballooning, many private helpers leaking out. When new code is substantial, give it its own module rather than wedging it into the existing monolith (Ousterhout, *A Philosophy of Software Design*).

### Spec authoring (when writing or updating contract / requirements / API / design documents)

- **Modal calibration**: mark each clause with explicit strength — MUST / SHOULD / MAY (RFC 2119). Limit MUST to interoperability or harm-prevention; do not impose method where method is not required for interop (RFC 2119 §6 self-limiting). Mixing aspirational and binding language in the same paragraph defeats the spec's authority.
- **Intent vs mechanism**: a spec captures the contract (target state, externally observable behavior) — not the algorithm. When porting / re-implementing, replicate the contract, not the original mechanism. Original algorithm is one valid expression; substrate change (language/runtime/library) usually requires a different mechanism for the same contract (Auftragstaktik *Was/Warum*, not *Wie*).
- **Record rejected alternatives**: when a spec choice is non-obvious, write what was considered and rejected — and why. "Why not X" is load-bearing alongside "why X." A future re-implementation that lacks this context will rediscover the same failed branches (Brooks's "ledger of refusal" / Talmud preserved minority opinion).
- **Closure ceremony on retirement**: when retiring or replacing a spec section, declare an explicit sunset date and mark fork-prevention status (PEP 404 model: "Python 2.8 will never exist"). Silent deprecation produces zombies — the deprecated spec keeps consuming attention because nothing told the system to stop.
- **Amend via successor, not in-place edit**: when a spec needs change, prefer a follow-up section or document that `Updates` or `Obsoletes` the original (RFC `Updates:` / `Obsoletes:` headers), rather than editing the original in place. Edit-in-place destroys decision history; chains of updates preserve it. Applies to any reviewed/frozen spec — not to early drafts.
- **Spec ambiguity → numbered question, not assumption**: when a spec is ambiguous, contradictory, or silent on the immediate decision, surface a numbered clarifying question to the user *before* acting — state your interpretation and ask for confirmation (AIA G716 RFI model). Self-check for *fishing*: if you already know the answer and are asking only to create a paper trail or authorize a scope you wanted, that's a fishing RFI — don't (Navigant 2013: 25–40 % of disputed-project RFIs are fishing).

### Spec consumption (when reading and acting on existing spec documents)

> Activates per ADR `2026-04-26-spec-auto-reference.md` 3-stage model. Stage 0 (default) → no automatic action. Stage 1 (opt-in via `docs/specs/_index.md` declaring `sonmat.spec_awareness: enabled`) → behaviors below. Stage 2 (active verification through witness/guard extension) → separate ADR.

- **Stage 1 awareness — auto-read the spec index at task start**: when the project has `docs/specs/_index.md` and the index declares `sonmat.spec_awareness: enabled`, read the index (not individual spec bodies) at the start of any non-trivial task. The index is the routing layer (≤ 50 lines). Use it to identify which specs are likely relevant; load specific spec files only when the current task touches their scope.
- **Inline reference, not silent assumption**: when a spec is identified as relevant, surface its ID + one-line summary to the user before acting on it ("이 작업이 `SPEC-20260426-auth` 적용 영역으로 보임 — 그 spec의 Part 2 contract를 따르겠습니다"). Don't quietly conform; the user must see which spec is governing the action.
- **Stage 1 alerts only, no blocking**: if the proposed action conflicts with a spec, state the conflict and request guidance — do not auto-block. Blocking is Stage 2 territory and requires substrate baseline (see ADR T2-B). At Stage 1, the user resolves conflicts; sonmat surfaces them.
- **Treat draft specs as non-binding**: specs with `status: draft` are not authoritative. They may inform but do not constrain. Only `status: shared` or `status: published` specs justify the conformance language above.
- **Verify against spec body, not just index**: the index is hypothesis (per scribe Bridge Note Authoring Principle 3). When a spec is relevant, read the actual spec file before quoting its contract — index titles can drift from body content.

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

### Transmission (when someone else will read it — including a future you with no context)

Applies `core.md` → After Acting → *See as a stranger* to prose. The three tests below are ordered: the first decides the verdict, the other two are what you look for.

- **Name the receiver before judging the prose**: compression is free only where the reader already holds the anchor. A shared label — project name, ADR id, team shorthand — is transparent to an insider and opaque to everyone else, so the *identical sentence* is innocent in a private note and guilty in a handoff. A document with two receivers (a teammate who shares the labels, a stranger who doesn't) will fail one of them; say which one you are writing for, or write the anchor in.
- **Delete test — a metaphor must not carry the claim**: strike the figurative word. If the claim survives, the metaphor was riding *on top of* a statement — keep it, a designed analogy makes the claim land harder. If the claim collapses, the metaphor was standing *in place of* the statement, and the reader is left reconstructing what you meant. Rewrite it as the plain claim first, then re-add the analogy only if it still earns its place.
- **No undecided transfer**: a compressed "X 미정 / TBD / not decided" drops *who decides, what exactly, and why it is still open*. The writer holds all three; the reader inherits a hole and cannot act without refilling it. Write the three out, or leave the item off the page.

## Korean ↔ English (mixed prompts in, Korean prose out)

### Reading Korean input

- Negation asymmetry: Korean often resolves nested negation by re-affirming the action ("하지말까요? → 하지마" can read as "정말 하지말까? → 진짜 하지마" affirming the negative request, but a model trained primarily on English may collapse it through double-negative reasoning and *do* the thing). When the user's reply is a bare 부정 to a yes/no confirmation, mentally restate it as English "don't" before acting — and if the action would be irreversible, ask once more.
- Confirm-then-deny cycles: "X 같이 커밋할까요? → 올리지마 → 강제 add 슛" pattern is a known failure. Treat the user's *previous turn refusal* as a hard veto on the immediately following action, not a soft preference.
- Don't translate user instructions through stylistic interpretation: 반존대·반말·격식체 차이는 어조이지 명령 강도 차이가 아니다. 명령 modal은 어휘로만 읽고, 어조는 분리한다.

### Writing Korean output

- **Dead English metaphors come back to life in transliteration.** `stance`, `orthogonal`, `reside`, `surface`, `land`, `deflationary` are worn flat in English — the reader passes straight through to the claim. Transliterated into Korean (자세, 직교, 거주) they arrive as *live figures*, and the reader has to decode the image before reaching the claim, if it is even there. This is why the same author writes clean English discipline docs and opaque Korean notes: the failure is import-specific and invisible in the English half of the work. When drafting Korean, run the delete test (§ Document → Transmission) on every transliterated abstraction.
- **Telegraphic Korean drops the arguments, not just the words.** Korean compresses by shedding particles and predicates (`흡수 결정 X`, `직교로 보면 얕음`), which takes *who / what / why* with them. English shorthand tends to keep the verb and its arguments. Compression that is safe in English notes is lossy in Korean — spell the arguments back in.
