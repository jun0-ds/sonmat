---
id: SPEC-{YYYYMMDD}-{slug}
status: draft        # draft | shared | published | archived
modal: should        # must | should | may  (default tier for clauses without explicit modal)
created: {YYYY-MM-DD}
last-updated: {YYYY-MM-DD}
supersedes:          # SPEC-... (optional, when this spec replaces a prior one)
superseded-by:       # SPEC-... (filled when this spec is itself replaced; do not edit in place — successor spec adds this back-reference)
references:
  # - {ADR id}
  # - {external standard}
---

# {Spec Title}

> Replace placeholders. Delete sections that don't apply, but don't move them — section order is part of the contract.

## Part 1 — General (intent)

- **What**: {달성 상태. 외부 관찰 가능 동작. 한 줄로.}
- **Why**: {이 spec이 존재하는 이유. 사라지면 무엇이 무너지나.}
- **Scope**: {적용 범위 — 어떤 코드/모듈/도메인에 작동}
- **Out of scope**: {명시 비적용. "이건 다른 spec이 다룸" 또는 "의도적으로 빈 공간"}
- **Stakeholders**: {이 spec에 의존하는 사람·시스템}

## Part 2 — Behavior (contract)

> Each clause SHOULD have an explicit modal (MUST / SHOULD / MAY).
> Limit MUST to interoperability or harm-prevention requirements (RFC 2119 §6 self-limiting). Do not impose method where method is not required for interop.

- {clause 1 — MUST | SHOULD | MAY}
- {clause 2 — MUST | SHOULD | MAY}
- ...

### Acceptance criteria

> Verifiable predicates. Each criterion should be checkable by code, test, or observation.

- [ ] {criterion 1 — how to verify}
- [ ] {criterion 2 — how to verify}

### Known implementations

> Per RFC 2026 spirit: ≥2 independent interoperable implementations is the maturity signal. List even if single.

- {impl 1 — code path or external system}
- {impl 2 — if any}

## Part 3 — Verification

- **Test location**: {path or external test suite}
- **Manual check (if any)**: {steps a reviewer follows}
- **Failure modes already observed**: {known traps. Link to journal/trap memory if any.}

## Rejected alternatives

> Brooks ledger of refusal / Talmud preserved minority opinion. Future re-implementers without this section will rediscover failed branches.

- **{Alt 1}** — Considered. Rejected because {reason}.
- **{Alt 2}** — Considered. Rejected because {reason}.

## Amendment log

> Do **not** edit the body of this spec for changes after `status: published`.
> Amendments come as successor specs that `supersedes:` this one (RFC `Updates:` / `Obsoletes:` model).
> This log records who/when/why amendments were proposed — not the amendments themselves.

| Date | Proposer | Type | Outcome |
|------|----------|------|---------|
| {YYYY-MM-DD} | {who} | propose successor / clarify only / withdraw | {SPEC-... | n/a} |

## Closure (only when status: archived)

> Filled when this spec is retired. Required if `status: archived`.

- **Sunset date**: {YYYY-MM-DD}
- **Successor**: {SPEC-... or "no successor — capability removed"}
- **Fork prevention**: {explicit declaration that no forked-but-active version exists. PEP 404 model.}
- **Reason for closure**: {one paragraph}
