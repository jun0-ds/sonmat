# 2026-04-26 — Spec auto-reference mechanism (T2-B, with substrate baseline)

## Context

ADR `2026-04-26-project-spec-structure.md` (T2-A) 가 사용자 프로젝트에 `docs/specs/` 권고 도입. 그러나 권고만으로는 Q1("스펙은 자동적으로 실행되는가?") 답이 NO 유지. spec이 권위 인식되어 자동 참조·검증·alert 되려면 **sonmat 측 메커니즘 변경 필요** — witness/guard 확장 또는 신규 hook.

Phase 3 architecture-methodology 연구의 직접 매핑:
- **A3 BIM CDE (Common Data Environment)** — Information Container 자동 참조 + LOIN(Level of Information Need) per-task 명세
- **A5 Document Hierarchy A201 §1.2.1** — spec ↔ drawings 충돌 시 resolution 룰
- **A5 Constructability Review (CII IR 34-1)** — pre-construction spec 검토 의례

devil 정제 결과 (counter strength: **Strong**, verdict: **Needs revision**):

> "spec 품질 baseline 없이 auto-reference 켜면 false positive 폭주. spec 자체가 부실하면 충돌 차단의 신뢰성 깨짐."

이는 핵심 미해결. T2-A 권고가 채택돼도 사용자가 실제 작성한 spec 품질은 **알 수 없음** — 처음부터 부실한 spec에 자동 참조 강제하면 가짜 충돌·가짜 차단으로 사용자 신뢰 파괴.

질문: spec 자동 참조를 도입하되 substrate 부재 시 카고-컬트 차단하는 단계 의례를 어떻게 박을 것인가.

## Decision

**3단계 점진 진입 모델**을 채택. 단계 통과 조건 명시. 각 단계별 sonmat 동작 변경 분리.

### 3단계 모델

#### Stage 0 — Silent observation (default)

- `docs/specs/` 존재 감지하되 sonmat 동작 변경 0
- 사용자가 직접 spec 호출 시(예: "이 spec 검토해줘") 의례 적용
- **현재 v0.12.0 + T2-A 권고 상태와 동일** — 별도 변경 없음

#### Stage 1 — Opt-in awareness

trigger: 사용자가 `docs/specs/_index.md`에 명시적 항목 추가:
```yaml
sonmat:
  spec_awareness: enabled
```

이 flag 있을 때만 Stage 1 작동:
- 작업 시작 시 `_index.md` 자동 read
- 관련 spec 후보 inline reference (강제 read 안 함, 사용자에게 surface)
- 충돌 자동 차단 안 함 (alert만)

**Substrate baseline 측정 의무**: Stage 1 진입 후 첫 30일 (또는 첫 10 task) 동안:
- spec inline reference 정확도 (spec과 실제 task 관련성)
- 사용자가 alert를 dismiss vs heeded 비율
- 명시적 spec 호출 빈도

이 baseline 데이터가 Stage 2 진입 자격 판정 자료.

#### Stage 2 — Active verification

trigger: Stage 1 baseline에서 (a) spec inline reference 정확도 > 70 %, (b) heeded ratio > 50 %, (c) 사용자가 명시 활성화 (`spec_verification: enabled`).

Stage 2 활성화 효과:
- witness가 spec ↔ artifact 비교 수행 (현재 user turn ↔ artifact)
- guard가 spec과 명백 충돌하는 capability 사용 시 추가 confirmation gate
- spec ambiguity 감지 시 RFI 형식 질문 자동 생성

Stage 2는 **사용자가 적극 opt-in 후에만**. baseline 미달 시 Stage 1 유지.

### Substrate 측정 메트릭 (open question 답)

devil 정제가 제기한 "사용자 spec 품질 baseline 어떻게 측정?"에 대한 답:

- **Spec section 분량 분포**: 평균 / median / max (분량 양극화 = 일관성 결여 신호)
- **Modal 명시율**: MUST/SHOULD/MAY 명시된 조항 / 전체 조항 비율 (RFC 2119 정합도)
- **Acceptance criteria 존재율**: Part 3 Verification 채워진 spec / 전체 spec
- **Supersession chain 정합도**: `supersedes`/`superseded-by` metadata 일관성
- **Last update 분포**: spec 평균 stale 정도 (1년 이상 갱신 없음 = 사실상 archive)

이 메트릭은 Stage 1 baseline 측정 시 자동 계산. 임계값 미달 spec 영역엔 Stage 2 진입 보류.

### 충돌 resolution 룰 (A5 A201 §1.2.1 차용)

Stage 2에서 spec ↔ 코드 충돌 감지 시:
- spec이 외부 관찰 가능 동작(contract) 명시 + 코드가 그것 위반 → BLOCK candidate (사용자 confirmation 후만 차단)
- spec이 내부 implementation 명시 + 코드가 다른 mechanism으로 같은 contract 충족 → ALERT only (Auftragstaktik intent vs mechanism 분리 정합 — hints.md v0.12.0 항목)
- spec이 "draft" status → silent (publish 안 된 spec은 권위 없음)

### sonmat 측 변경 범위

- Stage 0: 변경 없음
- Stage 1: 자동 read + alert만. **새 skill 추가 안 함** — 기존 worker에 inline reference로 작동
- Stage 2: witness·guard 행동 확장. **별도 ADR** (`2026-XX-XX-witness-spec-extension.md`, `2026-XX-XX-guard-spec-gate.md`)로 진입

## Consequences

### 긍정적

- **devil "Strong" counter 채택**: substrate baseline 측정 단계 추가로 카고-컬트 차단
- **점진 진입**: Stage 0(현재) → 1(opt-in) → 2(verified)으로 사용자 자율
- **Q1 부분 답**: Stage 2 도달 시 "스펙 자동 실행" 부분 YES (충돌 BLOCK + RFI 자동 생성)
- **substrate 메트릭 명시**: 5개 정량 지표가 Stage 진입 자격 판정 — devil open question에 답
- **A5 Document Hierarchy 정합**: spec ↔ 코드 충돌 resolution이 contract 우선·mechanism 자유 (Auftragstaktik 정신)

### 부정적·리스크

- **Stage 1 baseline 측정 자동화 미정**: 5 메트릭을 sonmat이 자동 계산할지, 사용자 수동 보고할지 본 ADR엔 없음. 별도 결정 필요 (자동이면 hook 추가, 수동이면 human-in-loop)
- **임계값 (70 %, 50 %, 30일, 10 task) 임의**: 첫 운용 후 갱신 필요
- **Stage 2 진입자 적을 가능성**: substrate 충족 사용자 적으면 Stage 2 자체가 빈 기능
- **witness·guard 확장 ADR 미작성**: 본 ADR은 entry point만, 실 변경은 후속 ADR. 작성 부담 존재
- **메트릭 자체가 cargo-cult**: "modal 명시율 70 %"이 의미 있는지 검증 안 됨 — Goodhart's law 위험

### 트레이드오프 검증 시점

- 첫 Stage 1 활성 사용자 등장 시 — baseline 측정 작동성
- baseline 30일 통과 시 — 임계값이 합리적인지
- Stage 2 진입자 발생 시 — witness·guard 확장 ADR 필요성
- 1년 후 Stage 분포 측정 — 점진 모델이 채택률 도울지 차단할지

## 후속 ADR 후보

- `2026-XX-XX-substrate-baseline-automation.md` — baseline 측정 자동화 결정 (hook vs manual)
- `2026-XX-XX-witness-spec-extension.md` — Stage 2 witness 확장 (spec ↔ artifact 비교)
- `2026-XX-XX-guard-spec-gate.md` — Stage 2 guard 확장 (spec 충돌 confirmation gate)

## 참조

- `2026-04-26-project-spec-structure.md` (T2-A) — 본 ADR의 직속 상위 (`docs/specs/` 권고)
- `2026-04-25-l2-cognitive-architecture-positioning.md` — L2 본체 운영 원칙 (작동 중 플러그인 보호)
- `docs/research/architecture-methodology-and-spec-discipline.md` — A3 BIM CDE/LOIN, A5 Document Hierarchy + Constructability 근거
- `discipline/hints.md` v0.12.0 Spec authoring — substrate 갖춘 spec 형식 정의 (Modal/Intent-Mech/Closure)
- 후속: `2026-04-26-spec-evolution-loop.md` (T2-C, AAR-only)
