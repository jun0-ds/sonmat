# 2026-04-26 — 훈수꾼 ↔ sonmat capability boundary seam

## Context

ADR `2026-04-25-hunsugun-positioning.md` D5 세 번째 seam. sonmat `guard`는 검증·차단 권한을 가짐. 훈수꾼은 D4에서 "차단 권한 0, plugin 권한 화이트리스트" 명시 — 영역은 비슷(capability boundary)하나 권한이 다름.

또한 훈수꾼 정체성 §3.1 "권한 경계":
- READ-only main 컨텍스트
- WRITE는 자기 advisory artifact만
- plugin 권한 화이트리스트

guard의 영역과 훈수꾼 audit log의 영역이 직접 겹친다. 단톡 인사이트(영웅님 git -f 사고)도 이 영역 직격 — guard·훈수꾼 어느 쪽이 막아야 하는가.

질문: capability boundary 영역에서 두 시스템이 어떻게 분기하는가.

## Decision

**guard는 차단·게이트, 훈수꾼은 audit·advisory**. 두 시스템 모두 작동, 권한이 다름.

### 분기

| 차원 | sonmat guard | 훈수꾼 audit log |
|------|-------------|----------------|
| 권한 | 차단 가능 (BLOCK 시 다음 단계 진행 차단) | 차단 권한 0 (advisory만) |
| 시점 | 행위 직전 (게이트) | 행위 후 또는 진행 중 (관찰) |
| 출력 | 차단 결정 + 사용자 승인 요청 | advisory artifact + 패턴 ledger |
| trigger | 위험 capability 감지 (rm -rf, git -f, push -f 등) | 모든 capability 사용 관찰 (sampling 가능) |
| isolation | sonmat 내부 (main과 같은 인스턴스) | 별도 인스턴스 |

### 각 시스템 전담 영역

**guard 전담**:
- L4 wrapper 채택 거절 게이트 (`l3-adapter-policy` 정합)
- 직접 위험 capability 차단 (rm -rf 등)
- pre-commit secrets 차단
- 즉시 비가역 행위 게이트

**훈수꾼 전담**:
- capability 사용 패턴의 cross-session ledger
- "지난 N 세션에서 이 capability가 M번 위험 사용됐다" 같은 메타 패턴
- 사용자 의도와 실제 capability 사용 간 drift 관찰

### 협업 패턴

guard가 차단한 사건은 **훈수꾼 ledger에도 기록** (READ-only로 guard 결정 결과 참조):
- 훈수꾼이 guard 차단 자체를 막을 수 없음
- 훈수꾼이 guard 차단을 자기 advisory에 학습 데이터로 활용 가능
- "guard가 같은 capability를 N번 차단했다" → 훈수꾼이 이걸 사용자에게 surface ("이 패턴 자주 차단되는데, hint나 default 변경 어떻습니까")

guard는 훈수꾼 advisory 받지 않음 — guard는 sub-second 게이트라 advisory 처리할 시간 없음. 훈수꾼이 guard 동작 변경 원하면 사용자 → 사용자가 guard 룰 갱신.

### 영웅님 git -f 사고 매핑

단톡에서 본 사례: ignore된 파일 강제 add. 이 상황에서:
- **guard 역할**: `git add -f` capability 자체에 추가 confirmation 게이트 ("force flag 사용. ignored 파일이 add 됨. 진행?")
- **훈수꾼 역할**: 이 패턴이 반복 시 사용자에게 "git -f 강제 옵션이 자주 사용되는데, .gitignore 검토 권합니다" advisory

guard가 즉시 막고, 훈수꾼이 패턴 학습. 둘 다 작동.

## Consequences

### 긍정적

- **권한 분리**: 차단 권한 = guard, 학습·advisory = 훈수꾼. 명확한 책임
- **다층 방어**: guard 즉시 차단 + 훈수꾼 cross-session 패턴 → false negative 차단 비율 ↑
- **단톡 인사이트 직접 매핑**: 영웅님 git -f 사례 같은 실제 문제에 두 시스템 협업 적용 가능
- **권한 폭주 방지**: 훈수꾼이 차단 권한 안 가짐 → 훈수꾼 환각이 사용자 작업 차단하는 위험 0

### 부정적·리스크

- **guard 부담**: 훈수꾼이 차단 권한 없으면 모든 즉시 게이트는 guard 책임 → guard 룰 비대화 위험
- **메타 패턴 surface 부담**: 훈수꾼이 cross-session 패턴 advisory 발행 시 사용자 피로 가능 → frequency 제어 필요 (정체성 §3.9 사용자 override)
- **guard 차단 결과 훈수꾼 참조 흐름 미정**: 본 ADR은 "READ-only로 참조"라 했으나 실제 메커니즘 미정 — 훈수꾼 prototype 시 결정

### 트레이드오프 검증 시점

- 훈수꾼 prototype 첫 구현 시 — guard 차단 결과 참조 메커니즘
- 같은 capability가 자주 차단되는 패턴 발생 시 — 훈수꾼 advisory가 사용자에게 유용한지
- guard 룰이 비대해지는 시점 — 일부를 훈수꾼 advisory로 위임할지 재검토

## 참조

- `2026-04-25-hunsugun-positioning.md` D5 — seam 4 영역 중 세 번째
- `skills/guard/SKILL.md` — guard 정체 (sonmat 리포 내)
- `2026-04-26-hunsugun-witness-seam.md`, `2026-04-26-hunsugun-scribe-seam.md` — 자매 ADR
- `docs/research/hunsugun-identity.md` v0.2 §3.1 권한 경계
- 단톡 인사이트 (working doc Phase 2 통합 패턴 #14 "running code") — git -f 사례
