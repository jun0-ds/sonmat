# 2026-04-26 — 훈수꾼 ↔ sonmat witness seam

## Context

ADR `2026-04-25-hunsugun-positioning.md` D5 (sonmat과의 seam) 4 겹침 영역 중 첫 번째. sonmat의 `witness` agent와 훈수꾼 advisory가 둘 다 "intent vs artifact 일치 검증" 영역에 작동 가능. 결정 안 하면 두 시스템이 같은 영역에서 중복하거나 충돌.

sonmat witness 현재 정체:
- sub-second 척도, sonmat 자체의 [Judge] 파이프라인 일부
- main 추론과 protocol-isolated, ground truth 기반
- intent-artifact comparator (commit / session forest / principle coverage 3 scope)
- 출력: PASS / WARN / BLOCK 마커

훈수꾼은 task/session 척도 advisor. Intent vs artifact 일치 점검은 자연스럽게 훈수꾼 영역과 겹친다 — 같은 영역의 시간 척도 다른 표현일 수 있음.

질문: 두 시스템이 겹치는 이 영역을 어떻게 분기·합병할 것인가.

## Decision

**시간 척도와 권위로 분기**한다. witness는 sub-second 검증, 훈수꾼은 task/session 검증. 같은 영역이지만 cycle이 다름.

### 분기

| 차원 | sonmat witness | 훈수꾼 advisory |
|------|--------------|----------------|
| 시간 척도 | sub-second (commit/session forest scope) | task / session level |
| trigger | autoloop [Judge] 파이프라인 자동 | session·task 단위 trigger 또는 사용자 호출 |
| 권위 | sonmat 측 — verdict (PASS/WARN/BLOCK) 발행 | advisory 만 — 구속력 없음 |
| isolation | 강 (main과 protocol-isolated) | 강 (별도 인스턴스, READ-only main) |
| 입력 | 원 user turn + artifact만 | main 컨텍스트 전체 (READ) + 자기 메모리 |
| 출력 위치 | scribe journal (witness verdict) | 훈수꾼 advisory artifact (별도 채널) |
| failure mode | BLOCK 시 sonmat 다음 단계 진행 차단 | advisory dismiss·snooze·redirect 가능 |

### 두 시스템 협업 패턴

훈수꾼은 sonmat witness의 verdict를 **참조 가능** (READ-only). 단:
- 직접 verdict를 advisory로 복사 금지 (witness isolation 정합 — scribe SKILL.md §Isolation boundaries 정신)
- "지난 세션 witness가 N번 WARN 했다" 같은 **메타 패턴** 만 advisory에 사용

sonmat witness는 훈수꾼 advisory를 **참조 안 함**. witness isolation 유지 — 훈수꾼 출력이 witness 입력으로 들어가면 isolation 깨짐.

### 같은 영역에서 다른 cycle

같은 "intent vs artifact 비교"를 다른 cycle로 중첩 가능:
- witness: 매 commit·session 단위 (autoloop 의례)
- 훈수꾼: 세션 종료 시 retrospective + 사용자 호출 시

중복 아니라 **다층 검증** — 같은 영역에서 다른 척도의 검증은 정합. 단, 중복 비용 측정 필요 (LLM 호출 budget — 훈수꾼 정체성 §3.4).

### 합병 거절

두 시스템 합병 거절. 이유:
- witness sub-second 척도가 task/session 척도로 늘어나면 isolation 비용 ↑ (긴 컨텍스트 격리 어려움)
- 훈수꾼 task/session advisor가 sub-second에서 작동하면 비용 폭주

다른 척도가 다른 시스템을 정당화. 합병하면 둘 다 망가짐.

## Consequences

### 긍정적

- **시간 척도 분기로 중복 회피**: 같은 영역이지만 다른 cycle → 책임 명확
- **isolation 정합**: 두 시스템 간 직접 입력 흐름 차단 → witness isolation 깨지지 않음
- **다층 검증 가능**: 같은 영역의 다른 시각이 false negative 차단 가능
- **합병 거절로 두 정체성 보호**: 둘 다 자기 척도에서 강해짐

### 부정적·리스크

- **비용 중복**: 같은 영역 검증이 두 척도에서 실행 → LLM 호출 ↑. 훈수꾼 정체성 §3.4 budget 거버넌스로 관리 필요
- **중복 detection 분리 책임 모호**: 같은 issue를 witness BLOCK + 훈수꾼 advisory 동시 발행 시 사용자 혼란 — 우선순위 룰 후속 결정 가치
- **메타 패턴 추출 의례 부재**: 훈수꾼이 witness verdict를 참조해 메타 패턴 생성하는 의례가 본 ADR에서 미정 — 후속

### 트레이드오프 검증 시점

- 훈수꾼 prototype 첫 구현 시 — witness verdict 참조 메커니즘이 isolation 깨지 않는지
- 두 시스템 동시 운영 시 비용 측정 — budget 거버넌스 작동성
- 같은 issue 중복 발행 사례 발생 시 — 우선순위 룰 후속 ADR

## 참조

- `2026-04-25-hunsugun-positioning.md` D5 — seam 4 영역 중 첫 번째
- `skills/scribe/SKILL.md` §Isolation boundaries — witness isolation 원칙 (정합 기반)
- `agents/sonmat-witness.md` 또는 `skills/witness/SKILL.md` — witness 정체 (sonmat 리포 내)
- `docs/research/hunsugun-identity.md` v0.2 §3.7 — 실패 모드 (graceful degradation 원칙 정합)
