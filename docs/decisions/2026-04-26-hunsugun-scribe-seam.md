# 2026-04-26 — 훈수꾼 ↔ sonmat scribe seam

## Context

ADR `2026-04-25-hunsugun-positioning.md` D5 두 번째 seam. sonmat scribe는 v0.11.0에서 bridge-note authoring 4 원리·Novel Trap dual flavor 추가. 훈수꾼 정체성 §3.16 onboarding + §3.17 telemetry feedback에서 훈수꾼도 session/project 단위 기록 의례 가짐.

scribe 영역과 훈수꾼 기록 영역이 직접 겹친다:
- scribe `bridge-note.md` — 세션 간 handoff
- scribe `journal.md` — append-only 기록
- scribe novel trap recording — 학습 자료 승격
- 훈수꾼 multi-tag memory + handoff spec (§3.15)
- 훈수꾼 advisory 이력 append-only (§3.11)

질문: 두 시스템의 기록을 분기·합병할 것인가.

## Decision

**기록 채널은 분기, 일부 데이터는 단방향 흐름**한다.

### 분기

| 차원 | sonmat scribe | 훈수꾼 기록 |
|------|--------------|-----------|
| 척도 | sub-second 발견 → 세션/프로젝트 영구화 | task/session/project 단위 advisory 기록 |
| trigger | 다른 sonmat skill (guard, autoloop)이 dispatch | 훈수꾼 자체 advisory 발행 시 |
| 출력 위치 | `.claude/sonmat/bridge-note.md`, `journal.md`, `progress.md`, `memory/trap_*.md` | 훈수꾼 자체 채널 (위치 별도 결정, sonmat 채널과 분리) |
| 권한 | 텍스트 작성·승격 권한 | 자기 advisory 작성만, sonmat 채널 작성 안 함 |
| 사용자 가시성 | bridge-note 자동 (다음 세션 main이 읽음), journal·trap on-demand | advisory 사용자 명시 호출 또는 trigger 만 |

### 단방향 흐름 (훈수꾼 → scribe)

훈수꾼이 task/session 단위로 발견한 패턴 중 **sonmat 학습 가치 있는 것**은 scribe novel trap channel로 dispatch:
- `verification_failure` 또는 `spec_gap` flavor (v0.11.0 정합)
- 훈수꾼 → 사용자 confirmation → scribe 기록 의례
- scribe의 **synchronous 의례** 사용 (사용자 확인 필수)

이 흐름은 훈수꾼 → sonmat 이지만 scribe의 기존 protocol을 따름 — scribe가 게이트키퍼 유지.

### 단방향 흐름 (scribe → 훈수꾼 — 보류)

scribe artifact를 훈수꾼이 입력으로 사용할 수 있는가? **잠정 보류**:
- bridge-note는 main 자동 입력 (scribe SKILL.md). 훈수꾼이 별도 인스턴스라 main과 다른 컨텍스트 — bridge-note 직접 읽으면 main 컨텍스트 일부 흡수
- isolation 관점에서 위험 가능

→ 본 ADR은 scribe → 훈수꾼 흐름 **보류**. 훈수꾼 prototype 구현 시 isolation 검증 후 결정.

### 합병 거절

scribe와 훈수꾼 기록 합병 거절. 이유:
- scribe는 sonmat 자기 학습 의례, 훈수꾼은 advisory 행위 자체 기록 — 다른 의도
- 합병 시 scribe의 sub-second 발견과 훈수꾼의 task-level advisory가 같은 채널에 섞여 noise

### 다른 가능성 — bridge-note 7섹션 부정 정합

준선생이 이전 세션에서 "7섹션 표준화 정말 필요한가" 의문 제기, 결과 scribe SKILL.md v0.11.0 4 원리 박힘. 훈수꾼이 같은 4 원리(status form / Traps / hypothesis / brevity)를 자기 advisory artifact 작성에 차용 — scribe에서 검증된 원리가 훈수꾼에서 재사용. 이는 두 시스템이 **다른 채널·같은 원리**.

## Consequences

### 긍정적

- **채널 분리로 noise 회피**: 다른 의도의 기록이 섞이지 않음
- **단방향 흐름이 scribe gatekeeper 유지**: 훈수꾼 → scribe 흐름이 기존 scribe synchronous 의례 통과 → 무자각 학습 차단
- **isolation 보호**: scribe → 훈수꾼 흐름 보류로 main 컨텍스트 간접 흡수 위험 차단
- **공유 원리**: bridge-note 4 원리가 훈수꾼 advisory에도 적용 — 일관성

### 부정적·리스크

- **scribe → 훈수꾼 부재로 컨텍스트 단절**: 훈수꾼이 sonmat 학습 자료 (novel trap, hints)에 접근 못 함 → 같은 패턴 두 시스템에서 독립 발견 가능
- **단방향 dispatch 의례 부담**: 훈수꾼 → scribe dispatch에 사용자 confirmation 의례 거치면 advisory 흐름 느려짐
- **두 시스템 기록이 같은 사건 두 곳에 기록**: 같은 의사결정이 scribe journal과 훈수꾼 advisory 양쪽에 기록되면 정합성 부담

### 트레이드오프 검증 시점

- 훈수꾼 prototype 첫 구현 시 — scribe → 훈수꾼 흐름 보류 결정 재평가 (isolation 검증 결과)
- 훈수꾼 → scribe novel trap dispatch 비율 측정 — 학습 가치 있는 발견이 실제 흘러가는지
- 같은 사건 양쪽 기록 부담 측정

## 참조

- `2026-04-25-hunsugun-positioning.md` D5 — seam 4 영역 중 두 번째
- `skills/scribe/SKILL.md` (v0.11.0) — Bridge Note 4 원리 + Novel Trap dual flavor
- `2026-04-26-hunsugun-witness-seam.md` — 자매 ADR (witness seam 결정 패턴 동일)
- `docs/research/hunsugun-identity.md` v0.2 §3.11 (append-only), §3.15 (multi-tag memory), §3.16 (onboarding), §3.17 (telemetry)
