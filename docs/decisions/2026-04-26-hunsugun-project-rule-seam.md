# 2026-04-26 — 훈수꾼 ↔ sonmat project rule recording seam

## Context

ADR `2026-04-25-hunsugun-positioning.md` D5 네 번째 (마지막) seam. sonmat scribe `Project Rule Recording` (SKILL.md §) 영역과 훈수꾼 telemetry / project-level pattern 영역이 직접 겹친다.

scribe project rule:
- 사용자 직접 명시 ("이 프로젝트에서는 항상 X")
- 반복 교정 (같은 fix 2+ 회)
- 구조 추론 (config·test·naming pattern)
→ 사용자 confirmation → CLAUDE.md 작성

훈수꾼 project-level (정체성 §0 매트릭스 project 행):
- scribe project rule recording (sonmat 측)
- OpenRabbit L2 asset reuse pipeline (사업 측)
- scribe registry + ADR feed (도구 측)

훈수꾼 정체성 §3.17 telemetry feedback도 project-level outcome tracking 영역.

질문: 두 시스템의 project-level 기록이 어떻게 분기·협업하는가.

## Decision

**scribe는 단일 프로젝트 rule, 훈수꾼은 cross-project pattern**. 시간·범위 척도로 분기.

### 분기

| 차원 | sonmat scribe project rule | 훈수꾼 cross-project telemetry |
|------|--------------------------|-------------------------------|
| 범위 | 단일 프로젝트 | 여러 프로젝트 가로지름 |
| 출력 위치 | 프로젝트 `CLAUDE.md` `## Project Rules` 섹션 | 훈수꾼 자체 telemetry artifact (별도 위치) |
| 권한 | 사용자 confirmation 후 작성 | 자기 telemetry 자유 작성 (READ-only main) |
| trigger | 직접 명시 / 반복 교정 / 구조 추론 (3 신호) | 모든 advisory outcome tracking |
| 쓰임 | 다음 세션 main이 자동 로드 | 훈수꾼 자기 학습 + 사용자 retrospective |

### 단방향 흐름 (훈수꾼 → scribe)

훈수꾼이 cross-project pattern 발견 시:
- 단일 프로젝트 적용 가치 있으면 → 사용자 confirmation 의례 거쳐 scribe project rule로 dispatch
- 여러 프로젝트 적용 가치 있으면 → sonmat memory `~/.claude/sonmat/memory/` 또는 글로벌 CLAUDE.md 후보로 사용자에게 surface

이 흐름은 scribe gatekeeper protocol 정합 (project rule 작성은 scribe synchronous 의례 거침).

### 단방향 흐름 (scribe → 훈수꾼 — 보류)

scribe → 훈수꾼은 ADR `2026-04-26-hunsugun-scribe-seam.md` 와 동일 보류 결정. 훈수꾼이 별도 인스턴스라 scribe-managed CLAUDE.md 직접 읽으면 main 컨텍스트 일부 흡수.

대안: 훈수꾼이 **외부에서 프로젝트 CLAUDE.md를 읽는 것**은 허용 (프로젝트 정체성 자체 파악) — 단 그 CLAUDE.md는 scribe가 작성한 것이지 main 컨텍스트가 아니므로 isolation 깨지 않음.

### Cross-project pattern의 회수 가능성

훈수꾼이 발견한 cross-project pattern 중 **OpenRabbit L2 자산화 가치 있는 것**은 회수 파이프라인(`recovery-pipeline` ADR S1 detect 단계) 후보:
- 훈수꾼 telemetry → OpenRabbit 사내 회수 후보 backlog
- ADR `recovery-pipeline` S1~S5 절차 통과
- 회수 거절 시 거절 ADR (Brooks ledger of refusal)

이 흐름은 훈수꾼 → OpenRabbit (사용자 매개), sonmat scribe와 별도.

### 합병 거절

scribe project rule과 훈수꾼 telemetry 합병 거절. 이유:
- scribe는 단일 프로젝트 rule 영구 박힘 — CLAUDE.md 작성 권한 가짐
- 훈수꾼은 cross-project 관찰 — 영구 박힘 권한 없이 advisory만
- 합병 시 권한 모델 충돌

## Consequences

### 긍정적

- **범위 분리로 각자 강해짐**: scribe는 단일 프로젝트 깊이, 훈수꾼은 cross-project 폭
- **권한 분리**: CLAUDE.md 작성은 scribe·사용자 confirmation, telemetry는 훈수꾼 자유 — 권한 폭주 없음
- **회수 파이프라인 입력**: cross-project pattern이 OpenRabbit 회수 후보로 자연스럽게 흘러감
- **scribe gatekeeper 유지**: 훈수꾼 → scribe 흐름이 sync 의례 거침

### 부정적·리스크

- **cross-project pattern 발견 신뢰성 미검증**: 훈수꾼이 여러 프로젝트 정보 조합해 패턴 발견하는 능력이 prototype 미실증
- **사용자 confirmation 비용**: cross-project 패턴 surface → scribe dispatch 시 매번 사용자 확인 → 흐름 느려짐
- **scribe → 훈수꾼 보류로 컨텍스트 단절**: 훈수꾼이 단일 프로젝트의 CLAUDE.md project rule 모르면 advisory가 그 rule과 충돌 가능 → "외부에서 CLAUDE.md 읽기 허용" 우회로로 부분 해결, 단 의례 정착 필요

### 트레이드오프 검증 시점

- 훈수꾼 prototype 첫 구현 시 — cross-project pattern 발견 능력 측정
- 첫 회수 후보가 훈수꾼 telemetry에서 나오는 시점 — recovery-pipeline S1과 정합성
- 사용자 confirmation 의례 부담 측정 — 훈수꾼 → scribe dispatch 비율

## D5 4 ADR 완료 노트

본 ADR로 ADR `2026-04-25-hunsugun-positioning.md` D5의 4 seam 결정 모두 완료:

1. ✓ `2026-04-26-hunsugun-witness-seam.md`
2. ✓ `2026-04-26-hunsugun-scribe-seam.md`
3. ✓ `2026-04-26-hunsugun-capability-boundary.md`
4. ✓ `2026-04-26-hunsugun-project-rule-seam.md`

훈수꾼 design freeze 가능 상태 (D5 잠금 완료). prototype 구현 진입 전 다음 검토 권장:
- v0.2 28 조건 중 미해결 Open Question 8개 재방문
- single 본체 vs federation 결정 (D8 잠정)
- L1·L3 abstraction layer 구체 인터페이스

## 참조

- `2026-04-25-hunsugun-positioning.md` D5 — seam 4 영역 중 마지막
- `skills/scribe/SKILL.md` §Project Rule Recording — scribe 측 protocol
- `2026-04-26-hunsugun-{witness,scribe,capability-boundary}-seam.md` — 자매 ADR (D5 결정 묶음)
- `2026-04-26-recovery-pipeline.md` — cross-project pattern → OpenRabbit 회수 흐름
- `docs/research/hunsugun-identity.md` v0.2 §3.5 (privacy·격리), §3.17 (telemetry)
