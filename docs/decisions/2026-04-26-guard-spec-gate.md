# 2026-04-26 — Guard extension to spec-aware capability gating (Stage 2)

## Context

ADR `2026-04-26-spec-auto-reference.md` (T2-B) Stage 2 두 작용 중 두 번째. witness 확장은 자매 ADR `2026-04-26-witness-spec-extension.md`. 본 ADR은 guard 측.

현재 guard (sonmat v0.13.0):
- 위험 capability 감지 (rm -rf, git -f, push -f 등)
- 차단 → 사용자 confirmation 요청
- pre-commit secrets 차단
- 즉시 비가역 행위 게이트

확장 방향: **published spec과 명백 contract 위반 capability 사용 시 추가 confirmation gate**.

ADR `2026-04-25-hunsugun-capability-boundary.md`와 정합: guard는 차단 권한 가짐, 훈수꾼은 audit·advisory만. 본 ADR은 guard 자체 확장이고 훈수꾼과 무관.

A5 (`docs/research/architecture-methodology-and-spec-discipline.md`) 직접 매핑:
- **A201 §3.7.4 Hidden Conditions** — pre-allocated risk for unknowns. spec과 충돌은 differing site condition 등가
- **A201 §1.2.1 Document Hierarchy** — spec이 material/quality 강제, drawings가 dimension/location

질문: guard가 spec 충돌 capability를 어떻게 식별·차단·복원하는가, false-positive 어떻게 방지하나.

## Decision

**Stage 2 사용자 한정 spec-aware gate**를 도입. Contract violation BLOCK, mechanism mismatch ALERT.

### 작동 contract

Stage 2 활성 (T2-B `sonmat.spec_verification: enabled` + baseline 통과) 시 guard가 capability 사용 직전:

1. 해당 capability가 영향 미치는 영역 식별 (예: `git push -f`는 git 영역, `rm -rf`는 fs 영역)
2. `docs/specs/_index.md`에서 해당 영역 published spec 조회
3. spec contract 조항과 capability 의도 비교
4. 충돌 type 판별:
   - **contract violation** — spec의 외부 관찰 가능 동작에 명백 위반 → BLOCK candidate (사용자 confirmation 후 진행 또는 취소)
   - **mechanism mismatch** — 같은 contract를 다른 method로 충족 가능 → ALERT only (사용자 정보 제공만, 차단 없음)
   - **draft conflict** — `status: draft` spec과 충돌 → silent (draft는 권위 미확립)
   - **archived conflict** — `status: archived` spec과 충돌 → silent OR alert (deprecated 자체이므로 위반이 정상 가능)

### 4 원칙

#### G1. Contract violation만 BLOCK candidate

`spec-contract-violation` (witness sub-tag 정합) 만 BLOCK 후보. mechanism은 자유 (Auftragstaktik 정신, hints.md v0.12.0 Intent vs mechanism 정합).

BLOCK 시 사용자 confirmation:
```
🛑 Spec contract violation detected
   Capability: {what's about to happen}
   Spec: {SPEC-id} Part 2 clause {N}: "{quote}"
   Conflict: {how the capability violates}

   Override and proceed? [Yes / No / Show spec body]
```

`Yes`: 사용자 명시 override. journal에 LEARN entry (T2-C 정합) — "이 violation을 사용자가 의도적으로 허용". scribe novel trap `spec_gap` flavor dispatch — spec 갱신 후보.

`No`: capability 취소.

`Show spec body`: spec 본문 보여주고 다시 결정 요청.

#### G2. Override 자동 화석화 차단

같은 capability + 같은 spec 충돌이 N회 (default 3회) 발생 + 매번 사용자 override 시 — guard가 묻는다:
```
이 violation pattern이 N회 발생, 매번 override됨. 
- spec이 잘못됐는가 (T2-C amendment 후보)
- 또는 이 capability가 일관 예외인가 (spec MAY 조항 추가 후보)
이를 surface합니다.
```

→ Brooks ledger of refusal 정합. 반복 override 자체가 spec 갱신 신호.

#### G3. Multi-spec 충돌 시 hierarchy

A201 §1.2.1 정합:
- 명시 hierarchy 있으면 (`docs/specs/_index.md` `precedence:` 필드) 따름
- 없으면 더 최근 published + 더 명시적 modal (MUST > SHOULD > MAY) 우선
- 같은 강제력이면 사용자에게 RFI

#### G4. 비가역 capability + spec 충돌은 즉시 BLOCK

`rm -rf`, `git push -f`, DROP DATABASE 등 비가역 capability + contract violation은 G1 BLOCK candidate가 아니라 **무조건 BLOCK** (사용자 override 없이는 진행 0). 이는 guard 기존 차단 doctrine 강화.

### Cargo-cult 차단 — substrate 부재 사용자 보호

T2-B baseline 통과 의례가 G1·G2·G3·G4 모두에 선행. baseline 미통과 사용자에겐 본 ADR 작동 0. 

기존 guard 차단 (rm -rf 등 capability-based)은 Stage 무관 작동 — 본 ADR은 *spec-aware* 추가 게이트만.

### 자매 witness 확장과의 협업

witness가 BLOCK verdict + `spec-contract-violation` sub-tag 발행 → guard가 그 verdict를 받아 capability 차단 정당화 자료로 사용. 단:
- witness verdict는 witness isolation 정합 따라 verdict + spec ID만 main 노출 (본문 인용 안 함)
- guard는 그 verdict 기반으로 사용자 confirmation 요청
- guard는 witness verdict 자체를 다시 main 컨텍스트에 흘리지 않음 (isolation 유지)

## Consequences

### 긍정적

- **Q1 강한 답 (guard 측)**: contract violation 자동 BLOCK candidate — "스펙 자동 실행" guard 측 부분 yes
- **A201 §3.7.4 Hidden Conditions 정합**: spec 충돌이 사전 할당 risk (contract violation 사용자 책임 vs mechanism 차이 sonmat 책임)
- **Override 화석화 차단**: G2가 spec 부실을 surface — 반복 override가 곧 spec 갱신 trigger
- **G4 비가역 강제**: rm -rf 등은 spec 충돌 시 무조건 차단 — 영웅님 사례 (force add 슛) 직격
- **하위 호환**: Stage 0·1 사용자에게 guard 동작 변경 0

### 부정적·리스크

- **False BLOCK 비용**: spec 표현이 모호한데 guard가 contract violation으로 판정 시 사용자 작업 마비. baseline 통과 메트릭이 이 위험 줄이지만 0 아님
- **spec contract 자동 판별 어려움**: 본 ADR은 worker가 spec 조항이 contract인지 mechanism인지 자동 판별 가정 — 첫 운용에서 임의성 높을 것
- **Override fatigue**: G1 confirmation 의례가 자주 발생하면 사용자 reflex로 Yes 누르기 → guard 무력화. G2 화석화 차단이 부분 완화하나 임계 N=3 임의
- **G3 multi-spec hierarchy 미명시 사용자**: `precedence:` 필드를 사용자가 안 쓰면 guard가 임의 우선순위 결정 — 일관성 ↓
- **witness ↔ guard 통신 비용**: 매 capability마다 witness verdict 호출 시 budget 폭주. sampling·캐싱 의례 별도 결정 필요

### 트레이드오프 검증 시점

- 첫 Stage 2 활성 사용자 등장 시 — G1·G2·G3·G4 작동성
- 6개월 후 false BLOCK 비율 — baseline 메트릭 보정 필요성
- Override 화석화 패턴 (G2) 발생 시 — N=3 임계 적합성
- multi-spec 환경 (≥ 5 spec) 사용자 등장 시 — G3 hierarchy 작동

## 후속 ADR 후보

- `2026-XX-XX-witness-guard-budget.md` — Stage 2 witness·guard 협업 비용 거버넌스 (sampling, 캐싱)
- `2026-XX-XX-spec-precedence-doctrine.md` — `precedence:` 필드 명시 의례 + 자동 hierarchy 알고리즘

## 참조

- `2026-04-26-spec-auto-reference.md` (T2-B) — 본 ADR의 직속 상위
- `2026-04-26-witness-spec-extension.md` — 자매 ADR (Stage 2 witness 확장)
- `2026-04-26-substrate-baseline-automation.md` — Stage 2 진입 자격 측정 의례
- `2026-04-25-hunsugun-capability-boundary.md` — guard ↔ 훈수꾼 권한 분리 (본 ADR과 직교)
- `discipline/hints.md` v0.12.0 Intent vs mechanism — G1 mechanism mismatch 처리 근거
- `docs/research/architecture-methodology-and-spec-discipline.md` A5 — A201 §3.7.4 Hidden Conditions, §1.2.1 Document Hierarchy
- 단톡 인사이트 (Phase 2 통합 패턴 #14) — 영웅님 git -f force add 사례 (G4 직접 적용)
