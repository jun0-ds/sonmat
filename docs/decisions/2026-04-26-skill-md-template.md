# 2026-04-26 — SKILL.md template (Inputs / Process / Outputs)

## Context

ADR `2026-04-25-icm-memory-mapping.md`가 도출한 흡수 후보 4건 중 세 번째. ICM 5층 모델의 L2 Stage Contract는 정형 템플릿 사용:

```
Inputs (어디에서 무엇을 읽나)
Process (무엇을 하나)
Outputs (무엇을 어디에 남기나)
```

sonmat의 각 skill `SKILL.md`는 현재 자유 포맷. 결과적으로:
- skill마다 구조 다름 (devil은 §1~§6, scribe는 modes/dispatch protocol 등)
- 신규 skill 작성 시 기존 skill 참조 부담
- worker가 SKILL.md를 읽을 때 어디에 무엇이 있는지 매번 학습

질문: 신규 SKILL.md에 ICM Inputs/Process/Outputs 템플릿을 강제할 것인가, 기존 skill은 어떻게 다룰 것인가.

## Decision

**신규 SKILL.md에 ICM 템플릿을 권장**한다. 강제는 아니다 — sonmat 현 v0.11.0 시점 6개 skill 모두 자유 포맷이고 작동 중이므로 일괄 강제는 부담.

### 신규 SKILL.md 권장 템플릿

```markdown
---
name: {skill-name}
description: {one-line — what this skill verifies/does}
user-invocable: {true | false}
---

# {Skill Name} — {Tagline}

## Purpose
{1-2 paragraphs: what axis this skill owns, what it doesn't}

## Inputs
{Where this skill reads from: dispatch payload, files, prior artifacts.
List with paths/sources where applicable.}

## Process
{What this skill does, ordered. Numbered steps.
Each step: verb-led, concrete, verifiable.}

## Outputs
{What this skill produces and where it goes.
List with paths/destinations.}

## Dispatch / Invocation
{When this skill is invoked (auto trigger, user command, other skill dispatch).
If user-invocable, the slash command. If not, the dispatch contract.}

## Failure modes
{What can go wrong, how to detect, how to recover.}

## Design rationale (optional)
{Why this skill exists in this shape. Reference research/decisions.}
```

### 적용 범위

- **신규 skill** — 권장 템플릿 따름. 핵심 4개 섹션(Purpose / Inputs / Process / Outputs)은 의무. Dispatch / Failure modes / Design rationale은 skill 성격에 따라 선택
- **기존 skill 6개** — 일괄 변경 안 함. 다음 메이저 수정 시 점진 정렬. 우선순위:
  1. 가장 자주 호출되는 skill부터 (guard / scribe — 자동 dispatch가 잦음)
  2. user-invocable skill 다음 (devil / inspect / punch — 사용자가 직접 SKILL.md 의식)
  3. 기타

### 명시 비강제 이유

- v0.11.0 작동 중 플러그인 보호 원칙 (ADR `l2-cognitive-architecture-positioning` D-운영 원칙)
- 기존 6 skill 작성자(준선생) 의도가 자유 포맷에 박혀있어 일괄 변경이 정체성 손상 위험
- ICM 템플릿이 모든 skill에 맞는지 미검증 — 자동 dispatch skill (scribe) vs user-invocable skill (devil)이 다른 구조 필요할 수 있음

### 검증 방법

신규 skill 1~2개 작성 시 권장 템플릿 적용해보고, 실효성 평가 후 정착·갱신·기각 결정.

## Consequences

### 긍정적

- **신규 skill 일관성**: 작성자가 매번 구조 결정 안 하고 템플릿 채움 → 작성 부담 ↓
- **worker 학습 비용 ↓**: 템플릿 학습되면 임의 skill 읽을 때 "Process 섹션 = 행동", "Outputs = 산출물 위치"로 빠르게 매핑
- **ICM 외부 정합**: skill SKILL.md가 ICM Stage Contract 형태 → 외부 표준과 호환
- **기존 skill 보호**: 일괄 변경 안 함 → v0.11.0 작동 안전성 유지

### 부정적·리스크

- **두 종류 SKILL.md 공존**: 일정 기간 신규 템플릿 vs 기존 자유 포맷 혼재. worker가 두 형태 모두 다뤄야
- **템플릿 미검증**: 신규 skill 1~2개 적용 후에야 효과 측정 가능. 그 사이 잘못된 템플릿 정착 위험 → 첫 적용 후 적극 retrospective 필요
- **자동 dispatch vs user-invocable 차이 미반영**: 현 템플릿은 둘 다 같은 구조 권장. scribe (자동) 같은 skill에선 "Dispatch / Invocation" 섹션이 본체급, devil (user-invocable)에선 "Failure modes" 가 본체급 — 템플릿이 이 차이 못 잡으면 v2 필요

### 트레이드오프 검증 시점

- 신규 skill 1개 작성 시 적용 결과 평가
- 6개월 후 신규 vs 기존 skill 사용성 비교
- ICM 자체가 다른 표준에 자리 내주는 시점에 본 ADR 재평가

## 참조

- `2026-04-25-icm-memory-mapping.md` — 본 ADR의 상위
- `2026-04-26-memory-token-budgets.md`, `2026-04-26-l3-l4-strategic-distinction.md` — 자매 ADR
- ICM (Van Clief & McDermott, arXiv 2603.16021) — Stage Contract 템플릿 원본
- 기존 6 skill: `skills/{guard,inspect,witness,punch,devil,scribe,autoloop}/SKILL.md` — 점진 정렬 대상
- 후속: `2026-XX-XX-discipline-progressive-disclosure.md` (마지막 ICM 흡수 ADR)
