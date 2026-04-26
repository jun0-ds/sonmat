# 2026-04-26 — Witness extension to spec ↔ artifact comparison (Stage 2)

## Context

ADR `2026-04-26-spec-auto-reference.md` (T2-B) Stage 2 진입 시 두 작용 명시:
- witness가 spec ↔ artifact 비교 (현재 user turn ↔ artifact)
- guard가 spec과 명백 충돌하는 capability 사용 시 추가 confirmation gate

본 ADR은 첫 작용. guard 측은 자매 ADR `2026-04-26-guard-spec-gate.md`.

현재 witness (`agents/sonmat-witness.md` + skills/witness 영역, sonmat v0.13.0):
- protocol-isolated intent-artifact comparator
- 입력: 원 user turn + artifact만
- 출력: PASS / WARN / BLOCK verdict
- 3 scope (commit / session forest / principle coverage)
- isolation 보호: bridge-note·journal 등 scribe-managed 파일 입력 금지 (scribe SKILL.md §Isolation boundaries)

확장 방향: **published spec의 contract 조항을 witness 입력에 추가**. 그러면 user turn이 생략·모호한 부분도 spec이 지정한 contract를 기준으로 verdict 가능.

ADR `2026-04-25-hunsugun-witness-seam.md`와 정합: 시간 척도 분기 (witness sub-second, 훈수꾼 task/session) 그대로 유지. 본 ADR은 witness 자체 입력 확장만, 훈수꾼과 무관.

질문: spec을 witness 입력에 어떻게 안전하게 추가하나, isolation 깨지지 않게.

## Decision

**Stage 2 사용자 한정으로 witness 입력에 published spec 추가**한다. 4 원칙으로 isolation 보호.

### 입력 확장 contract

Stage 2 활성 (T2-B 정합 — `sonmat.spec_verification: enabled` + baseline 통과) 시 witness dispatch payload에 추가:

```
witness 입력:
- 원 user turn (기존)
- 변경 artifact (기존)
- 관련 published spec 본문 (신규 — Stage 2 한정)
- 관련 spec ID + status frontmatter (신규)
```

"관련 spec" 식별:
- 해당 task 시작 시 worker가 inline-reference한 spec (hints.md v0.13.0 Spec consumption Stage 1 의례 산출물)
- 또는 사용자가 명시 지정한 spec ID

### 4 원칙 — isolation 보호

#### P1. published spec만 입력 — draft 입력 금지

`status: draft` spec은 witness 입력에 포함 안 함. draft는 권위 미확립이고 사용자가 변경 중일 수 있음. witness가 draft를 contract로 다루면 false-positive 폭주.

#### P2. spec 본문이 main 컨텍스트로 흐르지 않게 격리

scribe SKILL.md §Isolation boundaries 정신 정합: witness가 spec을 읽었어도, witness verdict가 main에 돌아갈 때 **spec 본문은 인용 안 함**. verdict + verdict가 어느 spec 조항 위반·준수인지 ID 참조만.

이는 witness isolation을 깨지 않으면서 spec 조항을 검증 기준으로 활용하는 방식.

#### P3. spec 변경 추적 — verdict가 spec 갱신 trigger 안 함

witness가 spec과 충돌 발견 시 자동으로 spec 갱신 안 함. spec 갱신은 T2-C scribe amendment ritual 영역. witness는 verdict만 발행. spec 갱신 여부는 사용자 결정.

#### P4. multi-spec 충돌 처리

artifact가 여러 spec 영역에 걸칠 때 (예: A spec MUST이고 B spec MAY인 동작) — A201 §1.2.1 Document Hierarchy 정합:
- contract 명시 spec(behavior 강제)이 mechanism 명시 spec(implementation 안내)보다 우선
- 같은 강제력일 때 사용자에게 "이 두 spec이 충돌, 어느 것 우선?" 질문 (RFI 형식)
- 자동 우선순위 결정 안 함

### Verdict 형식 확장

기존 PASS / WARN / BLOCK + 신규 spec-related sub-tag:

| Verdict | spec sub-tag | 의미 |
|---------|-------------|------|
| PASS | `spec-aligned` | spec contract 충족 |
| PASS | `spec-extends` | spec 미명시 영역에 합리적 default |
| WARN | `spec-mechanism-mismatch` | 동일 contract 다른 mechanism (Auftragstaktik intent vs mechanism — hints.md v0.12.0 정합) |
| WARN | `spec-ambiguity` | spec이 이 case에 모호. RFI 후보 |
| BLOCK | `spec-contract-violation` | 명시 contract 명백 위반 |
| BLOCK | `spec-deprecated-active` | `status: archived` spec을 새 코드가 의존 |

`mechanism-mismatch`는 WARN — Auftragstaktik 정신 따라 mechanism 자유. contract만 violation 시 BLOCK candidate.

### Stage 2 진입 강제 안 함

Stage 2 활성은 사용자 명시 opt-in (T2-B 정합). 본 ADR 자체는 *witness 확장 가능 메커니즘 정의*만. 자동 진입 0.

## Consequences

### 긍정적

- **Q1 강한 답**: Stage 2에서 spec contract 명시 위반 BLOCK — "스펙 자동 실행" 부분 yes
- **isolation 보호**: 4 원칙으로 witness verdict 채널이 spec 본문을 main에 누출시키지 않음
- **A201 §1.2.1 정합**: multi-spec 충돌이 contract vs mechanism으로 분리 — 건축 doctrine 직접 차용
- **하위 호환**: Stage 0·1 사용자에게 변경 0
- **subagent로 격리 강화**: spec 본문이 witness 컨텍스트에만 머물고 main에 안 흐름

### 부정적·리스크

- **witness 컨텍스트 비용 ↑**: spec 본문 추가로 witness LLM 호출 토큰 증가. budget 부담
- **draft → published 전환 시점 모호**: 사용자가 spec status 갱신 의례 빠뜨리면 witness가 draft를 published로 오판 위험. T2-A frontmatter 의례에 의존
- **mechanism vs contract 자동 판별 어려움**: spec이 "calls function X"라 쓰면 contract인지 mechanism인지 worker가 매번 판단 — 임의성 높음. hints.md v0.12.0 Intent vs mechanism hint가 작성자에 떠넘김
- **spec 본문 추적 비용**: 어느 spec이 어느 task에 관련인지 계산 비용 — Stage 1에서 inline reference 정확도 70% 임계가 의미 있는 이유

### 트레이드오프 검증 시점

- 첫 Stage 2 활성 사용자 등장 시 — 4 원칙 작동성
- 1년 후 verdict sub-tag 분포 — `spec-mechanism-mismatch` 비율이 너무 높으면 Auftragstaktik 의례 작동 검증 필요
- isolation 위반 사례 발생 시 — P2 강화 필요

## 후속 ADR 후보

- `2026-XX-XX-witness-budget-management.md` — Stage 2 witness 토큰 비용 거버넌스
- `2026-XX-XX-spec-relevance-scoring.md` — task ↔ spec 관련성 자동 판별 알고리즘 (Stage 1 inline reference 정확도 향상)

## 참조

- `2026-04-26-spec-auto-reference.md` (T2-B) — 본 ADR의 직속 상위 (Stage 2 entry)
- `2026-04-26-substrate-baseline-automation.md` — Stage 2 진입 자격 측정 의례
- `2026-04-26-guard-spec-gate.md` — 자매 ADR (Stage 2 guard 확장)
- `2026-04-25-hunsugun-witness-seam.md` — witness ↔ 훈수꾼 시간 척도 분기 (본 ADR과 직교)
- `skills/scribe/SKILL.md` §Isolation boundaries — witness isolation 원본 doctrine
- `discipline/hints.md` v0.13.0 Spec consumption — Stage 1 inline reference 의례 (witness 입력 식별 자료)
- `docs/research/architecture-methodology-and-spec-discipline.md` A5 Document Hierarchy A201 §1.2.1 — multi-spec 충돌 resolution 근거
