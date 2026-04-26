# 2026-04-26 — Spec evolution loop (T2-C, AAR-only, metric deferred)

## Context

ADR `2026-04-26-spec-auto-reference.md` (T2-B) 가 spec 자동 참조·검증 3단계 도입. 본 ADR은 그 위에 **임기응변 발생 시 spec 갱신 흐름**을 박는다.

기존 메커니즘:
- v0.11.0 `discipline/core.md` After Acting #4 (spec-gap AAR) — 임기응변 발생 시 scribe Novel Trap `spec_gap` flavor로 dispatch
- v0.11.0 `skills/scribe/SKILL.md` Novel Trap dual flavor — `verification_failure` + `spec_gap` 양쪽 수용
- v0.12.0 `discipline/hints.md` Amend via successor — RFC `Updates:`/`Obsoletes:` 모델, in-place edit 지양

빠진 것: **spec_gap dispatch 후 무엇이 일어나는가**. 현재는 trap memory로 승격까지만. 사용자 프로젝트의 spec 문서 자체가 갱신되는 흐름은 부재.

Phase 3 architecture-methodology 연구의 직접 매핑:
- **A4 Last Planner System 5 conversations** — should / can / will / did / **learn**
- **A4 PPC (Percent Plan Complete)** — planning reliability metric
- **A5 Change Order G701 + CCD G714** — formal scope/cost/time amendment ritual

devil 정제 결과 (counter strength: **Strong**, verdict: **Needs revision**):

> "PPC sw 등가 metric은 이미 sw에서 시도(velocity) 실패. sonmat이 다른 결과 낼 근거 약함."

→ **metric 부분 분리 보류, AAR 흐름만 우선 진행**.

질문: spec_gap 발생 시 spec 갱신 흐름을 어디까지 자동화하고, 어디서 사용자 confirmation 거치고, metric 측정은 어떻게 분리 보류하나.

## Decision

**AAR-driven amendment 의례를 도입하되 metric은 본 ADR 범위 밖으로 분리**한다.

### AAR-driven amendment 의례

#### 1. spec_gap 감지 (기존 v0.11.0 작동)

worker가 작업 중 임기응변 — spec/discipline 밖 행동 — 발생 시 After Acting #4가 자동 trigger. scribe Novel Trap `spec_gap` flavor dispatch.

#### 2. AAR 단계 (신규)

scribe novel trap 처리 시 **spec_gap flavor 한정** 추가 단계:

```
1. Pattern 추출: 무엇이 spec 밖이었나
2. Catch-signal: 어떤 spec 조항이 있었으면 미리 잡았을까
3. Amendment 후보 작성: 기존 spec에 어떻게 supersede·update할지 draft (RFC Updates:/Obsoletes: 메타 모델)
4. 사용자 confirmation 제시:
   💡 Spec gap detected: {pattern}
      Propose amendment to {existing-spec-id}?
      [Yes — generate successor spec / No — log only / Edit first]
```

`Yes` 선택 시: scribe가 후속 spec 파일 생성 (T2-A 권고 구조 따름) — `supersedes:` 메타로 원 spec 참조, in-place 수정 안 함. 원 spec status를 `superseded-by:` 추가하여 cross-reference.

`No log only`: trap_*.md memory에만 기록 (기존 동작). spec 갱신 없음.

`Edit first`: 사용자가 amendment draft 수정 후 작성.

#### 3. AAR LEARN 보존 (A4 LPS 5번째 conversation 정합)

amendment 작성·거절 양쪽 결과를 scribe `journal.md`에 LEARN 항목으로 append. 미래 retrospective 자료.

```markdown
## YYYY-MM-DD [hostname] — Spec gap AAR
- Trigger: {what was outside spec}
- Catch-signal: {what spec clause would have caught it}
- Decision: {amendment generated SPEC-XXX | log only | edited then generated}
- Reasoning: {1-line justification}
```

### Stage 진입 조건 (T2-B 정합)

본 ADR의 amendment 흐름은 **T2-B Stage 1 이상**에서만 작동 — `docs/specs/_index.md` 에 `sonmat.spec_awareness: enabled` 명시한 프로젝트 한정. Stage 0(default) 프로젝트는 spec_gap dispatch가 trap memory까지만 (기존 v0.11.0 동작).

### Metric 부분 분리 보류

다음 결정은 **본 ADR 범위 밖** — devil 정제 채택:

- spec_gap 발생 빈도 측정 (PPC 등가 candidate)
- 같은 spec 영역에서 반복 spec_gap 감지 (Goodhart's law 위험)
- amendment 채택률 측정 (Yes/No/Edit first 분포)

**metric 도입은 별도 ADR**로 분리. 사유:
- velocity·story-point 같은 sw metric의 실패 사례 (gaming, 측정이 행동 왜곡)
- AAR 흐름 자체가 작동하는지 먼저 검증
- metric 없이 정성적 사용자 retrospective로 충분할 가능성 (Phase 1 Toyota A3 정신: 측정보다 대화)

metric 도입 trigger: AAR 흐름 활성 사용자 6개월 이상 운용 후, 정성 retrospective에서 정량 도구 필요 surface 시.

### 사용자 confirmation 의례 강제

본 ADR 도입 후에도 **자동 spec 갱신은 0**. 모든 amendment는 사용자 confirmation 후. 사유:
- T2-B Strong counter (substrate 부재 시 false positive)와 정합
- spec은 권위 문서 — 사용자 명시 의지 없는 자동 변경은 권위 자체 침식
- scribe synchronous 의례 (project rule recording 동일 패턴) 정합

### Closure ceremony 자동 트리거 (v0.12.0 hints 정합)

amendment가 기존 spec을 fully supersede 시:
- 원 spec `status: archived` + `superseded-by:` 메타 자동 추가 제안
- sunset date 명시 권유 (PEP 404 모델, hints.md v0.12.0 항목)
- 사용자 confirmation 후 적용

## Consequences

### 긍정적

- **devil Strong counter 채택**: PPC 등가 metric 보류로 sw velocity 실패 패턴 회피
- **AAR 흐름만으로도 Q1 부분 답**: 임기응변 → 사용자 confirmation → spec 갱신이 흐름. spec이 사용자 작업과 함께 진화
- **A4 LPS 5 conversation 정합**: should/can/will/did/learn 중 LEARN 항목이 sonmat 측 명시 의례화
- **Closure ceremony 자동화**: amendment 시 원 spec archive 자동 제안 — zombie spec 차단 (hints.md v0.12.0 정합)
- **Stage 게이팅**: T2-B Stage 1 이상에서만 작동 — substrate 없는 프로젝트엔 영향 0
- **사용자 confirmation 강제**: scribe synchronous 의례 패턴 재사용 — 권위 문서 자동 변경 차단

### 부정적·리스크

- **AAR 흐름 작동성 미검증**: 첫 사용자가 도입할 때까지 실효성 알 수 없음
- **사용자 confirmation 부담**: 매 spec_gap마다 confirmation prompt 발생 시 사용자 피로 가능
- **amendment quality 불균질**: scribe가 생성하는 amendment draft 품질이 사용자 spec 품질에 종속
- **metric 부재로 추적 어려움**: amendment 흐름이 작동하는지 정량적으로 알 수 없음 — 정성 retrospective 의존
- **`docs/specs/` 디렉토리 의존**: T2-A 권고가 채택 안 된 프로젝트엔 amendment가 들어갈 곳 없음

### 트레이드오프 검증 시점

- 첫 spec_gap → amendment 흐름 발생 시 — 의례 작동성
- 6개월 후 amendment 채택 분포 — Yes/No/Edit first 비율
- 사용자 retrospective에서 metric 필요성 surface 시 — 별도 ADR trigger
- closure ceremony 자동 트리거의 false positive 측정 (premature archive 사례)

## 후속 ADR 후보

- `2026-XX-XX-spec-amendment-metric.md` — AAR 흐름 6개월 운용 후 metric 도입 결정 (PPC 등가)
- `2026-XX-XX-amendment-quality-baseline.md` — scribe 생성 amendment draft 품질 측정 (T2-B baseline 메트릭과 통합 가능)

## 참조

- `2026-04-26-spec-auto-reference.md` (T2-B) — 본 ADR의 직속 상위 (Stage 1 게이팅)
- `2026-04-26-project-spec-structure.md` (T2-A) — `docs/specs/` 권고 (amendment 위치)
- `2026-04-25-hunsugun-scribe-seam.md` — scribe synchronous 의례 패턴 정합
- `discipline/core.md` v0.11.0 After Acting #4 — spec-gap AAR trigger
- `skills/scribe/SKILL.md` v0.11.0 Novel Trap dual flavor — spec_gap flavor 처리 본체
- `discipline/hints.md` v0.12.0 — Amend via successor / Closure ceremony 정합
- `docs/research/architecture-methodology-and-spec-discipline.md` — A4 LPS 5 conversation, A5 Change Order 의례 근거
